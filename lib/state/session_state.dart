import 'dart:developer';

import 'package:flutter/material.dart';

import '../models/user_session.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/local_store.dart';

/// The single source of truth for the auth / session state (guest vs signed in).
///
/// Holds one [UserSession] object the whole app reads from. Coordinates the
/// guest → account migration so progress is never lost.
class SessionState extends ChangeNotifier {
  SessionState({
    required AuthService auth,
    required DatabaseService database,
    required LocalStore store,
  })  : _auth = auth,
        _database = database,
        _store = store {
    _bootstrap();
  }

  final AuthService _auth;
  final DatabaseService _database;
  final LocalStore _store;

  UserSession _session = UserSession.anonymousGuest;
  bool _initialized = false;
  bool _busy = false;

  UserSession get session => _session;
  bool get initialized => _initialized;
  bool get busy => _busy;
  String? get uid => _session.uid;

  // --- Entry / onboarding flags ---------------------------------------------
  bool get seenOnboarding => _store.seenOnboarding;
  Future<void> markOnboardingSeen() => _store.setSeenOnboarding(true);
  bool get appEntered => _store.appEntered;
  Future<void> markEntered() => _store.setAppEntered(true);

  /// Restores the last session: a signed-in Firebase user if present, otherwise
  /// a guest seeded with any locally stored display name and step goal.
  Future<void> _bootstrap() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _loadSignedIn(user.uid, fallbackName: user.displayName, email: user.email);
    } else {
      _session = UserSession(
        mode: AuthMode.guest,
        displayName: _store.guestName,
        dailyStepGoal: _store.stepGoal,
      );
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadSignedIn(String uid,
      {String? fallbackName, String? email}) async {
    Map<String, dynamic>? data;
    try {
      data = await _database.fetchUserData(uid);
    } catch (e) {
      log('fetchUserData failed: $e', name: 'SessionState');
    }
    final profile = data?['profile'];
    if (profile is Map) {
      _session = UserSession.signedInFromJson(
        uid,
        Map<String, dynamic>.from(profile),
      );
    } else {
      _session = UserSession(
        mode: AuthMode.signedIn,
        uid: uid,
        displayName: fallbackName,
        email: email,
        dailyStepGoal: _store.stepGoal,
      );
    }
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  // --- Guest -----------------------------------------------------------------
  Future<void> continueAsGuest({String? displayName}) async {
    if (displayName != null && displayName.trim().isNotEmpty) {
      await _store.setGuestName(displayName.trim());
    }
    _session = UserSession(
      mode: AuthMode.guest,
      displayName: displayName?.trim() ?? _store.guestName,
      dailyStepGoal: _store.stepGoal,
    );
    notifyListeners();
  }

  Future<void> setGuestName(String name) async {
    await _store.setGuestName(name.trim());
    _session = _session.copyWith(displayName: name.trim());
    notifyListeners();
  }

  // --- Account ---------------------------------------------------------------
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    try {
      final user = await _auth.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      // Migrate any guest progress into the new account so nothing is lost.
      final profile = UserSession(
        mode: AuthMode.signedIn,
        uid: user.uid,
        displayName: fullName.trim(),
        email: email.trim(),
        dailyStepGoal: _store.stepGoal,
      ).toJson();
      await _database.migrateGuestData(
        user.uid,
        profile: profile,
        stepsByDay: _store.stepsByDay,
        rsvps: _store.rsvps,
        workoutsCompleted: _store.workoutsCompleted,
      );
      _session = UserSession(
        mode: AuthMode.signedIn,
        uid: user.uid,
        displayName: fullName.trim(),
        email: email.trim(),
        dailyStepGoal: _store.stepGoal,
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logIn({required String email, required String password}) async {
    _setBusy(true);
    try {
      final user = await _auth.logIn(email: email, password: password);
      await _loadSignedIn(user.uid, fallbackName: user.displayName, email: user.email);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> sendPasswordReset(String email) => _auth.sendPasswordReset(email);

  /// Changes the signed-in user's account password.
  Future<void> changePassword(String newPassword) =>
      _auth.updatePassword(newPassword);

  Future<void> signOut() async {
    await _auth.signOut();
    _session = UserSession(
      mode: AuthMode.guest,
      displayName: _store.guestName,
      dailyStepGoal: _store.stepGoal,
    );
    notifyListeners();
  }

  /// Logs out of the current session — signed-in *or* guest — and clears the
  /// "entered" flag so the splash routes back to the Welcome screen on the next
  /// launch instead of dropping straight into the home shell.
  Future<void> logOut() async {
    if (_session.isSignedIn) {
      await _auth.signOut();
    }
    await _store.setAppEntered(false);
    _session = UserSession(
      mode: AuthMode.guest,
      displayName: _store.guestName,
      dailyStepGoal: _store.stepGoal,
    );
    notifyListeners();
  }

  // --- Profile edits ---------------------------------------------------------
  Future<void> updateProfile({
    String? displayName,
    String? email,
    String? faculty,
    String? photoUrl,
    int? dailyStepGoal,
  }) async {
    _session = _session.copyWith(
      displayName: displayName,
      email: email,
      faculty: faculty,
      photoUrl: photoUrl,
      dailyStepGoal: dailyStepGoal,
    );
    if (dailyStepGoal != null) await _store.setStepGoal(dailyStepGoal);
    if (_session.isGuest && displayName != null) {
      await _store.setGuestName(displayName.trim());
    }
    if (_session.isSignedIn && _session.uid != null) {
      try {
        await _database.writeUserProfile(_session.uid!, _session.toJson());
      } catch (e) {
        log('writeUserProfile failed: $e', name: 'SessionState');
      }
    }
    notifyListeners();
  }
}

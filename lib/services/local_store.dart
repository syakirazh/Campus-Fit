import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for guest-mode, local-first
/// persistence (display name, steps, workout history, RSVPs, settings).
///
/// All keys live here so storage concerns stay in one place.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStore> create() async =>
      LocalStore(await SharedPreferences.getInstance());

  // --- Keys ------------------------------------------------------------------
  static const _kGuestName = 'guest_display_name';
  static const _kStepGoal = 'daily_step_goal';
  static const _kStepsByDay = 'steps_by_day'; // json: {yyyy-MM-dd: int}
  static const _kPedometerBaseline = 'pedometer_baseline'; // json per day
  static const _kWorkoutsDone = 'workouts_completed';
  static const _kRsvps = 'event_rsvps'; // json: list of event ids
  static const _kUnlockedZones = 'unlocked_zones';
  static const _kThemeMode = 'theme_mode'; // system|light|dark
  static const _kUnitsMetric = 'units_metric';
  static const _kNotifications = 'notifications_enabled';
  static const _kSeenOnboarding = 'seen_onboarding';
  static const _kAppEntered = 'app_entered';

  // --- Onboarding ------------------------------------------------------------
  bool get seenOnboarding => _prefs.getBool(_kSeenOnboarding) ?? false;
  Future<void> setSeenOnboarding(bool v) => _prefs.setBool(_kSeenOnboarding, v);

  /// True once the user has chosen an entry path (guest or account), so
  /// returning guests skip straight to the home shell.
  bool get appEntered => _prefs.getBool(_kAppEntered) ?? false;
  Future<void> setAppEntered(bool v) => _prefs.setBool(_kAppEntered, v);

  // --- Guest profile ---------------------------------------------------------
  String? get guestName => _prefs.getString(_kGuestName);
  Future<void> setGuestName(String name) => _prefs.setString(_kGuestName, name);

  int get stepGoal => _prefs.getInt(_kStepGoal) ?? 8000;
  Future<void> setStepGoal(int goal) => _prefs.setInt(_kStepGoal, goal);

  // --- Steps -----------------------------------------------------------------
  Map<String, int> get stepsByDay {
    final raw = _prefs.getString(_kStepsByDay);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  Future<void> setStepsByDay(Map<String, int> map) =>
      _prefs.setString(_kStepsByDay, jsonEncode(map));

  /// The hardware step-counter is monotonic since boot; we store a per-day
  /// baseline so we can derive "steps today".
  Map<String, dynamic> get pedometerBaseline {
    final raw = _prefs.getString(_kPedometerBaseline);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> setPedometerBaseline(Map<String, dynamic> map) =>
      _prefs.setString(_kPedometerBaseline, jsonEncode(map));

  // --- Workouts --------------------------------------------------------------
  int get workoutsCompleted => _prefs.getInt(_kWorkoutsDone) ?? 0;
  Future<void> setWorkoutsCompleted(int n) =>
      _prefs.setInt(_kWorkoutsDone, n);

  // --- Events ----------------------------------------------------------------
  List<String> get rsvps => _prefs.getStringList(_kRsvps) ?? [];
  Future<void> setRsvps(List<String> ids) => _prefs.setStringList(_kRsvps, ids);

  // --- Campus zones ----------------------------------------------------------
  List<String> get unlockedZones =>
      _prefs.getStringList(_kUnlockedZones) ?? [];
  Future<void> setUnlockedZones(List<String> ids) =>
      _prefs.setStringList(_kUnlockedZones, ids);

  // --- Settings --------------------------------------------------------------
  String get themeMode => _prefs.getString(_kThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) => _prefs.setString(_kThemeMode, mode);

  bool get unitsMetric => _prefs.getBool(_kUnitsMetric) ?? true;
  Future<void> setUnitsMetric(bool v) => _prefs.setBool(_kUnitsMetric, v);

  bool get notificationsEnabled => _prefs.getBool(_kNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool v) =>
      _prefs.setBool(_kNotifications, v);

  /// Wipe guest progress (used after migrating into a new account).
  Future<void> clearGuestProgress() async {
    await _prefs.remove(_kGuestName);
    await _prefs.remove(_kStepsByDay);
    await _prefs.remove(_kWorkoutsDone);
    await _prefs.remove(_kRsvps);
    await _prefs.remove(_kUnlockedZones);
  }
}

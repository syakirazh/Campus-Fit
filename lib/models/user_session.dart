/// Whether the current user is signed in with a Firebase account or browsing
/// as a guest (the low-friction default).
enum AuthMode { guest, signedIn }

/// A single immutable snapshot of the auth / session state.
///
/// The whole app reads the signed-in vs guest distinction from one object, as
/// required. Guest sessions have a null [uid]; signed-in sessions carry the
/// Firebase uid so data can sync to the Realtime Database.
class UserSession {
  const UserSession({
    required this.mode,
    this.uid,
    this.displayName,
    this.email,
    this.faculty,
    this.photoUrl,
    this.dailyStepGoal = 8000,
  });

  final AuthMode mode;
  final String? uid;
  final String? displayName;
  final String? email;
  final String? faculty;
  final String? photoUrl;
  final int dailyStepGoal;

  bool get isGuest => mode == AuthMode.guest;
  bool get isSignedIn => mode == AuthMode.signedIn;

  /// A guest session with no name set yet.
  static const UserSession anonymousGuest = UserSession(mode: AuthMode.guest);

  UserSession copyWith({
    AuthMode? mode,
    String? uid,
    String? displayName,
    String? email,
    String? faculty,
    String? photoUrl,
    int? dailyStepGoal,
  }) {
    return UserSession(
      mode: mode ?? this.mode,
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      faculty: faculty ?? this.faculty,
      photoUrl: photoUrl ?? this.photoUrl,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'email': email,
        'faculty': faculty,
        'photoUrl': photoUrl,
        'dailyStepGoal': dailyStepGoal,
      };

  /// Reconstructs the profile fields for a signed-in user from their RTDB node.
  factory UserSession.signedInFromJson(String uid, Map<String, dynamic> json) {
    return UserSession(
      mode: AuthMode.signedIn,
      uid: uid,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      faculty: json['faculty'] as String?,
      photoUrl: json['photoUrl'] as String?,
      dailyStepGoal: (json['dailyStepGoal'] as num?)?.toInt() ?? 8000,
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';

/// Wraps [FirebaseAuth] so the rest of the app never touches the SDK directly.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(fullName.trim());
    return cred.user!;
  }

  Future<User> logIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Changes the signed-in user's password. May throw `requires-recent-login`
  /// if the session is stale, in which case the user must sign in again.
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'You must be signed in to change your password.',
      );
    }
    await user.updatePassword(newPassword);
  }

  Future<void> signOut() => _auth.signOut();

  /// Maps Firebase error codes to friendly, user-facing messages.
  static String messageFor(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'email-already-in-use' => 'That email is already registered.',
        'invalid-email' => 'That email address looks invalid.',
        'weak-password' => 'Please choose a stronger password (6+ characters).',
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'Incorrect email or password.',
        'network-request-failed' => 'Network error — check your connection.',
        'too-many-requests' => 'Too many attempts. Try again later.',
        'requires-recent-login' =>
          'Please sign out and sign in again to change your password.',
        _ => error.message ?? 'Authentication failed. Please try again.',
      };
    }
    return 'Something went wrong. Please try again.';
  }
}

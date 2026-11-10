import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName);
    await user.sendEmailVerification();
    return user;
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<bool> refreshVerification() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed == null || !refreshed.emailVerified) return false;
    await refreshed.getIdToken(true);
    return true;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  Future<void> signOut() => _auth.signOut();
}

String describeAuthError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'That email address is not valid.',
      'user-disabled' => 'This account has been disabled. Contact campus support.',
      'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists for this email. Try signing in.',
      'weak-password' => 'Choose a stronger password.',
      'too-many-requests' => 'Too many attempts. Wait a moment and try again.',
      'network-request-failed' => 'No internet connection. Check your network and try again.',
      _ => error.message ?? 'Authentication failed.',
    };
  }
  if (error is FirebaseException) {
    return error.message ?? 'Something went wrong. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:campus_incidents/models/app_user.dart';
import 'package:campus_incidents/services/auth_service.dart';
import 'package:campus_incidents/services/user_repository.dart';

enum SessionStatus { loading, signedOut, unverified, signedIn }

class SessionProvider extends ChangeNotifier {
  SessionProvider({required AuthService authService, required UserRepository users})
      : _authService = authService,
        _users = users {
    _authSub = _authService.authStateChanges().listen(_onAuthChanged);
  }

  final AuthService _authService;
  final UserRepository _users;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  SessionStatus _status = SessionStatus.loading;
  AppUser? _profile;
  String? _profileError;
  bool _busy = false;

  SessionStatus get status => _status;
  AppUser? get profile => _profile;
  String? get profileError => _profileError;
  bool get busy => _busy;
  String get email => _authService.currentUser?.email ?? '';

  void _onAuthChanged(User? user) {
    _profileSub?.cancel();
    _profileSub = null;
    _profile = null;
    _profileError = null;

    if (user == null) {
      _status = SessionStatus.signedOut;
      notifyListeners();
      return;
    }
    if (!user.emailVerified) {
      _status = SessionStatus.unverified;
      notifyListeners();
      return;
    }
    _listenToProfile(user);
  }

  void _listenToProfile(User user) {
    _profileSub?.cancel();
    _status = SessionStatus.loading;
    _profileError = null;
    notifyListeners();

    _profileSub = _users.watch(user.uid).listen(
      (profile) {
        if (profile == null) {
          _restoreMissingProfile(user);
          return;
        }
        _profile = profile;
        _status = SessionStatus.signedIn;
        notifyListeners();
      },
      onError: (Object _) {
        _profileError = 'Your profile could not be loaded. Check your connection and try again.';
        notifyListeners();
      },
    );
  }

  Future<void> _restoreMissingProfile(User user) async {
    final email = user.email ?? '';
    try {
      await _users.createProfile(AppUser(
        uid: user.uid,
        fullName: user.displayName ?? email.split('@').first,
        email: email,
        role: UserRole.student,
      ));
    } on FirebaseException {
      _profileError = 'Your profile could not be created. Sign out and try again.';
      notifyListeners();
    }
  }

  Future<String?> signIn(String email, String password) {
    return _run(() => _authService.signIn(email: email, password: password));
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    String program = '',
  }) {
    return _run(() async {
      final name = fullName.trim();
      final user = await _authService.register(email: email, password: password, displayName: name);
      await _users.createProfile(AppUser(
        uid: user.uid,
        fullName: name,
        email: user.email ?? email.trim().toLowerCase(),
        role: UserRole.student,
        program: program.trim(),
      ));
    });
  }

  Future<String?> resendVerification() => _run(_authService.sendVerificationEmail);

  Future<String?> resetPassword(String email) => _run(() => _authService.sendPasswordReset(email));

  Future<bool> checkVerification() async {
    try {
      final verified = await _authService.refreshVerification();
      final user = _authService.currentUser;
      if (verified && user != null && _status == SessionStatus.unverified) {
        _listenToProfile(user);
      }
      return verified;
    } on FirebaseException {
      return false;
    }
  }

  Future<void> signOut() => _authService.signOut();

  Future<String?> _run(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
      return null;
    } catch (error) {
      return describeAuthError(error);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}

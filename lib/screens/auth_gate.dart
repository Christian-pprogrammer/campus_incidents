import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/providers/session_provider.dart';
import 'package:campus_incidents/screens/auth/login_screen.dart';
import 'package:campus_incidents/screens/auth/verify_email_screen.dart';
import 'package:campus_incidents/screens/main_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    return switch (session.status) {
      SessionStatus.loading => _LoadingView(error: session.profileError, onSignOut: session.signOut),
      SessionStatus.signedOut => const LoginScreen(),
      SessionStatus.unverified => const VerifyEmailScreen(),
      SessionStatus.signedIn => const MainShell(),
    };
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.error, required this.onSignOut});

  final String? error;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    TextButton(onPressed: onSignOut, child: const Text('Sign out')),
                  ],
                ),
              ),
      ),
    );
  }
}

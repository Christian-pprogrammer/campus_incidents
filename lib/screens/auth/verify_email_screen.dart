import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/providers/session_provider.dart';
import 'package:campus_incidents/widgets/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _resendDelay = 30;

  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _cooldown = _resendDelay;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _check(silent: true));
    _startCooldown();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldown = _resendDelay;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown <= 1) timer.cancel();
      setState(() => _cooldown--);
    });
  }

  Future<void> _check({bool silent = false}) async {
    if (_checking) return;
    final session = context.read<SessionProvider>();
    if (!silent) setState(() => _checking = true);
    final verified = await session.checkVerification();
    if (!mounted) return;
    if (!silent) setState(() => _checking = false);
    if (!verified && !silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not verified yet. Open the link in your inbox first.')),
      );
    }
  }

  Future<void> _resend() async {
    final error = await context.read<SessionProvider>().resendVerification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'A new verification link is on its way.')),
    );
    if (error == null) setState(_startCooldown);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                  child: const Icon(Icons.mark_email_unread_outlined, color: AppColors.primary, size: 38),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Check your inbox',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  'We sent a verification link to ${session.email}. '
                  'Open it to activate your account, then come back here.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Outlook sometimes files it under Junk.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: "I've verified my email",
                  loading: _checking,
                  onPressed: _check,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _cooldown > 0 ? null : _resend,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(_cooldown > 0 ? 'Resend link in ${_cooldown}s' : 'Resend link'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: session.signOut,
                  child: const Text('Use a different account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

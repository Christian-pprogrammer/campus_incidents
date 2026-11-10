import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/core/validators.dart';
import 'package:campus_incidents/providers/session_provider.dart';
import 'package:campus_incidents/screens/auth/register_screen.dart';
import 'package:campus_incidents/widgets/app_text_field.dart';
import 'package:campus_incidents/widgets/brand_mark.dart';
import 'package:campus_incidents/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<SessionProvider>().signIn(_email.text, _password.text);
    if (!mounted || error == null) return;
    _showMessage(error);
  }

  Future<void> _resetPassword() async {
    if (Validators.email(_email.text) != null) {
      _showMessage('Enter your ALU email above, then tap Forgot password again.');
      return;
    }
    final error = await context.read<SessionProvider>().resetPassword(_email.text);
    if (!mounted) return;
    _showMessage(error ?? 'Reset link sent to ${_email.text.trim()}.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<SessionProvider, bool>((s) => s.busy);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMark(),
                    const SizedBox(height: 36),
                    const Text(
                      'Welcome back',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in with your ALU account to report and track campus issues.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: 'ALU email',
                      controller: _email,
                      hint: 'name@alustudent.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      controller: _password,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _signIn(),
                      validator: (value) => (value ?? '').isEmpty ? 'Enter your password' : null,
                      suffix: IconButton(
                        icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: busy ? null : _resetPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(label: 'Sign in', loading: busy, onPressed: _signIn),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("New here?", style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                  ),
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/core/validators.dart';
import 'package:campus_incidents/providers/session_provider.dart';
import 'package:campus_incidents/widgets/app_text_field.dart';
import 'package:campus_incidents/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _program = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    for (final controller in [_name, _email, _program, _password, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final error = await context.read<SessionProvider>().register(
          fullName: _name.text,
          email: _email.text,
          password: _password.text,
          program: _program.text,
        );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<SessionProvider, bool>((s) => s.busy);

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              const Text(
                'Only @alustudent.com and @alueducation.com addresses can sign up. '
                'We will email you a link to confirm the address belongs to you.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Full name',
                controller: _name,
                hint: 'Amina Hassan',
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: Validators.fullName,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'ALU email',
                controller: _email,
                hint: 'a.hassan@alustudent.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Program or department (optional)',
                controller: _program,
                hint: 'Software Engineering',
                prefixIcon: Icons.school_outlined,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                controller: _password,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _hidePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.password,
                suffix: IconButton(
                  icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Confirm password',
                controller: _confirm,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _hidePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _register(),
                validator: (value) => value != _password.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 28),
              PrimaryButton(label: 'Create account', loading: busy, onPressed: _register),
            ],
          ),
        ),
      ),
    );
  }
}

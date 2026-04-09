import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../shared/repositories/auth_repository.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool loading = false;
  bool _awaitingVerification = false;

  String? _validateEmail(String value) => RegExp(r'\S+@\S+\.\S+').hasMatch(value) ? null : 'Invalid email';

  Future<void> _submit() async {
    if (name.text.trim().isEmpty ||
        _validateEmail(email.text.trim()) != null ||
        password.text.length < 8 ||
        password.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix form errors')));
      return;
    }
    setState(() => loading = true);
    try {
      final needsVerification = await AuthRepository().signUp(name.text.trim(), email.text.trim(), password.text);
      if (!mounted) return;
      if (needsVerification) {
        setState(() => _awaitingVerification = true);
      } else {
        context.go('/chats');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_awaitingVerification) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_unread_outlined, size: 64, color: AppColors.accent),
                const SizedBox(height: 20),
                const Text('Check your email', style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 24, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  'We sent a confirmation link to ${email.text.trim()}. Click it to activate your account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'DMSans', color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to Login', style: TextStyle(color: AppColors.accent)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text('Create Account', style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 26, color: AppColors.textPrimary)),
              const Text('Join AisodChat', style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF666666))),
              const SizedBox(height: 16),
              AppInput(label: 'Full Name', controller: name),
              AppInput(label: 'Email', controller: email),
              AppInput(label: 'Password', controller: password, obscureText: true),
              AppInput(label: 'Confirm Password', controller: confirm, obscureText: true),
              AppButton(label: 'Create Account', loading: loading, onPressed: _submit),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Login', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

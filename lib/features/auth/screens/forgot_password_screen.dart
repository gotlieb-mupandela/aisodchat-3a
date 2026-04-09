import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../shared/repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();
  bool loading = false;
  bool success = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => loading = true);
    try {
      await AuthRepository().resetPassword(email.text.trim());
      if (mounted) setState(() => success = true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reset Password', style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 24, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Enter your email and we will send a reset link.', style: TextStyle(color: Color(0xFF666666))),
              const SizedBox(height: 16),
              if (!success) ...[
                AppInput(label: 'Email', controller: email),
                AppButton(label: 'Send Reset Link', loading: loading, onPressed: _send),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1D3D2A), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success)),
                  child: const Text('Check your email', style: TextStyle(color: AppColors.success)),
                ),
                TextButton(onPressed: () => context.go('/login'), child: const Text('Back to Login')),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

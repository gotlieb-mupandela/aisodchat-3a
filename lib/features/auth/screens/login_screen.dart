import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../shared/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      await AuthRepository().signIn(email.text.trim(), password.text);
      if (!mounted) return;
      context.go('/chats');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email or password')));
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome Back', style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 26, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Sign in to AisodChat', style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF666666))),
              const SizedBox(height: 16),
              AppInput(label: 'Email', controller: email, hintText: 'you@example.com'),
              AppInput(label: 'Password', controller: password, obscureText: true),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Forgot Password?', style: TextStyle(color: AppColors.accent))),
              ),
              AppButton(label: 'Sign In', loading: loading, onPressed: _submit),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Don\'t have an account? Sign Up', style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

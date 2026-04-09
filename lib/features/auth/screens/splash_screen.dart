import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/repositories/auth_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final auth = AuthRepository();
    final hasLaunched = await AppStorage.getHasLaunched();
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (auth.currentUser != null) {
      context.go('/chats');
    } else if (!hasLaunched) {
      context.go('/onboarding');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.accent,
              child: Text('A', style: TextStyle(color: Colors.white, fontFamily: 'PlayfairDisplay', fontSize: 26)),
            ),
            SizedBox(height: 12),
            Text('AisodChat', style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 28, color: AppColors.textPrimary)),
            Text('by AISOD Institute', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

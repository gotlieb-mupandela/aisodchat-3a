import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/chats_list_screen.dart';
import '../../features/settings/screens/about_screen.dart';
import '../../features/settings/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

class _AuthNotifier extends ChangeNotifier {
  StreamSubscription<AuthState>? _sub;

  _AuthNotifier() {
    _sub = SupabaseService.client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final _authNotifierProvider = Provider<_AuthNotifier>((ref) {
  final notifier = _AuthNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

const _protectedPaths = ['/chats', '/chat', '/settings', '/profile', '/about'];

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(_authNotifierProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = SupabaseService.client.auth.currentUser;
      final loc = state.matchedLocation;
      final isProtected = _protectedPaths.any((p) => loc.startsWith(p));
      if (user == null && isProtected) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/chats', builder: (_, __) => const ChatsListScreen()),
      GoRoute(path: '/chat/:id', builder: (_, state) => ChatScreen(chatId: state.pathParameters['id']!)),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
    ],
  );
});

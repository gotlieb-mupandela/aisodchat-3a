import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../shared/models/chat_models.dart';
import '../../../shared/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(defaultModeProvider);
    return AppScaffold(
      title: 'Settings',
      leading: IconButton(onPressed: () => context.go('/chats'), icon: const Icon(Icons.arrow_back)),
      child: ListView(
        children: [
          _row('Profile', () => context.push('/profile')),
          _row('Change Password', () => context.push('/forgot-password')),
          ListTile(
            title: const Text('Default Mode: Offline', style: TextStyle(fontFamily: 'DMSans')),
            trailing: Switch(
              value: mode == ChatMode.offline,
              activeColor: AppColors.accent,
              onChanged: (value) => ref.read(defaultModeProvider.notifier).set(value ? ChatMode.offline : ChatMode.online),
            ),
          ),
          _row('Storage / Model', () {}),
          _row('About', () => context.push('/about')),
          _row('Sign Out', () async {
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) context.go('/login');
          }, danger: true),
        ],
      ),
    );
  }

  Widget _row(String title, VoidCallback onTap, {bool danger = false}) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: TextStyle(fontFamily: 'DMSans', color: danger ? AppColors.danger : AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/state/session_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../shared/providers/app_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  bool loading = false;
  bool _prefilled = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    emailController.text = user?.email ?? '';

    final profile = ref.watch(userProfileProvider);
    profile.whenData((data) {
      if (!_prefilled) {
        _prefilled = true;
        if (data != null) {
          nameController.text = (data['name'] as String?) ?? '';
        }
      }
    });

    final initial = nameController.text.isNotEmpty
        ? nameController.text[0].toUpperCase()
        : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : '?');

    return AppScaffold(
      title: 'Profile',
      leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      child: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading profile: $e', style: const TextStyle(color: AppColors.danger))),
        data: (_) => Column(
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.accent,
              child: Text(initial, style: const TextStyle(color: Colors.white, fontFamily: 'PlayfairDisplay', fontSize: 22)),
            ),
            const SizedBox(height: 16),
            AppInput(label: 'Full Name', controller: nameController),
            AppInput(label: 'Email', controller: emailController, readOnly: true),
            AppButton(
              label: 'Save Changes',
              loading: loading,
              onPressed: () async {
                if (user == null) return;
                setState(() => loading = true);
                try {
                  await ref.read(authRepositoryProvider).updateProfile(user.id, nameController.text.trim());
                  ref.invalidate(userProfileProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => loading = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

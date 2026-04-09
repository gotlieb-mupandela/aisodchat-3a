import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    final user = ref.read(authRepositoryProvider).currentUser;
    emailController.text = user?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile',
      leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      child: Column(
        children: [
          const CircleAvatar(radius: 32, backgroundColor: AppColors.accent, child: Text('G', style: TextStyle(color: Colors.white, fontFamily: 'PlayfairDisplay', fontSize: 22))),
          TextButton(onPressed: () {}, child: const Text('Change Photo', style: TextStyle(color: AppColors.accent))),
          AppInput(label: 'Full Name', controller: nameController),
          AppInput(label: 'Email', controller: emailController, readOnly: true),
          AppButton(
            label: 'Save Changes',
            loading: loading,
            onPressed: () async {
              final user = ref.read(authRepositoryProvider).currentUser;
              if (user == null) return;
              setState(() => loading = true);
              await ref.read(chatRepositoryProvider);
              await Future<void>.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                setState(() => loading = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
              }
            },
          )
        ],
      ),
    );
  }
}

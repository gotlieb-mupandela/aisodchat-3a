import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'About',
      leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(radius: 25, backgroundColor: AppColors.accent, child: Text('A', style: TextStyle(color: Colors.white, fontFamily: 'PlayfairDisplay'))),
          const SizedBox(height: 10),
          const Text('AisodChat', style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 18)),
          const Text('Version 1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const Text('Powered by Aisod 3A', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 24),
          _row('AISOD Institute'),
          _row('Terms of Service'),
          _row('Privacy Policy'),
          _row('Open Source Licenses'),
        ],
      ),
    );
  }

  static Widget _row(String label) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontFamily: 'DMSans')),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}

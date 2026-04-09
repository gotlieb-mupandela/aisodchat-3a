import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/chat_models.dart';
import '../../../shared/providers/app_providers.dart';

class ModelPickerSheet extends ConsumerWidget {
  const ModelPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(defaultModeProvider);
    final downloaded = ref.watch(modelDownloadedProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: SizedBox(width: 32, child: Divider(color: Color(0xFF444444), thickness: 3))),
          const SizedBox(height: 10),
          const Text('Select Mode', style: TextStyle(color: Colors.grey, fontFamily: 'DMSans', fontSize: 12)),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Aisod 3A - Online', style: TextStyle(fontFamily: 'PlayfairDisplay')),
            subtitle: const Text('Full power - Requires internet', style: TextStyle(fontSize: 11)),
            trailing: mode == ChatMode.online ? const Icon(Icons.check_circle, color: AppColors.accent) : null,
            onTap: () => ref.read(defaultModeProvider.notifier).set(ChatMode.online),
          ),
          ListTile(
            title: const Text('Aisod 3A 0.1 - Offline', style: TextStyle(fontFamily: 'PlayfairDisplay')),
            subtitle: const Text('On-device - ~491MB', style: TextStyle(fontSize: 11)),
            trailing: mode == ChatMode.offline ? const Icon(Icons.check_circle, color: AppColors.accent) : null,
            onTap: () => ref.read(defaultModeProvider.notifier).set(ChatMode.offline),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => ref.read(modelDownloadedProvider.notifier).set(!downloaded),
              child: Text(downloaded ? 'Delete model' : 'Download model', style: TextStyle(color: downloaded ? AppColors.danger : AppColors.accent)),
            ),
          )
        ],
      ),
    );
  }
}

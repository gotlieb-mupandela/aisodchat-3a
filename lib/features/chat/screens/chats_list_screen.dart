import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/state/session_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../shared/models/chat_models.dart';
import '../../../shared/providers/app_providers.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  final search = TextEditingController();
  List<AppConversation> conversations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }
    final rows = await ref.read(chatRepositoryProvider).getConversations(user.id);
    if (mounted) {
      setState(() {
        conversations = rows;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = conversations
        .where((c) => c.title.toLowerCase().contains(search.text.toLowerCase()))
        .toList();

    return AppScaffold(
      title: 'Chats',
      actions: [
        IconButton(onPressed: () => context.push('/settings'), icon: const Icon(Icons.menu))
      ],
      child: Column(
        children: [
          TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search Chats...'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('No chats yet', style: TextStyle(color: AppColors.textMuted)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(color: AppColors.bgSecondary, height: 1),
                          itemBuilder: (_, index) {
                            final chat = filtered[index];
                            return ListTile(
                              onTap: () => context.push('/chat/${chat.id}'),
                              title: Text(chat.title, style: const TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary)),
                              subtitle: Text(DateFormat.yMMMd().add_jm().format(chat.updatedAt), style: const TextStyle(fontSize: 11)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.danger),
                                onPressed: () async {
                                  await ref.read(chatRepositoryProvider).deleteConversation(chat.id);
                                  await _load();
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () => context.push('/chat/new'),
              child: const Text('+ New Chat'),
            ),
          )
        ],
      ),
    );
  }
}

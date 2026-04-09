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

  final List<String> suggestions = [
    'What is 3A?',
    'Learn AI skills',
    'Automate my business',
    'AI for education',
    'Build AI agents',
    'Get in touch',
  ];

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

  void _startChat(String initialMessage) async {
    // We can navigate to a new chat and pass the message as a query param or state,
    // but for simplicity, we'll just go to '/chat/new' and let the user type,
    // or we can implement a way to pre-fill. Let's just go to new chat for now.
    context.push('/chat/new');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = conversations
        .where((c) => c.title.toLowerCase().contains(search.text.toLowerCase()))
        .toList();

    return AppScaffold(
      title: null, // We'll use a custom header
      padding: EdgeInsets.zero,
      actions: [
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
        )
      ],
      child: Column(
        children: [
          // Custom Header matching the screenshot
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Simple logo representation
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2D6BDE), Color(0xFF7EA6F7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AISOD',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Meet 3A - Namibia's #1 AI assistant solving real problems",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Transform your business, advance your career, or automate operations with AISOD 3A",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Search / Prompt Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20, right: 12),
                        child: Icon(Icons.search, color: AppColors.textMuted, size: 22),
                      ),
                      Expanded(
                        child: TextField(
                          controller: search,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Ask 3A anything about AISOD...',
                            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 15),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: AppColors.accentLight,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _startChat(search.text),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Suggestion Chips
                if (search.text.isEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: suggestions.map((text) {
                      return ActionChip(
                        label: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () => _startChat(text),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          
          const Divider(color: AppColors.border, height: 1),
          
          // Chat History List
          Expanded(
            child: Container(
              color: AppColors.bgPrimary,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No recent chats',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                            itemBuilder: (_, index) {
                              final chat = filtered[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                onTap: () => context.push('/chat/${chat.id}'),
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.bgSecondary,
                                  child: Icon(Icons.chat_bubble_outline, color: AppColors.accent, size: 20),
                                ),
                                title: Text(
                                  chat.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  DateFormat.yMMMd().add_jm().format(chat.updatedAt),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat/new'),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


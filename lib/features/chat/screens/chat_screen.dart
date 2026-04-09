import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/state/session_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../shared/models/chat_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../widgets/message_bubble.dart';
import '../widgets/model_picker_sheet.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final input = TextEditingController();
  final scroll = ScrollController();
  List<AppMessage> messages = [];
  bool loading = true;
  bool typing = false;
  StreamSubscription<String>? streamSub;
  String? conversationId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    streamSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.chatId == 'new') {
      setState(() => loading = false);
      return;
    }
    final rows = await ref.read(chatRepositoryProvider).getMessages(widget.chatId);
    setState(() {
      messages = rows;
      conversationId = widget.chatId;
      loading = false;
    });
  }

  Future<void> _send() async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    input.clear();
    final mode = ref.read(defaultModeProvider);
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final optimisticUser = AppMessage(
      id: 'local-user-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId ?? 'new',
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
      isOffline: mode == ChatMode.offline,
    );
    setState(() {
      messages = [...messages, optimisticUser];
      typing = true;
    });

    var cid = conversationId;
    if (cid == null) {
      final title = await ref.read(aiServiceProvider).generateTitle(text);
      cid = await ref.read(chatRepositoryProvider).createConversation(
            userId: user.id,
            title: title,
            mode: mode,
          );
      conversationId = cid;
      if (mounted) context.go('/chat/$cid');
    }
    await ref.read(chatRepositoryProvider).saveMessage(
          conversationId: cid!,
          role: 'user',
          content: text,
          isOffline: mode == ChatMode.offline,
        );

    final assistantSeed = AppMessage(
      id: 'local-ai-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: cid,
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isOffline: mode == ChatMode.offline,
    );
    setState(() => messages = [...messages, assistantSeed]);

    if (mode == ChatMode.online) {
      final history = messages.map((m) => {'role': m.role, 'content': m.content}).toList();
      final stream = ref.read(aiServiceProvider).streamReply(history);
      streamSub = stream.listen((chunk) {
        setState(() {
          final last = messages.last;
          messages = [...messages.sublist(0, messages.length - 1), AppMessage(
            id: last.id,
            conversationId: last.conversationId,
            role: last.role,
            content: '${last.content}$chunk',
            createdAt: last.createdAt,
            isOffline: false,
          )];
        });
      }, onDone: () async {
        final finalText = messages.last.content;
        await ref.read(chatRepositoryProvider).saveMessage(
              conversationId: cid!,
              role: 'assistant',
              content: finalText,
              isOffline: false,
            );
        if (mounted) setState(() => typing = false);
      }, onError: (_) {
        if (mounted) setState(() => typing = false);
      });
    } else {
      final downloaded = ref.read(modelDownloadedProvider);
      if (!downloaded) {
        if (mounted) {
          setState(() => typing = false);
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => const ModelPickerSheet(),
          );
        }
        return;
      }
      ref.read(offlineModelServiceProvider).complete(text).listen((token) async {
        setState(() {
          final last = messages.last;
          messages = [...messages.sublist(0, messages.length - 1), AppMessage(
            id: last.id,
            conversationId: last.conversationId,
            role: last.role,
            content: '${last.content}$token',
            createdAt: last.createdAt,
            isOffline: true,
          )];
        });
      }, onDone: () async {
        await ref.read(chatRepositoryProvider).saveMessage(
              conversationId: cid!,
              role: 'assistant',
              content: messages.last.content,
              isOffline: true,
            );
        if (mounted) setState(() => typing = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(defaultModeProvider);
    return AppScaffold(
      title: '',
      leading: IconButton(onPressed: () => context.go('/chats'), icon: const Icon(Icons.arrow_back)),
      actions: [
        TextButton.icon(
          onPressed: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => const ModelPickerSheet(),
          ),
          icon: Icon(Icons.circle, size: 8, color: mode == ChatMode.online ? AppColors.success : Colors.grey),
          label: Text(mode == ChatMode.online ? 'Aisod 3A' : 'Aisod 3A 0.1', style: const TextStyle(fontFamily: 'PlayfairDisplay', color: AppColors.textPrimary)),
        )
      ],
      child: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 20, backgroundColor: AppColors.accent, child: Text('A', style: TextStyle(color: Colors.white))),
                            SizedBox(height: 12),
                            Text('How can I help you this afternoon?', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20))
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scroll,
                        itemCount: messages.length + (typing ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (typing && i == messages.length) return const TypingIndicator();
                          final m = messages[i];
                          return MessageBubble(role: m.role, content: m.content);
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const CircleAvatar(radius: 16, backgroundColor: Color(0xFF333333), child: Icon(Icons.add, size: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: input,
                    minLines: 1,
                    maxLines: 6,
                    style: const TextStyle(fontFamily: 'DMSans'),
                    decoration: const InputDecoration.collapsed(hintText: 'Chat with Aisod 3A...'),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const CircleAvatar(radius: 16, backgroundColor: AppColors.accent, child: Icon(Icons.arrow_upward, size: 16, color: Colors.white)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

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
  StreamSubscription<String>? offlineStreamSub;
  String? conversationId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    streamSub?.cancel();
    offlineStreamSub?.cancel();
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _load() async {
    if (widget.chatId == 'new') {
      setState(() => loading = false);
      return;
    }
    try {
      final rows = await ref.read(chatRepositoryProvider).getMessages(widget.chatId);
      if (mounted) {
        setState(() {
          messages = rows;
          conversationId = widget.chatId;
          loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load messages: $e')));
      }
    }
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
    _scrollToBottom();

    try {
      var cid = conversationId;
      if (cid == null) {
        String title = 'New Chat';
        try {
          title = await ref.read(aiServiceProvider).generateTitle(text);
        } catch (_) {}
        cid = await ref.read(chatRepositoryProvider).createConversation(
              userId: user.id,
              title: title,
              mode: mode,
            );
        conversationId = cid;
        if (mounted) context.go('/chat/$cid');
      }
      await ref.read(chatRepositoryProvider).saveMessage(
            conversationId: cid,
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
        streamSub = stream.listen(
          (chunk) {
            if (!mounted) return;
            setState(() {
              final last = messages.last;
              messages = [
                ...messages.sublist(0, messages.length - 1),
                AppMessage(
                  id: last.id,
                  conversationId: last.conversationId,
                  role: last.role,
                  content: '${last.content}$chunk',
                  createdAt: last.createdAt,
                  isOffline: false,
                ),
              ];
            });
            _scrollToBottom();
          },
          onDone: () async {
            if (messages.isEmpty) return;
            final finalText = messages.last.content;
            await ref.read(chatRepositoryProvider).saveMessage(
                  conversationId: cid!,
                  role: 'assistant',
                  content: finalText,
                  isOffline: false,
                );
            if (mounted) setState(() => typing = false);
          },
          onError: (_) {
            if (mounted) setState(() => typing = false);
          },
        );
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
        offlineStreamSub = ref.read(offlineModelServiceProvider).complete(text).listen(
          (token) {
            if (!mounted) return;
            setState(() {
              final last = messages.last;
              messages = [
                ...messages.sublist(0, messages.length - 1),
                AppMessage(
                  id: last.id,
                  conversationId: last.conversationId,
                  role: last.role,
                  content: '${last.content}$token',
                  createdAt: last.createdAt,
                  isOffline: true,
                ),
              ];
            });
            _scrollToBottom();
          },
          onDone: () async {
            if (messages.isEmpty) return;
            await ref.read(chatRepositoryProvider).saveMessage(
                  conversationId: cid!,
                  role: 'assistant',
                  content: messages.last.content,
                  isOffline: true,
                );
            if (mounted) setState(() => typing = false);
          },
          onError: (_) {
            if (mounted) setState(() => typing = false);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => typing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
                            Text('How can I help you?', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 20)),
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {}, // Attachment logic placeholder
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.textMuted, size: 24),
                ),
                Expanded(
                  child: TextField(
                    controller: input,
                    minLines: 1,
                    maxLines: 6,
                    style: const TextStyle(fontFamily: 'DMSans', fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Chat with Aisod 3A...',
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
                      onTap: _send,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

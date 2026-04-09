import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.role, required this.content});
  final String role;
  final String content;

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? AppColors.accent : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: isUser
            ? Text(content, style: const TextStyle(color: Colors.white, fontFamily: 'DMSans'))
            : MarkdownBody(
                data: content,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Color(0xFFD0CDC8), fontFamily: 'DMSans', fontSize: 13),
                  code: const TextStyle(fontFamily: 'JetBrainsMono', color: Colors.white, backgroundColor: Color(0xFF2E2E2E)),
                  codeblockDecoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                ),
              ),
      ),
    );
  }
}

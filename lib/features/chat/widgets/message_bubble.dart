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
          color: isUser ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: isUser ? null : Border.all(color: AppColors.border, width: 0.5),
        ),
        child: isUser
            ? Text(content, style: const TextStyle(color: Colors.white, fontFamily: 'DMSans', fontSize: 14))
            : MarkdownBody(
                data: content,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: AppColors.textPrimary, fontFamily: 'DMSans', fontSize: 14),
                  code: const TextStyle(fontFamily: 'JetBrainsMono', color: AppColors.textPrimary, backgroundColor: Color(0xFFF0F4FA)),
                  codeblockDecoration: BoxDecoration(color: const Color(0xFFF0F4FA), borderRadius: BorderRadius.circular(8)),
                ),
              ),
      ),
    );
  }
}

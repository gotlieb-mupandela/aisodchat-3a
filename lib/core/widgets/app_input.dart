import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.errorText,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final String? errorText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF666666), fontFamily: 'DMSans', fontSize: 11)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscureText,
            readOnly: readOnly,
            style: TextStyle(
              color: readOnly ? Colors.grey : AppColors.textPrimary,
              fontFamily: 'DMSans',
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              errorText: errorText,
            ),
          ),
        ],
      ),
    );
  }
}

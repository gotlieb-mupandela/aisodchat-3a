import 'package:flutter/material.dart';

class AppColors {
  static const bgPrimary = Color(0xFF1C1C1C);
  static const bgSecondary = Color(0xFF252525);
  static const bgCard = Color(0xFF2E2E2E);
  static const accent = Color(0xFFE8693A);
  static const accentLight = Color(0xFFF0875A);
  static const textPrimary = Color(0xFFF0EDE8);
  static const textSecondary = Color(0xFF9A9690);
  static const textMuted = Color(0xFF555555);
  static const border = Color(0xFF333333);
  static const success = Color(0xFF4CAF82);
  static const danger = Color(0xFFE05050);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      cardColor: AppColors.bgCard,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentLight,
        surface: AppColors.bgSecondary,
        error: AppColors.danger,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'PlayfairDisplay', color: AppColors.textPrimary),
        titleLarge: TextStyle(fontFamily: 'PlayfairDisplay', color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontFamily: 'DMSans', color: AppColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

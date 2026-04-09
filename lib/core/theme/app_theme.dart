import 'package:flutter/material.dart';

class AppColors {
  static const bgPrimary = Color(0xFFF7F9FC);
  static const bgSecondary = Color(0xFFFFFFFF);
  static const bgCard = Color(0xFFFFFFFF);
  static const accent = Color(0xFF2D6BDE);
  static const accentLight = Color(0xFF7EA6F7);
  static const textPrimary = Color(0xFF1B2A41);
  static const textSecondary = Color(0xFF4D5E7C);
  static const textMuted = Color(0xFF8A97AF);
  static const border = Color(0xFFD8E1F0);
  static const success = Color(0xFF2BAA7A);
  static const danger = Color(0xFFE04F5F);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      cardColor: AppColors.bgCard,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.accentLight,
        surface: AppColors.bgSecondary,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF6C4BF4);
  static const primaryLight = Color(0xFF9479FF);
  static const primarySoft = Color(0xFFEFEBFF);
  static const background = Color(0xFFF7F7FB);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF17162E);
  static const textSecondary = Color(0xFF6F6E85);
  static const border = Color(0xFFE7E6F0);
  static const amber = Color(0xFFD98A00);
  static const amberSoft = Color(0xFFFFF3D6);
  static const blue = Color(0xFF3D6FE8);
  static const blueSoft = Color(0xFFE8EEFF);
  static const green = Color(0xFF2E9E5B);
  static const greenSoft = Color(0xFFE3F5E9);
  static const red = Color(0xFFDC4A4F);
  static const redSoft = Color(0xFFFDE9E9);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
    );
    final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          fontSize: 14,
        ),
        border: _outline(AppColors.border),
        enabledBorder: _outline(AppColors.border),
        focusedBorder: _outline(AppColors.primary, 1.4),
        errorBorder: _outline(AppColors.red),
        focusedErrorBorder: _outline(AppColors.red, 1.4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
    );
  }

  static OutlineInputBorder _outline(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

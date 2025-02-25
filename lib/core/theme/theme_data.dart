import 'package:flutter/material.dart';

/// Define your app’s core colors matching the TOT vibe.
class AppColors {
  static const primary = Color(0xFFFF5A5F); // Warm red
  static const secondary = Color(0xFFFFA726); // Vibrant orange
  static const accent = Color(0xFFFAFAFA); // Light accent
  static const backgroundLight = Color(0xFFF5F5F5); // Clean light background
  static const backgroundDark = Color(0xFF2C2C2C); // Deep dark gray
  static const textPrimaryLight =
      Color(0xFF333333); // Dark text on light background
  static const textPrimaryDark =
      Color(0xFFF5F5F5); // Light text on dark background
  static const textSecondary = Color(0xFF888888); // Muted text
  static const error = Colors.red;
}

/// Define your app’s fonts.
class AppFonts {
  static const bold = 'RobotoBold';
  static const regular = 'RobotoRegular';
  static const semiBold = 'RobotoSemiBold';
  static const medium = 'RobotoMedium';
}

/// Define both light and dark themes.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppFonts.bold,
          fontSize: 20,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: AppFonts.bold,
          fontSize: 24,
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppFonts.regular,
          fontSize: 14,
          color: AppColors.textPrimaryLight,
        ),
        bodySmall: TextStyle(
          fontFamily: AppFonts.regular,
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          textStyle: const TextStyle(fontFamily: AppFonts.semiBold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppFonts.bold,
          fontSize: 20,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: AppFonts.bold,
          fontSize: 24,
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppFonts.regular,
          fontSize: 14,
          color: AppColors.textPrimaryDark,
        ),
        bodySmall: TextStyle(
          fontFamily: AppFonts.regular,
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          textStyle: const TextStyle(fontFamily: AppFonts.semiBold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFFD32F2F); // Deep Red
  static const Color secondary = Color(0xFF1976D2); // Professional Blue
  static const Color accent = Color(0xFF00796B); // Deep Teal

  // Neutral colors
  static const Color background = Color(0xFFFAFAFA); // Off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color textPrimary = Color(0xFF212121); // Near black
  static const Color textSecondary = Color(0xFF757575); // Medium gray
  static const Color divider = Color(0xFFE0E0E0); // Light gray

  // Status colors
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFE0E0E0);
}

class AppFonts {
  static const String regular = 'ShipporiMincho-Regular';
  static const String medium = 'ShipporiMincho-Medium';
  static const String semiBold = 'ShipporiMincho-SemiBold';
  static const String bold = 'ShipporiMincho-Bold';
}

class AppTheme {
  static const TextTheme _baseTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontFamily: AppFonts.bold,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontFamily: AppFonts.bold,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontFamily: AppFonts.semiBold,
      color: AppColors.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 20,
      fontFamily: AppFonts.semiBold,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontFamily: AppFonts.medium,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontFamily: AppFonts.medium,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: AppFonts.regular,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontFamily: AppFonts.regular,
      color: AppColors.textPrimary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontFamily: AppFonts.medium,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.surface,
      onSecondary: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: _baseTextTheme,
    appBarTheme: AppBarTheme(
      color: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _baseTextTheme.headlineMedium?.copyWith(
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.surface,
        backgroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: AppFonts.medium,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(
        fontFamily: AppFonts.regular,
        color: AppColors.textSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: AppColors.surface,
      onSecondary: AppColors.surface,
      onSurface: AppColors.darkText,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: _baseTextTheme.apply(
      bodyColor: AppColors.darkText,
      displayColor: AppColors.darkText,
    ),
    appBarTheme: AppBarTheme(
      color: AppColors.darkSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _baseTextTheme.headlineMedium?.copyWith(
        color: AppColors.darkText,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        backgroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: AppFonts.medium,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      hintStyle: TextStyle(
        fontFamily: AppFonts.regular,
        color: AppColors.darkText.withOpacity(0.7),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.darkText.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.darkText.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';

/// A helper class that provides theme-aware colors to reduce redundancy
/// across widgets.
class ThemeHelper {
  /// Returns appropriate colors based on the current theme mode
  static ThemeColors of(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ThemeColors(isDarkMode);
  }

  /// Alternative approach using a boolean flag directly
  static ThemeColors fromDarkMode(bool isDarkMode) {
    return ThemeColors(isDarkMode);
  }
}

/// Container class for all theme-dependent colors
class ThemeColors {
  final bool isDarkMode;

  ThemeColors(this.isDarkMode);

  // Background colors
  Color get backgroundColor =>
      isDarkMode ? AppColors.backgroundDark : AppColors.background;

  // Card colors
  Color get cardColor => isDarkMode ? AppColors.surfaceDark : Colors.white;

  // Text colors
  Color get textPrimary => isDarkMode ? Colors.white : AppColors.textPrimary;
  Color get textSecondary =>
      isDarkMode ? Colors.white70 : AppColors.textSecondary;
  Color get textTertiary => isDarkMode ? Colors.white54 : Colors.black45;

  // Icon colors
  Color get iconPrimary => isDarkMode ? Colors.white70 : Colors.black54;
  Color get iconSecondary => isDarkMode ? Colors.white54 : Colors.black38;

  // Border colors
  Color get borderColor => isDarkMode
      ? Colors.white.withOpacity(0.24)
      : AppColors.primary.withOpacity(0.2);

  // Shadow colors
  Color get shadowColor => isDarkMode
      ? Colors.black.withOpacity(0.3)
      : Colors.black.withOpacity(0.1);

  // Bottom navigation colors
  Color get bottomNavBackground =>
      isDarkMode ? Colors.grey[900]! : Colors.white;

  // Header background
  Color get headerBackground => isDarkMode ? Colors.grey[900]! : Colors.white;

  // Search bar colors
  Color get searchBarBackground =>
      isDarkMode ? Colors.grey[800]! : Colors.white;
  Color get searchBarHint =>
      isDarkMode ? Colors.grey[400]! : AppColors.textSecondary;

  // Container backgrounds
  Color get containerLight =>
      isDarkMode ? Colors.grey[800]! : Colors.grey.shade100;

  // Filter card gradient colors
  List<Color> get filterGradient => isDarkMode
      ? [Colors.grey[700]!, Colors.grey[800]!]
      : [
          AppColors.primary.withOpacity(0.9),
          AppColors.primary.withOpacity(0.7)
        ];

  // Returns a color with dark/light variant based on a base color
  Color getVariant(Color baseColor,
      {double lightOpacity = 0.1, double darkOpacity = 0.15}) {
    if (isDarkMode) {
      return Color.fromARGB(
        (darkOpacity * 255).round(),
        baseColor.red,
        baseColor.green,
        baseColor.blue,
      );
    } else {
      return Color.fromARGB(
        (lightOpacity * 255).round(),
        baseColor.red,
        baseColor.green,
        baseColor.blue,
      );
    }
  }

  // Returns appropriate border color for a base color
  Color getBorderVariant(Color baseColor,
      {double lightOpacity = 0.3, double darkOpacity = 0.4}) {
    if (isDarkMode) {
      return Color.fromARGB(
        (darkOpacity * 255).round(),
        baseColor.red,
        baseColor.green,
        baseColor.blue,
      );
    } else {
      return Color.fromARGB(
        (lightOpacity * 255).round(),
        baseColor.red,
        baseColor.green,
        baseColor.blue,
      );
    }
  }
}

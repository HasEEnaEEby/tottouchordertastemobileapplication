import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFFC62828);
  static const Color primaryLight = Color(0xFFE57373);
  static const Color primaryDark = Color(0xFF8E0000);

  // Secondary Brand Colors
  static const Color secondary = Color(0xFF212121);
  static const Color secondaryLight = Color(0xFF424242);
  static const Color secondaryDark = Color(0xFF000000);

  // Accent and Backgrounds
  static const Color accent = Color(0xFFF8F8F8);
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFFF2F2F2);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Status Colors
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF0288D1);

  // Order Status Colors
  static const Color orderPending = primary;
  static const Color orderPreparing = secondaryLight;
  static const Color orderReady = Color(0xFF4CAF50);
  static const Color orderServed = Color(0xFF6A1B9A);
  static const Color orderCompleted = Color(0xFF78909C);
  static const Color orderCancelled = error;

  // Dividers and Borders
  static const Color divider = Color(0xFFDFDFDF);
  static const Color border = Color(0xFFBDBDBD);

  // Gradients for headers, buttons, etc.
  static const List<Color> primaryGradient = [
    primary,
    primaryLight,
  ];

  static const List<Color> secondaryGradient = [
    secondary,
    secondaryLight,
  ];

  // Shadows and Overlays
  static Color shadowColor = const Color(0xFF000000).withOpacity(0.1);
  static Color overlayColor = const Color(0xFF000000).withOpacity(0.5);

  // Special Purpose Colors
  static const Color vegetarianBadge = Color(0xFF66BB6A); // Green for veg items
  static const Color nonVegetarianBadge = error; // Red for non-veg
  static const Color spicyIndicator =
      Color(0xFFB71C1C); // Intense red for spicy
  static const Color popularDishBadge =
      Color(0xFFFFD700); // Gold for popular items

  // MaterialColor for primary swatch (useful for themes).
  static MaterialColor primarySwatch = MaterialColor(
    primary.value,
    <int, Color>{
      50: primary.withOpacity(0.1),
      100: primary.withOpacity(0.2),
      200: primary.withOpacity(0.3),
      300: primary.withOpacity(0.4),
      400: primary.withOpacity(0.5),
      500: primary.withOpacity(0.6),
      600: primary.withOpacity(0.7),
      700: primary.withOpacity(0.8),
      800: primary.withOpacity(0.9),
      900: primary,
    },
  );
}

// lib/core/config/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2A9D8F); // Teal - Main brand color
  static const Color primaryLight =
      Color(0xFF4DB6A9); // Light Teal - Secondary actions
  static const Color primaryDark =
      Color(0xFF1E7268); // Dark Teal - Pressed states

  // Secondary Colors
  static const Color secondary = Color(0xFFE76F51); // Coral - Accents and CTAs
  static const Color secondaryLight =
      Color(0xFFF4A261); // Light Coral - Highlights
  static const Color secondaryDark =
      Color(0xFFCC4E31); // Dark Coral - Pressed states

  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA); // Light Gray - Background
  static const Color surface = Color(0xFFFFFFFF); // White - Surface
  static const Color cardBackground =
      Color(0xFFFFFFFF); // White - Card Background

  // Text Colors
  static const Color textPrimary =
      Color(0xFF264653); // Dark Blue - Primary Text
  static const Color textSecondary =
      Color(0xFF546E7A); // Medium Gray - Secondary Text
  static const Color textHint = Color(0xFF90A4AE); // Light Gray - Hint Text

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green - Success
  static const Color error = Color(0xFFDC3545); // Red - Error
  static const Color warning = Color(0xFFFFC107); // Yellow - Warning
  static const Color info = Color(0xFF0288D1); // Blue - Information

  // Order Status Colors
  static const Color orderPending =
      Color(0xFFFFA726); // Orange - Pending Orders
  static const Color orderPreparing = Color(0xFF42A5F5); // Blue - Preparing
  static const Color orderReady = Color(0xFF66BB6A); // Green - Ready
  static const Color orderServed = Color(0xFF8E24AA); // Purple - Served
  static const Color orderCompleted = Color(0xFF78909C); // Gray - Completed
  static const Color orderCancelled = Color(0xFFEF5350); // Red - Cancelled

  // Dividers and Borders
  static const Color divider = Color(0xFFE0E0E0); // Light Gray - Dividers
  static const Color border = Color(0xFFBDBDBD); // Medium Gray - Borders

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF2A9D8F),
    Color(0xFF4DB6A9),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFE76F51),
    Color(0xFFF4A261),
  ];

  // Transparent Colors

  static Color shadowColor = const Color(0xFF000000).withOpacity(0.1);
  static Color overlayColor = const Color(0xFF000000).withOpacity(0.5);

  // Special Purpose Colors
  static const Color vegetarianBadge = Color(0xFF66BB6A); // Green for Veg Items
  static const Color nonVegetarianBadge = Color(0xFFEF5350); // Red for Non-Veg
  static const Color spicyIndicator = Color(0xFFFF5722); // Orange for Spicy
  static const Color popularDishBadge =
      Color(0xFFFFD700); // Gold for Popular Items

  // Method to get order status color
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return orderPending;
      case 'preparing':
        return orderPreparing;
      case 'ready':
        return orderReady;
      case 'served':
        return orderServed;
      case 'completed':
        return orderCompleted;
      case 'cancelled':
        return orderCancelled;
      default:
        return textSecondary;
    }
  }

  // Material Color for primary swatch
  static MaterialColor primarySwatch = MaterialColor(
    primary.value,
    <int, Color>{
      50: primary.withValues(alpha: 0.1),
      100: primary.withValues(alpha: 0.2),
      200: primary.withValues(alpha: 0.3),
      300: primary.withValues(alpha: 0.4),
      400: primary.withValues(alpha: 0.5),
      500: primary.withValues(alpha: 0.6),
      600: primary.withValues(alpha: 0.7),
      700: primary.withValues(alpha: 0.8),
      800: primary.withValues(alpha: 0.9),
      900: primary,
    },
  );
}

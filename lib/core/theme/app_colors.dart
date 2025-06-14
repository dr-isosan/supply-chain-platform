import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2E7D32); // Professional green
  static const Color primaryVariant = Color(0xFF1B5E20);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryVariant = Color(0xFF66BB6A);

  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF424242);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Utility colors
  static const Color outline = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color divider = Color(0xFFE0E0E0);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryVariant],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryVariant],
  );

  // Supply status colors
  static const Color pending = Color(0xFFFF9800);
  static const Color approved = Color(0xFF4CAF50);
  static const Color rejected = Color(0xFFF44336);
}

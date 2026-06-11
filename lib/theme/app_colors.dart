import 'package:flutter/material.dart';

/// Brand palette for Campus Fit.
///
/// A single seed colour (teal) drives the generated [ColorScheme]; the other
/// constants are used sparingly and meaningfully (coral for events / recovery,
/// the dark canvas from the design mockups, and a few fixed accents).
class AppColors {
  AppColors._();

  /// Primary brand / seed colour.
  static const Color brandTeal = Color(0xFF0F6E56);

  /// Secondary accent — events and recovery items.
  static const Color accentCoral = Color(0xFFD85A30);

  /// Dark canvas used throughout the onboarding mockups (#30302E).
  static const Color canvasDark = Color(0xFF30302E);

  /// Muted dot / inactive indicator colour from the mockups.
  static const Color mutedGrey = Color(0xFF9C9A92);

  /// Semantic colours reused across stats and badges.
  static const Color caloriesAmber = Color(0xFFE8A33D);
  static const Color distanceBlue = Color(0xFF3D7DE8);
  static const Color goldBadge = Color(0xFFE7B400);
}

import 'package:flutter/material.dart';

/// The night-sky palette. Every screen draws from these values so the app
/// keeps one mood.
abstract final class AppColors {
  /// Deep midnight blue behind everything.
  static const Color night = Color(0xFF070B1A);

  /// Cards and sheets, one step lighter than the sky.
  static const Color surface = Color(0xFF10162B);
  static const Color surfaceHigh = Color(0xFF1A2240);
  static const Color outline = Color(0xFF2B3456);

  /// Pale ivory moonlight, for the moon and primary text.
  static const Color moonlight = Color(0xFFEDE8DA);

  /// Warm gold for highlights such as full moons.
  static const Color gold = Color(0xFFD9B26F);

  /// Soft lavender for secondary accents such as new moons.
  static const Color lavender = Color(0xFF9AA5D6);

  /// Muted text.
  static const Color textSecondary = Color(0xFFA3A9C2);

  static const Color error = Color(0xFFE5867A);

  /// Gradient for the sky behind the moon, top to bottom.
  static const List<Color> skyGradient = [
    Color(0xFF0C1330),
    Color(0xFF070B1A),
    Color(0xFF04060F),
  ];
}

import 'package:flutter/material.dart';

/// Central color definitions for SMS Manager.
///
/// Uses Material 3 seed-based color scheme with category-specific accent
/// colors for card backgrounds and icons.
///
/// Usage:
/// ```dart
/// CircleAvatar(backgroundColor: AppColors.bank.withOpacity(0.15));
/// ```
abstract final class AppColors {
  // ── Seed color for Material 3 color generation ──
  static const Color seed = Color(0xFF1565C0); // Blue 800

  // ── Category-specific colors ──
  static const Color contacts = Color(0xFF43A047); // Green
  static const Color unknown = Color(0xFF757575); // Grey
  static const Color bank = Color(0xFF1E88E5); // Blue
  static const Color otp = Color(0xFFE53935); // Red
  static const Color promo = Color(0xFFFF9800); // Orange
  static const Color discount = Color(0xFF8E24AA); // Purple
  static const Color order = Color(0xFF00897B); // Teal
  static const Color bill = Color(0xFFFDD835); // Yellow
  static const Color travel = Color(0xFF039BE5); // Light Blue
  static const Color government = Color(0xFF546E7A); // Blue Grey
  static const Color operatorColor = Color(0xFF7CB342); // Light Green
  static const Color suspicious = Color(0xFFD32F2F); // Dark Red
  static const Color starred = Color(0xFFFFA000); // Amber
  static const Color pinned = Color(0xFF5C6BC0); // Indigo
  static const Color recent = Color(0xFF26A69A); // Teal light
}

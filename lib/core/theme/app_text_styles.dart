import 'package:flutter/material.dart';

/// Typography configuration using the Vazirmatn font family.
///
/// Provides a complete [TextTheme] with appropriate weights for each
/// Material 3 text style. Used by [AppTheme] to configure both
/// light and dark themes.
abstract final class AppTextStyles {
  /// The font family name matching the asset declaration in pubspec.yaml.
  static const String fontFamily = 'Vazirmatn';

  /// Complete Material 3 text theme with Vazirmatn font.
  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
        ),
      );
}

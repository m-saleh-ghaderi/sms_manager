import 'package:flutter/material.dart';

/// Single Source of Truth for Iranian bank brand colors used consistently
/// across Financial Insights, bank filter chips, balance breakdowns, and
/// Home → Bank message cards.
///
/// Every bank receives a strictly unique, soft, eye-friendly muted color.
abstract final class BankColors {
  static const Map<String, Color> _brandColors = {
    'بانک ملت': Color(0xFFD16060), // Soft Terracotta Red (~0°)
    'بانک سپه': Color(0xFFD48852), // Soft Apricot (~25°)
    'بانک ملی': Color(0xFFCFA04C), // Muted Warm Gold (~42°)
    'بانک کشاورزی': Color(0xFF5FA36A), // Soft Meadow Green (~130°)
    'بانک سامان': Color(0xFF4AA8A6), // Soft Sage Teal (~179°)
    'بلوبانک': Color(0xFF55B0E0), // Soft Sky Blue (~200°)
    'بانک تجارت': Color(0xFF506B9E), // Muted Deep Slate Blue (~219°)
    'بانک صادرات': Color(0xFF7B74C4), // Muted Iris Indigo (~245°)
    'ویپاد': Color(0xFFA06CB8), // Soft Plum Violet (~281°)
    'بانک پاسارگاد': Color(0xFFC96B8C), // Dusty Rose (~339°)
    'بانک مسکن': Color(0xFFCC7864), // Muted Clay Coral
    'بانک رفاه': Color(0xFF4E9A84), // Muted Seafoam
    'بانک پارسیان': Color(0xFF88A85B), // Soft Olive Sage
    'بانک شهر': Color(0xFF8C7366), // Warm Mocha Taupe
    'بانک آینده': Color(0xFFB3A354), // Soft Antique Olive
    'بانک اقتصاد نوین': Color(0xFFAD74AD), // Muted Mauve Orchid
    'بانک دی': Color(0xFF6B8594), // Cool Slate Blue-Grey
    'بانک سرمایه': Color(0xFF58A893), // Soft Mint Jade
    'بانک رسالت': Color(0xFF5EAAD1), // Soft Cerulean
    'بانک مهر ایران': Color(0xFF4F8E62), // Soft Pine Green
    'بانک کارآفرین': Color(0xFF707CB5), // Soft Periwinkle
    'بانک سینا': Color(0xFF579E9E), // Muted Dusty Cyan
    'بانک گردشگری': Color(0xFFC9935B), // Warm Sand Caramel
    'بانک ایران زمین': Color(0xFF8579B8), // Soft Iris Violet
    'پست بانک': Color(0xFF759B5C), // Soft Moss Green
    'بانک توسعه تعاون': Color(0xFF4D89A8), // Muted Denim Blue
    'بانک خاورمیانه': Color(0xFFA67C6D), // Muted Dusty Copper
    'بانک صنعت و معدن': Color(0xFF667C89), // Soft Pewter Blue
    'بانک انصار': Color(0xFF5C947C), // Muted Eucalyptus
    'بانک حکمت': Color(0xFF916E66), // Muted Cocoa
    'بانکینو': Color(0xFFC96F9E), // Soft Dusty Pink
  };

  static final Map<String, Color> _dynamicAssignments = {};
  static final Set<int> _usedColorValues = {
    for (final c in _brandColors.values) c.toARGB32(),
  };

  /// Returns a strictly unique, soft brand color for [bankName] across all screens.
  static Color colorFor(String? bankName) {
    final trimmed = bankName?.trim() ?? '';
    if (trimmed.isEmpty) {
      return const Color(0xFF5682B5);
    }

    final exact = _brandColors[trimmed];
    if (exact != null) return exact;

    final cached = _dynamicAssignments[trimmed];
    if (cached != null) return cached;

    // Generate a unique, gentle muted color using golden-angle hue spacing.
    var seedHash = 0;
    for (final codeUnit in trimmed.codeUnits) {
      seedHash = (seedHash * 31 + codeUnit) & 0x7FFFFFFF;
    }

    const goldenAngle = 137.508;
    var attempt = 0;
    late Color candidate;
    do {
      final hue = ((seedHash + attempt * goldenAngle) % 360.0);
      final saturation = attempt.isEven ? 0.44 : 0.36;
      final lightness = attempt % 3 == 0 ? 0.56 : 0.61;
      candidate = HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
      attempt++;
    } while (_usedColorValues.contains(candidate.toARGB32()) && attempt < 200);

    _usedColorValues.add(candidate.toARGB32());
    _dynamicAssignments[trimmed] = candidate;
    return candidate;
  }

  /// Adjusts [brandColor] for calm, legible text/icons on light or dark card surfaces.
  static Color readableAccent(Color brandColor, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return Color.lerp(brandColor, Colors.white, 0.20) ?? brandColor;
    }
    return Color.lerp(brandColor, Colors.black, 0.25) ?? brandColor;
  }

  /// Builds a soft, eye-friendly tinted card surface in light & dark themes.
  static Color cardTint(ThemeData theme, Color brandColor) {
    final isDark = theme.brightness == Brightness.dark;
    return Color.alphaBlend(
      brandColor.withValues(alpha: isDark ? 0.10 : 0.055),
      theme.colorScheme.surfaceContainerLow,
    );
  }
}

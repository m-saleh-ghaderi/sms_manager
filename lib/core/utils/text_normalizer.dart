/// Utilities for normalizing Persian/Arabic SMS text before classification.
///
/// Handles Arabic ↔ Persian character unification, digit conversion,
/// ZWNJ removal, and whitespace collapsing — critical for reliable
/// keyword matching in Iranian SMS messages.
library;

/// Converts Arabic/Persian digits (۰-۹ and ٠-٩) to ASCII 0-9.
String normalizeDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x06F0 && rune <= 0x06F9) {
      // Persian digits ۰-۹
      buffer.writeCharCode(0x30 + (rune - 0x06F0));
    } else if (rune >= 0x0660 && rune <= 0x0669) {
      // Arabic-Indic digits ٠-٩
      buffer.writeCharCode(0x30 + (rune - 0x0660));
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// Normalizes Arabic ي and ك to Persian ی and ک.
String unifyArabicPersian(String input) {
  return input
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll('ة', 'ه')
      .replaceAll('ؤ', 'و')
      .replaceAll('إ', 'ا')
      .replaceAll('أ', 'ا')
      .replaceAll('آ', 'ا');
}

/// Full text normalization pipeline for SMS classification.
///
/// 1. Persian/Arabic digit → ASCII digit
/// 2. Arabic letter unification (ي→ی, ك→ک, etc.)
/// 3. ZWNJ (‌) removal
/// 4. Lowercase for Latin characters
/// 5. Whitespace collapsing
String normalizeText(String raw) {
  var text = normalizeDigits(raw);
  text = unifyArabicPersian(text);
  // Remove Zero-Width Non-Joiner (U+200C)
  text = text.replaceAll('\u200C', '');
  text = text.toLowerCase();
  // Collapse multiple whitespace
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text;
}

/// Strips all non-digit characters and returns the numeric string.
String extractDigitsOnly(String input) {
  return normalizeDigits(input).replaceAll(RegExp(r'[^0-9]'), '');
}

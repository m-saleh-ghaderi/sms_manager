import 'package:intl/intl.dart';

/// Display unit for Iranian bank amounts (stored internally as Rials).
enum CurrencyUnit {
  toman,
  rial,
}

/// Formats Iranian financial amounts stored in Rials into Toman or Rial strings.
abstract final class CurrencyFormatter {
  static final NumberFormat _decimalFormat = NumberFormat('#,##0', 'en_US');

  /// Converts [amountRial] to the requested [unit].
  static int convertFromRial(int amountRial, CurrencyUnit unit) {
    return unit == CurrencyUnit.toman ? amountRial ~/ 10 : amountRial;
  }

  /// Unit label in Persian.
  static String unitLabel(CurrencyUnit unit) {
    return unit == CurrencyUnit.toman ? 'تومان' : 'ریال';
  }

  /// Formats [amountRial] with thousand separators and optional Persian unit suffix.
  static String format(
    int amountRial,
    CurrencyUnit unit, {
    bool includeUnit = true,
  }) {
    final value = convertFromRial(amountRial.abs(), unit);
    final formatted = _decimalFormat.format(value);
    final sign = amountRial < 0 ? '-' : '';
    if (!includeUnit) return '$sign$formatted';
    return '$sign$formatted ${unitLabel(unit)}';
  }

  /// Compact axis/chart label (e.g. `۲.۵ م` or `۴۵۰ ه`).
  static String formatCompact(int amountRial, CurrencyUnit unit) {
    final value = convertFromRial(amountRial.abs(), unit);
    if (value == 0) return '0';
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} م.د';
    }
    if (value >= 1000000) {
      final millions = value / 1000000;
      final text = millions >= 10
          ? millions.toStringAsFixed(0)
          : millions.toStringAsFixed(1);
      return '${text.replaceAll(RegExp(r'\.0$'), '')} م';
    }
    if (value >= 1000) {
      return '${(value / 1000).round()} ه';
    }
    return '$value';
  }
}

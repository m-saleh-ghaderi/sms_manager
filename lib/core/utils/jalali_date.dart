import 'package:flutter/foundation.dart';

/// Pure Dart Jalali (Persian/Shamsi) calendar helper with exact bidirectional
/// Gregorian conversion, leap-year handling, and month arithmetic.
@immutable
class JalaliDate implements Comparable<JalaliDate> {
  const JalaliDate(this.year, [this.month = 1, this.day = 1]);

  final int year;
  final int month;
  final int day;

  static const List<String> monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const List<String> shortWeekdayNames = [
    'ش',
    'ی',
    'د',
    'س',
    'چ',
    'پ',
    'ج',
  ];

  /// Converts a Gregorian [DateTime] into its local [JalaliDate].
  factory JalaliDate.fromDateTime(DateTime dateTime) {
    final gy = dateTime.year;
    final gm = dateTime.month;
    final gd = dateTime.day;

    const gdm = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    final gy2 = gm > 2 ? gy + 1 : gy;
    var days = 355666 +
        (365 * gy) +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) +
        gd +
        gdm[gm - 1];

    var jy = -1595 + (33 * (days ~/ 12053));
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }

    final int jm;
    final int jd;
    if (days < 186) {
      jm = 1 + (days ~/ 31);
      jd = 1 + (days % 31);
    } else {
      jm = 7 + ((days - 186) ~/ 30);
      jd = 1 + ((days - 186) % 30);
    }
    return JalaliDate(jy, jm, jd);
  }

  /// Converts this [JalaliDate] to a local Gregorian [DateTime].
  DateTime toDateTime({
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
  }) {
    var jy = year + 1595;
    var days = -355668 +
        (365 * jy) +
        ((jy ~/ 33) * 8) +
        (((jy % 33) + 3) ~/ 4) +
        day +
        (month < 7 ? (month - 1) * 31 : ((month - 7) * 30) + 186);

    var gy = 400 * (days ~/ 146097);
    days %= 146097;
    if (days > 36524) {
      gy += 100 * (--days ~/ 36524);
      days %= 36524;
      if (days >= 365) days++;
    }
    gy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      gy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }

    var gd = days + 1;
    final salA = [
      0,
      31,
      ((gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0)) ? 29 : 28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];
    var gm = 0;
    while (gm < 13 && gd > salA[gm]) {
      gd -= salA[gm];
      gm++;
    }
    return DateTime(gy, gm, gd, hour, minute, second, millisecond);
  }

  /// Returns `true` if [year] is a Jalali leap year (33-year cycle).
  static bool isLeapYear(int year) {
    final mod = (year + 1595) % 33;
    return mod == 1 ||
        mod == 5 ||
        mod == 9 ||
        mod == 13 ||
        mod == 17 ||
        mod == 22 ||
        mod == 26 ||
        mod == 30;
  }

  /// Returns the number of days in [month] of [year].
  static int daysInMonth(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return isLeapYear(year) ? 30 : 29;
  }

  /// Day of week aligned to Saturday = 0 .. Friday = 6.
  int get persianWeekday => (toDateTime().weekday + 1) % 7;

  String get monthName => monthNames[(month - 1).clamp(0, 11)];

  JalaliDate get startOfMonth => JalaliDate(year, month, 1);

  JalaliDate get endOfMonth => JalaliDate(year, month, daysInMonth(year, month));

  /// Shifts this date by [deltaMonths], clamping the day to the target month length.
  JalaliDate addMonths(int deltaMonths) {
    final totalMonths = (year * 12) + (month - 1) + deltaMonths;
    final targetYear = totalMonths ~/ 12;
    final targetMonth = (totalMonths % 12) + 1;
    final maxDay = daysInMonth(targetYear, targetMonth);
    return JalaliDate(targetYear, targetMonth, day.clamp(1, maxDay));
  }

  String formatNumeric() {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year/$m/$d';
  }

  String formatWithMonthName() => '$day $monthName $year';

  String formatMonthYear() => '$monthName $year';

  @override
  int compareTo(JalaliDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  bool operator <(JalaliDate other) => compareTo(other) < 0;
  bool operator <=(JalaliDate other) => compareTo(other) <= 0;
  bool operator >(JalaliDate other) => compareTo(other) > 0;
  bool operator >=(JalaliDate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JalaliDate &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => formatNumeric();
}

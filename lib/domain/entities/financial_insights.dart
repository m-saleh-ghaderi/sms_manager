import 'package:flutter/foundation.dart';

import '../../core/utils/jalali_date.dart';
import 'message_entity.dart';

/// Preset and custom time filters for the Financial Insights screen.
enum InsightsTimeFilter {
  currentMonth('ماه جاری'),
  last3Months('۳ ماه اخیر'),
  last6Months('۶ ماه اخیر'),
  lastYear('یک سال اخیر'),
  custom('بازه دلخواه');

  const InsightsTimeFilter(this.label);
  final String label;
}

/// Optional filter for transaction list direction.
enum InsightsTxFilter {
  all('همه'),
  credit('واریز'),
  debit('برداشت');

  const InsightsTxFilter(this.label);
  final String label;
}

/// Inclusive Shamsi-aligned date range used for DB querying & chart bucketing.
@immutable
class InsightsDateRange {
  const InsightsDateRange({
    required this.start,
    required this.end,
    required this.startJalali,
    required this.endJalali,
  });

  final DateTime start;
  final DateTime end;
  final JalaliDate startJalali;
  final JalaliDate endJalali;

  /// Builds a Shamsi calendar range for [filter], or falls back to [customStart]..[customEnd].
  factory InsightsDateRange.fromFilter(
    InsightsTimeFilter filter, {
    DateTime? now,
    JalaliDate? customStart,
    JalaliDate? customEnd,
  }) {
    final reference = now ?? DateTime.now();
    final today = JalaliDate.fromDateTime(reference);

    switch (filter) {
      case InsightsTimeFilter.currentMonth:
        final startJ = today.startOfMonth;
        final endJ = today.endOfMonth;
        return InsightsDateRange._fromJalali(startJ, endJ);
      case InsightsTimeFilter.last3Months:
        final startJ = today.startOfMonth.addMonths(-2);
        final endJ = today.endOfMonth;
        return InsightsDateRange._fromJalali(startJ, endJ);
      case InsightsTimeFilter.last6Months:
        final startJ = today.startOfMonth.addMonths(-5);
        final endJ = today.endOfMonth;
        return InsightsDateRange._fromJalali(startJ, endJ);
      case InsightsTimeFilter.lastYear:
        final startJ = today.startOfMonth.addMonths(-11);
        final endJ = today.endOfMonth;
        return InsightsDateRange._fromJalali(startJ, endJ);
      case InsightsTimeFilter.custom:
        final s = customStart ?? today.startOfMonth;
        final e = customEnd ?? today;
        final orderedStart = s <= e ? s : e;
        final orderedEnd = s <= e ? e : s;
        return InsightsDateRange._fromJalali(orderedStart, orderedEnd);
    }
  }

  factory InsightsDateRange._fromJalali(JalaliDate startJ, JalaliDate endJ) {
    return InsightsDateRange(
      start: startJ.toDateTime(hour: 0, minute: 0, second: 0, millisecond: 0),
      end: endJ.toDateTime(hour: 23, minute: 59, second: 59, millisecond: 999),
      startJalali: startJ,
      endJalali: endJ,
    );
  }
}

/// Aggregated cash flow totals for a single Shamsi month.
@immutable
class MonthlyCashFlow {
  const MonthlyCashFlow({
    required this.year,
    required this.month,
    required this.monthName,
    required this.creditRial,
    required this.debitRial,
    required this.transactionCount,
  });

  final int year;
  final int month;
  final String monthName;
  final int creditRial;
  final int debitRial;
  final int transactionCount;

  int get netRial => creditRial - debitRial;
}

/// Complete aggregated financial summary and filtered transaction list.
@immutable
class FinancialInsightsSummary {
  const FinancialInsightsSummary({
    required this.totalCreditRial,
    required this.totalDebitRial,
    required this.transactionCount,
    required this.monthlyBreakdown,
    required this.transactions,
  });

  final int totalCreditRial;
  final int totalDebitRial;
  final int transactionCount;
  final List<MonthlyCashFlow> monthlyBreakdown;
  final List<MessageEntity> transactions;

  int get netRial => totalCreditRial - totalDebitRial;
}

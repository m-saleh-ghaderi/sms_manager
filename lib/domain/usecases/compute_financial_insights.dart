import '../../core/utils/jalali_date.dart';
import '../entities/financial_insights.dart';
import '../entities/message_entity.dart';

/// Pure domain service aggregating bank SMS messages into monthly Shamsi buckets
/// and financial totals.
class ComputeFinancialInsights {
  const ComputeFinancialInsights();

  FinancialInsightsSummary compute(
    List<MessageEntity> bankMessages, {
    required InsightsDateRange range,
  }) {
    var totalCredit = 0;
    var totalDebit = 0;
    var txCount = 0;

    final buckets = <String, _MutableMonthBucket>{};

    // Pre-populate every Shamsi month in the range so empty months stay visible.
    var cursor = range.startJalali.startOfMonth;
    final endMonth = range.endJalali.startOfMonth;
    while (cursor <= endMonth) {
      final key = _monthKey(cursor.year, cursor.month);
      buckets[key] = _MutableMonthBucket(
        year: cursor.year,
        month: cursor.month,
        monthName: cursor.monthName,
      );
      cursor = cursor.addMonths(1);
    }

    for (final msg in bankMessages) {
      final amount = msg.amountRial ?? 0;
      if (amount > 0 && msg.txType != null) {
        txCount++;
        final jDate = JalaliDate.fromDateTime(msg.date);
        final key = _monthKey(jDate.year, jDate.month);
        final bucket = buckets.putIfAbsent(
          key,
          () => _MutableMonthBucket(
            year: jDate.year,
            month: jDate.month,
            monthName: jDate.monthName,
          ),
        );

        bucket.count++;
        if (msg.txType == TransactionType.credit) {
          totalCredit += amount;
          bucket.creditRial += amount;
        } else if (msg.txType == TransactionType.debit) {
          totalDebit += amount;
          bucket.debitRial += amount;
        }
      }
    }

    final sortedBuckets = buckets.values.toList()
      ..sort((a, b) {
        final yearCmp = a.year.compareTo(b.year);
        return yearCmp != 0 ? yearCmp : a.month.compareTo(b.month);
      });

    return FinancialInsightsSummary(
      totalCreditRial: totalCredit,
      totalDebitRial: totalDebit,
      transactionCount: txCount,
      monthlyBreakdown: sortedBuckets
          .map(
            (b) => MonthlyCashFlow(
              year: b.year,
              month: b.month,
              monthName: b.monthName,
              creditRial: b.creditRial,
              debitRial: b.debitRial,
              transactionCount: b.count,
            ),
          )
          .toList(),
      transactions: bankMessages,
    );
  }

  String _monthKey(int year, int month) => '$year-${month.toString().padLeft(2, '0')}';
}

class _MutableMonthBucket {
  _MutableMonthBucket({
    required this.year,
    required this.month,
    required this.monthName,
  });

  final int year;
  final int month;
  final String monthName;
  int creditRial = 0;
  int debitRial = 0;
  int count = 0;
}

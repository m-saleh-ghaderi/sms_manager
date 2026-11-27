import '../classifier/bank_identifier.dart';
import '../entities/financial_insights.dart';
import '../entities/message_entity.dart';

/// Pure domain calculator computing the latest balance per `(bankName, cardTail)`
/// and overall bank/portfolio totals from persisted bank SMS messages.
class ComputeBankBalances {
  const ComputeBankBalances();

  PortfolioBalanceSummary compute(List<MessageEntity> balanceMessages) {
    if (balanceMessages.isEmpty) {
      return const PortfolioBalanceSummary(
        totalBalanceRial: 0,
        banks: [],
      );
    }

    // Input is expected sorted by date DESC (fallback defensive sort by date DESC, smsId DESC).
    final sorted = [...balanceMessages]
      ..sort((a, b) {
        final dateCmp = b.date.compareTo(a.date);
        return dateCmp != 0 ? dateCmp : b.smsId.compareTo(a.smsId);
      });

    final bankCards = <String, Map<String, BankCardBalance>>{};

    for (final msg in sorted) {
      final balance = msg.balanceRial;
      if (balance == null) continue;

      final bank = msg.bankName?.trim().isNotEmpty == true
          ? msg.bankName!.trim()
          : BankIdentifier.resolveBankName(
              rawBody: msg.body,
              rawAddress: msg.address,
            );
      final cardKey = msg.cardTail ?? '_default';

      final cardsMap = bankCards.putIfAbsent(bank, () => {});
      cardsMap.putIfAbsent(
        cardKey,
        () => BankCardBalance(
          cardTail: msg.cardTail,
          balanceRial: balance,
          updatedAt: msg.date,
        ),
      );
    }

    if (bankCards.isEmpty) {
      return const PortfolioBalanceSummary(
        totalBalanceRial: 0,
        banks: [],
      );
    }

    final bankSummaries = <BankBalanceSummary>[];
    var grandTotal = 0;
    DateTime? latestOverall;

    for (final entry in bankCards.entries) {
      final cards = entry.value.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      final bankTotal = cards.fold<int>(0, (sum, c) => sum + c.balanceRial);
      final bankUpdated = cards.first.updatedAt;
      grandTotal += bankTotal;
      if (latestOverall == null || bankUpdated.isAfter(latestOverall)) {
        latestOverall = bankUpdated;
      }

      bankSummaries.add(
        BankBalanceSummary(
          bankName: entry.key,
          totalBalanceRial: bankTotal,
          latestUpdate: bankUpdated,
          cards: cards,
        ),
      );
    }

    bankSummaries.sort((a, b) => b.latestUpdate.compareTo(a.latestUpdate));

    return PortfolioBalanceSummary(
      totalBalanceRial: grandTotal,
      banks: bankSummaries,
      latestUpdate: latestOverall,
    );
  }
}

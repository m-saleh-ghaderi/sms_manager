import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/jalali_date.dart';
import '../../../../domain/entities/financial_insights.dart';

/// Displays either the combined portfolio balance ("همه بانک‌ها") or the
/// selected bank's latest balance along with per-card breakdown pills.
class BankBalanceCard extends StatelessWidget {
  const BankBalanceCard({
    super.key,
    required this.portfolio,
    required this.unit,
    required this.onUnitChanged,
    this.selectedBank,
  });

  final PortfolioBalanceSummary portfolio;
  final CurrencyUnit unit;
  final ValueChanged<CurrencyUnit> onUnitChanged;
  final String? selectedBank;

  String _formatDateTime(DateTime dt) {
    final j = JalaliDate.fromDateTime(dt);
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${j.formatNumeric()} • $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSingleBank = selectedBank != null;

    BankBalanceSummary? singleBankSummary;
    if (isSingleBank) {
      for (final b in portfolio.banks) {
        if (b.bankName == selectedBank) {
          singleBankSummary = b;
          break;
        }
      }
    }

    final hasData = isSingleBank
        ? singleBankSummary != null
        : portfolio.hasAnyBalance;
    final displayBalanceRial = isSingleBank
        ? (singleBankSummary?.totalBalanceRial ?? 0)
        : portfolio.totalBalanceRial;
    final latestUpdate = isSingleBank
        ? singleBankSummary?.latestUpdate
        : portfolio.latestUpdate;

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row + Currency Unit Switcher
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 20,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isSingleBank
                              ? 'موجودی مانده • $selectedBank'
                              : 'مجموع کل موجودی بانک‌ها',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CurrencyUnitToggle(
                  unit: unit,
                  onUnitChanged: onUnitChanged,
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (!hasData)
              Text(
                isSingleBank
                    ? 'هنوز پیامکی با عدد «مانده» یا «موجودی» برای $selectedBank ثبت نشده است.'
                    : 'هنوز پیامکی با عدد «مانده» یا «موجودی» در دیتابیس ثبت نشده است.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              Text(
                CurrencyFormatter.format(displayBalanceRial, unit),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!isSingleBank)
                    Text(
                      'مجموع ${portfolio.banks.length} بانک دارای مانده',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer
                            .withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (latestUpdate != null)
                    Text(
                      'آخرین به‌روزرسانی: ${_formatDateTime(latestUpdate)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),

              // Show per-card balances when inspecting a single bank with card tails
              if (isSingleBank &&
                  singleBankSummary != null &&
                  (singleBankSummary.cards.length > 1 ||
                      singleBankSummary.cards.first.cardTail != null)) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: singleBankSummary.cards.map((card) {
                    final cardLabel = card.cardTail != null
                        ? 'کارت ${card.cardTail}'
                        : 'سایر حساب‌ها';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$cardLabel:',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            CurrencyFormatter.format(card.balanceRial, unit),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Shared Toman / Rial segmented pill toggle.
class CurrencyUnitToggle extends StatelessWidget {
  const CurrencyUnitToggle({
    super.key,
    required this.unit,
    required this.onUnitChanged,
  });

  final CurrencyUnit unit;
  final ValueChanged<CurrencyUnit> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UnitPill(
            label: 'تومان',
            selected: unit == CurrencyUnit.toman,
            onTap: () => onUnitChanged(CurrencyUnit.toman),
          ),
          _UnitPill(
            label: 'ریال',
            selected: unit == CurrencyUnit.rial,
            onTap: () => onUnitChanged(CurrencyUnit.rial),
          ),
        ],
      ),
    );
  }
}

class _UnitPill extends StatelessWidget {
  const _UnitPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/jalali_date.dart';
import '../../../../domain/entities/message_entity.dart';

/// Card displaying a single persisted bank SMS transaction with Shamsi timestamp,
/// credit/debit icon badge, formatted amount, and SIM indicator.
class BankTransactionTile extends StatelessWidget {
  const BankTransactionTile({
    super.key,
    required this.message,
    required this.unit,
    this.onTap,
  });

  final MessageEntity message;
  final CurrencyUnit unit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = message.txType == TransactionType.credit;
    final isDebit = message.txType == TransactionType.debit;

    final accentColor = isCredit
        ? AppColors.contacts
        : isDebit
            ? AppColors.otp
            : AppColors.bank;

    final leadingIcon = isCredit
        ? Icons.arrow_downward_rounded
        : isDebit
            ? Icons.arrow_upward_rounded
            : Icons.account_balance_rounded;

    final jDate = JalaliDate.fromDateTime(message.date);
    final hh = message.date.hour.toString().padLeft(2, '0');
    final mm = message.date.minute.toString().padLeft(2, '0');
    final dateLabel = '${jDate.formatNumeric()} • $hh:$mm';

    final amountRial = message.amountRial;
    final formattedValue = amountRial != null && amountRial > 0
        ? CurrencyFormatter.format(amountRial, unit, includeUnit: false)
        : null;
    final unitText = CurrencyFormatter.unitLabel(unit);
    final amountText = formattedValue != null
        ? '${isCredit ? '\u200E+' : isDebit ? '\u200E-' : ''}$formattedValue $unitText'
        : 'اطلاع‌رسانی بانکی';

    final displayBankTitle = message.bankName?.trim().isNotEmpty == true
        ? message.bankName!.trim()
        : (message.address.isEmpty ? 'بانک ناشناس' : message.address);
    final cardSuffix =
        message.cardTail != null ? ' • کارت ${message.cardTail}' : '';
    final balanceText = message.balanceRial != null
        ? 'مانده: ${CurrencyFormatter.format(message.balanceRial!, unit)}'
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: accentColor.withValues(alpha: 0.14),
                child: Icon(leadingIcon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$displayBankTitle$cardSuffix',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (message.simSlot != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'سیم ${message.simSlot}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message.body.replaceAll(RegExp(r'\s+'), ' ').trim(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          dateLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 11,
                          ),
                        ),
                        if (balanceText != null)
                          Text(
                            balanceText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: amountRial != null && amountRial > 0
                          ? accentColor
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

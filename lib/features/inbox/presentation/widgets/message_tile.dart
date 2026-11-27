import 'package:flutter/material.dart';

import '../../../../core/theme/bank_colors.dart';
import '../../../../core/widgets/bank_filter_strip.dart';
import '../../../../domain/entities/message_entity.dart';

/// Shared list tile displaying a persisted [MessageEntity].
///
/// Supports unread indicator, dual-SIM badge, pin/star state toggles,
/// consistent per-bank branding colors for bank SMS, and tap-to-open detail sheet.
class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
    this.onTap,
    this.onToggleStar,
    this.onTogglePin,
  });

  final MessageEntity message;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStar;
  final VoidCallback? onTogglePin;

  static String formatDateTime(DateTime dt) {
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$year/$month/$day  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBankSms = message.primaryCategory == 'bank';
    final resolvedBankName = isBankSms
        ? (message.bankName?.trim().isNotEmpty == true
            ? message.bankName!.trim()
            : message.address.trim())
        : null;
    final bankColor =
        isBankSms ? BankColors.colorFor(resolvedBankName) : null;

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Unread indicator, Sender, SIM Badge, Time
          Row(
            children: [
              if (!message.isRead) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (message.isPinned) ...[
                Icon(
                  Icons.push_pin_rounded,
                  size: 15,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  message.address.isEmpty ? 'نامشخص' : message.address,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight:
                        message.isRead ? FontWeight.w600 : FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (message.simSlot != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: message.simSlot == 1
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'سیم ${message.simSlot}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: message.simSlot == 1
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                formatDateTime(message.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          if (resolvedBankName != null && resolvedBankName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                BankNameBadge(bankName: resolvedBankName),
                if (message.cardTail != null)
                  Text(
                    'کارت ${message.cardTail}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 8),

          // Message Body
          Text(
            message.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: message.isRead
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          // Action Row: Star & Pin toggles
          if (onToggleStar != null || onTogglePin != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onTogglePin != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip:
                        message.isPinned ? 'برداشتن پین' : 'پین کردن پیام',
                    onPressed: onTogglePin,
                    icon: Icon(
                      message.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      size: 18,
                      color: message.isPinned
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.outline,
                    ),
                  ),
                if (onToggleStar != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip:
                        message.isStarred ? 'حذف نشان' : 'نشان‌دار کردن',
                    onPressed: onToggleStar,
                    icon: Icon(
                      message.isStarred
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 20,
                      color: message.isStarred
                          ? Colors.amber.shade700
                          : theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    final neutralBorderColor = message.isPinned
        ? theme.colorScheme.secondary.withValues(alpha: 0.55)
        : message.isRead
            ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
            : theme.colorScheme.primary.withValues(alpha: 0.4);
    final neutralBorderWidth =
        message.isPinned || !message.isRead ? 1.2 : 0.5;

    if (bankColor != null) {
      return BankAccentCard(
        bankColor: bankColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        borderRadius: 14,
        elevation: message.isRead ? 0.5 : 2,
        borderColor: neutralBorderColor,
        borderWidth: neutralBorderWidth,
        onTap: onTap,
        child: content,
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: message.isRead ? 0.5 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: neutralBorderColor,
          width: neutralBorderWidth,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

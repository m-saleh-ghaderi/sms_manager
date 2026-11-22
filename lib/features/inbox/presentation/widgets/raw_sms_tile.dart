import 'package:flutter/material.dart';

import '../../../../domain/entities/sms_entity.dart';

/// Individual list tile displaying a raw SMS message from the device inbox.
///
/// Follows Single Responsibility Principle (SRP):
/// Renders an SMS message with its sender, timestamp, dual-SIM badge, and body.
class RawSmsTile extends StatelessWidget {
  const RawSmsTile({
    super.key,
    required this.message,
    this.onTap,
  });

  final SmsEntity message;
  final VoidCallback? onTap;

  String _formatDateTime(DateTime dt) {
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: message.isRead ? 0.5 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: message.isRead
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.4),
          width: message.isRead ? 0.5 : 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Sender Address, SIM Badge, and Time
              Row(
                children: [
                  // Unread dot indicator
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

                  // Sender address
                  Expanded(
                    child: Text(
                      message.address.isEmpty ? 'نامشخص' : message.address,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: message.isRead ? FontWeight.w600 : FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // SIM Card Badge
                  if (message.simSlot != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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

                  // Timestamp
                  Text(
                    _formatDateTime(message.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}

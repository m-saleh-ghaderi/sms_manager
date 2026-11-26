import 'package:flutter/material.dart';

import '../../../../domain/entities/message_entity.dart';
import '../../../../domain/repositories/message_repository.dart';

/// Opens a draggable bottom sheet displaying full SMS details and user actions.
Future<void> showMessageDetailSheet({
  required BuildContext context,
  required MessageEntity message,
  required IMessageRepository repository,
}) {
  if (!message.isRead) {
    repository.markAsRead(message.smsId);
  }

  var isStarred = message.isStarred;
  var isPinned = message.isPinned;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) => Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'فرستنده: ${message.address.isEmpty ? 'نامشخص' : message.address}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (message.simSlot != null)
                      Chip(
                        label: Text('سیم‌کارت ${message.simSlot}'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'تاریخ دریافت: ${message.date.year}/${message.date.month}/${message.date.day} ساعت ${message.date.hour.toString().padLeft(2, '0')}:${message.date.minute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      avatar: Icon(
                        isStarred
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 18,
                        color: isStarred ? Colors.amber.shade700 : null,
                      ),
                      label: Text(isStarred ? 'نشان‌دار شده' : 'نشان‌دار کردن'),
                      onPressed: () async {
                        final next = !isStarred;
                        await repository.toggleStarred(message.smsId, next);
                        if (!ctx.mounted) return;
                        setSheetState(() => isStarred = next);
                      },
                    ),
                    ActionChip(
                      avatar: Icon(
                        isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        size: 18,
                        color: isPinned ? theme.colorScheme.secondary : null,
                      ),
                      label: Text(isPinned ? 'پین شده' : 'پین کردن'),
                      onPressed: () async {
                        final next = !isPinned;
                        await repository.togglePinned(message.smsId, next);
                        if (!ctx.mounted) return;
                        setSheetState(() => isPinned = next);
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),
                SelectableText(
                  message.body,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

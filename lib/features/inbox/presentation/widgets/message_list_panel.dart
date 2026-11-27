import 'package:flutter/material.dart';

import '../../../../domain/entities/message_entity.dart';
import '../../../../domain/repositories/message_repository.dart';
import 'message_detail_sheet.dart';
import 'message_tile.dart';

/// Shared searchable, SIM-filterable, DB-backed message list widget.
///
/// Reused by both [RawInboxPage] and [CategoryPage] so filtering, empty states,
/// and star/pin actions share a single implementation.
class MessageListPanel extends StatefulWidget {
  const MessageListPanel({
    super.key,
    required this.repository,
    required this.streamFactory,
    this.initialSimFilter,
    this.emptyTitle = 'هیچ پیامی یافت نشد',
    this.emptySubtitle = 'در این بخش پیامی ثبت نشده است.',
    this.onRetry,
    this.onSimChanged,
    this.extraFilterBar,
  });

  final IMessageRepository repository;
  final Stream<List<MessageEntity>> Function(
    int? simFilter,
    String searchQuery,
  ) streamFactory;
  final int? initialSimFilter;
  final String emptyTitle;
  final String emptySubtitle;
  final VoidCallback? onRetry;
  final ValueChanged<int?>? onSimChanged;
  final Widget? extraFilterBar;

  @override
  State<MessageListPanel> createState() => _MessageListPanelState();
}

class _MessageListPanelState extends State<MessageListPanel> {
  late int? _simFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _simFilter = widget.initialSimFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stream = widget.streamFactory(_simFilter, _searchQuery);

    return StreamBuilder<List<MessageEntity>>(
      stream: stream,
      builder: (context, snapshot) {
        final messages = snapshot.data ?? const <MessageEntity>[];

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'جستجو در پیام‌ها یا شماره فرستنده...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
            ),

            // SIM Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('همه پیام‌ها'),
                    selected: _simFilter == null,
                    onSelected: (_) {
                      setState(() => _simFilter = null);
                      widget.onSimChanged?.call(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: const Icon(Icons.sim_card_outlined, size: 16),
                    label: const Text('سیم‌کارت ۱'),
                    selected: _simFilter == 1,
                    onSelected: (_) {
                      setState(() => _simFilter = 1);
                      widget.onSimChanged?.call(1);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    avatar: const Icon(Icons.sim_card_outlined, size: 16),
                    label: const Text('سیم‌کارت ۲'),
                    selected: _simFilter == 2,
                    onSelected: (_) {
                      setState(() => _simFilter = 2);
                      widget.onSimChanged?.call(2);
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${messages.length} پیام',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (widget.extraFilterBar != null) widget.extraFilterBar!,

            const Divider(height: 1),

            // Message List
            Expanded(
              child: _buildListState(theme, snapshot, messages),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListState(
    ThemeData theme,
    AsyncSnapshot<List<MessageEntity>> snapshot,
    List<MessageEntity> messages,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('در حال بارگذاری از دیتابیس محلی...'),
          ],
        ),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'خطا در خواندن دیتابیس محلی',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                snapshot.error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تلاش مجدد'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 56,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                widget.emptyTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _searchQuery.isNotEmpty
                    ? 'نتیجه‌ای برای جستجوی شما پیدا نشد.'
                    : widget.emptySubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageTile(
          message: message,
          onTap: () => showMessageDetailSheet(
            context: context,
            message: message,
            repository: widget.repository,
          ),
          onToggleStar: () => widget.repository.toggleStarred(
            message.smsId,
            !message.isStarred,
          ),
          onTogglePin: () => widget.repository.togglePinned(
            message.smsId,
            !message.isPinned,
          ),
        );
      },
    );
  }
}

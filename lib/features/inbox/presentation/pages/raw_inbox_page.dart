import 'package:flutter/material.dart';

import '../../../../data/sources/android_sms_source.dart';
import '../../../../data/sources/sms_source.dart';
import '../../../../domain/entities/sms_entity.dart';
import '../widgets/raw_sms_tile.dart';

/// Screen presenting raw SMS messages read directly from Android's SMS inbox.
///
/// Serves as the tangible milestone for Phase 2.2:
/// - Verifies native ContentResolver reading on physical devices.
/// - Demonstrates dual-SIM slot detection.
/// - Allows searching and filtering by SIM.
class RawInboxPage extends StatefulWidget {
  const RawInboxPage({
    super.key,
    this.smsSource = const AndroidSmsSource(),
    this.initialSimFilter,
  });

  final SmsSource smsSource;
  final int? initialSimFilter;

  @override
  State<RawInboxPage> createState() => _RawInboxPageState();
}

class _RawInboxPageState extends State<RawInboxPage> {
  List<SmsEntity> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _simFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _simFilter = widget.initialSimFilter;
    _fetchMessages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final messages = await widget.smsSource.readInbox(limit: 300);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<SmsEntity> get _filteredMessages {
    return _messages.where((msg) {
      // SIM Filter
      if (_simFilter != null && msg.simSlot != _simFilter) {
        return false;
      }
      // Search Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesAddress = msg.address.toLowerCase().contains(q);
        final matchesBody = msg.body.toLowerCase().contains(q);
        return matchesAddress || matchesBody;
      }
      return true;
    }).toList();
  }

  void _showMessageDetail(SmsEntity message) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
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
                      'فرستنده: ${message.address}',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
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
                'تاریخ دریافت: ${message.date.year}/${message.date.month}/${message.date.day} ساعت ${message.date.hour}:${message.date.minute}',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Divider(height: 24),
              SelectableText(
                message.body,
                style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedMessages = _filteredMessages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('صندوق پیام‌های دریافتی'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'بارگذاری مجدد',
            onPressed: _isLoading ? null : _fetchMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Search & SIM Selector
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
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
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
                  onSelected: (_) => setState(() => _simFilter = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.sim_card_outlined, size: 16),
                  label: const Text('سیم‌کارت ۱'),
                  selected: _simFilter == 1,
                  onSelected: (_) => setState(() => _simFilter = 1),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.sim_card_outlined, size: 16),
                  label: const Text('سیم‌کارت ۲'),
                  selected: _simFilter == 2,
                  onSelected: (_) => setState(() => _simFilter = 2),
                ),
                const SizedBox(width: 12),
                Text(
                  '${displayedMessages.length} پیام',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Message List or States
          Expanded(
            child: _buildBody(theme, displayedMessages),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List<SmsEntity> messages) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('در حال خواندن پیام‌های صندوق ورودی...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'خطا در دریافت پیامک‌ها',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _fetchMessages,
                icon: const Icon(Icons.refresh),
                label: const Text('تلاش مجدد'),
              ),
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
                'هیچ پیامی یافت نشد',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _searchQuery.isNotEmpty
                    ? 'نتیجه‌ای برای جستجوی شما پیدا نشد.'
                    : 'صندوق پیام‌های ورودی دستگاه خالی است.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
        return RawSmsTile(
          message: message,
          onTap: () => _showMessageDetail(message),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/di/app_dependencies.dart';
import '../../../../data/sync/message_sync_service.dart';
import '../../../../domain/repositories/message_repository.dart';
import '../widgets/message_list_panel.dart';

/// Screen presenting persisted SMS messages from the local Drift database.
///
/// Triggers incremental synchronization with Android's SMS provider and streams
/// updates reactively from SQLite with dual-SIM filtering and star/pin toggles.
class RawInboxPage extends StatefulWidget {
  const RawInboxPage({
    super.key,
    this.repository,
    this.syncService,
    this.initialSimFilter,
  });

  final IMessageRepository? repository;
  final MessageSyncService? syncService;
  final int? initialSimFilter;

  @override
  State<RawInboxPage> createState() => _RawInboxPageState();
}

class _RawInboxPageState extends State<RawInboxPage> {
  late final IMessageRepository _repository;
  late final MessageSyncService _syncService;
  bool _isSyncing = false;
  String? _syncError;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? AppDependencies.instance.messageRepository;
    _syncService = widget.syncService ?? AppDependencies.instance.syncService;
    _syncInbox();
  }

  Future<void> _syncInbox() async {
    setState(() {
      _isSyncing = true;
      _syncError = null;
    });

    try {
      await _syncService.syncInbox();
      if (!mounted) return;
      setState(() => _isSyncing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _syncError = e.toString();
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('صندوق پیام‌های دریافتی'),
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.sync_rounded),
              tooltip: 'همگام‌سازی پیام‌های جدید',
              onPressed: _syncInbox,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_syncError != null)
            MaterialBanner(
              backgroundColor: theme.colorScheme.errorContainer,
              content: Text(
                'خطا در همگام‌سازی با گوشی (نمایش پیام‌های ذخیره‌شده): $_syncError',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
              actions: [
                TextButton(
                  onPressed: _syncInbox,
                  child: const Text('تلاش مجدد'),
                ),
              ],
            ),
          Expanded(
            child: MessageListPanel(
              repository: _repository,
              initialSimFilter: widget.initialSimFilter,
              emptySubtitle: 'صندوق پیام‌های ورودی دستگاه خالی است.',
              onRetry: _syncInbox,
              streamFactory: (sim, query) => _repository.watchLatest(
                simSlot: sim,
                searchQuery: query,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/app_dependencies.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/sync/message_sync_service.dart';
import '../../../../domain/entities/category_count.dart';
import '../../../../domain/repositories/message_repository.dart';
import '../widgets/category_grid.dart';
import '../widgets/home_search_bar.dart';

/// Home page displaying category grid with search, quick filters, and persisted DB summary.
///
/// Follows Clean Architecture: UI interacts with [IMessageRepository] streams and
/// [MessageSyncService] without direct database or Android API coupling.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.repository,
    this.syncService,
  });

  final IMessageRepository? repository;
  final MessageSyncService? syncService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final IMessageRepository _repository;
  late final MessageSyncService _syncService;

  // Selected SIM card filter: null = all, 1 = SIM 1, 2 = SIM 2
  int? _selectedSim;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repository =
        widget.repository ?? AppDependencies.instance.messageRepository;
    _syncService = widget.syncService ?? AppDependencies.instance.syncService;
    _syncInbox();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncInbox();
    }
  }

  Future<void> _syncInbox() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await _syncService.syncInbox();
    } catch (_) {
      // Errors during background sync leave cached DB messages visible.
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _openInboxPage() {
    final uri = _selectedSim != null
        ? '${AppRouter.inboxPath}?sim=$_selectedSim'
        : AppRouter.inboxPath;
    context.push(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // SIM card filter menu (Requirement: dual-SIM support)
          PopupMenuButton<int?>(
            icon: Badge(
              isLabelVisible: _selectedSim != null,
              label: Text('$_selectedSim'),
              child: const Icon(Icons.sim_card_outlined),
            ),
            tooltip: 'فیلتر سیم‌کارت',
            initialValue: _selectedSim,
            onSelected: (sim) {
              setState(() {
                _selectedSim = sim;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('هر دو سیم‌کارت'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('سیم‌کارت ۱'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('سیم‌کارت ۲'),
              ),
            ],
          ),
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'همگام‌سازی پیام‌ها',
            onPressed: _isSyncing ? null : _syncInbox,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            HomeSearchBar(
              onTap: _openInboxPage,
            ),

            // Persisted DB Inbox Access Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _openInboxPage,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(
                            Icons.all_inbox_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'صندوق ورودی پیام‌های گوشی',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              StreamBuilder<int>(
                                stream: _repository.watchTotalCount(
                                  simSlot: _selectedSim,
                                ),
                                builder: (context, snapshot) {
                                  final subtitle = _isSyncing && !snapshot.hasData
                                      ? 'در حال همگام‌سازی و ذخیره...'
                                      : '${snapshot.data ?? 0} پیام ذخیره‌شده در دیتابیس محلی';
                                  return Text(
                                    subtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_back_ios_new_rounded, // RTL direction
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Active SIM Indicator banner if filtered
            if (_selectedSim != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Chip(
                      avatar: const Icon(Icons.filter_alt, size: 16),
                      label: Text('نمایش سیم‌کارت $_selectedSim'),
                      onDeleted: () {
                        setState(() {
                          _selectedSim = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Grid of Categories backed by Drift DB Streams
            Expanded(
              child: StreamBuilder<Map<String, CategoryCount>>(
                stream: _repository.watchCategoryCounts(
                  simSlot: _selectedSim,
                ),
                builder: (context, snapshot) {
                  final counts =
                      snapshot.data ?? const <String, CategoryCount>{};
                  final categories = AppConstants.mockCategories.map((cat) {
                    final count = counts[cat.id] ?? CategoryCount.zero;
                    return cat.copyWith(
                      messageCount: count.total,
                      unreadCount: count.unread,
                    );
                  }).toList();

                  return CategoryGrid(
                    categories: categories,
                    selectedSim: _selectedSim,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

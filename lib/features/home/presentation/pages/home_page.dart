import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/sources/android_sms_source.dart';
import '../../../../data/sources/sms_source.dart';
import '../widgets/category_grid.dart';
import '../widgets/home_search_bar.dart';

/// Home page displaying category grid with search, quick filters, and live inbox summary.
///
/// Follows Clean Architecture: UI interacts with abstract [SmsSource] for live counts.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.smsSource = const AndroidSmsSource(),
  });

  final SmsSource smsSource;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Selected SIM card filter: null = all, 1 = SIM 1, 2 = SIM 2
  int? _selectedSim;
  int? _inboxCount;
  bool _isLoadingCount = false;

  @override
  void initState() {
    super.initState();
    _fetchInboxCount();
  }

  Future<void> _fetchInboxCount() async {
    setState(() => _isLoadingCount = true);
    try {
      final count = await widget.smsSource.getInboxCount();
      if (!mounted) return;
      setState(() {
        _inboxCount = count;
        _isLoadingCount = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingCount = false);
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
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'به‌روزرسانی پیام‌ها',
            onPressed: _isLoadingCount ? null : _fetchInboxCount,
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

            // Live Inbox Access Banner
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primary,
                          child: const Icon(
                            Icons.all_inbox_rounded,
                            color: Colors.white,
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
                              Text(
                                _isLoadingCount
                                    ? 'در حال شمارش پیام‌ها...'
                                    : _inboxCount != null
                                        ? '$_inboxCount پیام دریافت شده در دستگاه'
                                        : 'مشاهده پیام‌های خوانده شده از دستگاه',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
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

            // Grid of Categories
            const Expanded(
              child: CategoryGrid(
                categories: AppConstants.mockCategories,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

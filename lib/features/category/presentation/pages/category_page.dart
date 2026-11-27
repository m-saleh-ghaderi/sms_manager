import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/app_dependencies.dart';
import '../../../../core/widgets/bank_filter_strip.dart';
import '../../../../data/sync/message_sync_service.dart';
import '../../../../domain/entities/category_info.dart';
import '../../../../domain/repositories/message_repository.dart';
import '../../../inbox/presentation/widgets/message_list_panel.dart';

/// Displays locally persisted messages belonging to [categoryId].
///
/// For `'bank'`, also provides dynamic horizontal bank filter chips matching
/// the exact bank colors used on the Financial Insights tab.
class CategoryPage extends StatefulWidget {
  const CategoryPage({
    super.key,
    required this.categoryId,
    this.initialSimFilter,
    this.repository,
    this.syncService,
  });

  final String categoryId;
  final int? initialSimFilter;
  final IMessageRepository? repository;
  final MessageSyncService? syncService;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final IMessageRepository _repository;
  late final MessageSyncService _syncService;
  int? _simFilter;
  String? _selectedBank;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? AppDependencies.instance.messageRepository;
    _syncService = widget.syncService ?? AppDependencies.instance.syncService;
    _simFilter = widget.initialSimFilter;
    if (widget.categoryId == 'bank') {
      _syncService.backfillBankMetadata();
    }
  }

  String _emptyMessageForCategory(String id) {
    return switch (id) {
      'starred' => 'هنوز پیامی را نشان‌دار نکرده‌اید.',
      'pinned' => 'هنوز پیامی را پین نکرده‌اید.',
      'contacts' => 'هنوز پیامی از مخاطبین در دیتابیس ثبت نشده است.',
      'unknown' => 'هیچ پیام ناشناسی در دیتابیس ثبت نشده است.',
      _ => 'هنوز پیامی در این دسته‌بندی ثبت نشده است.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBankCategory = widget.categoryId == 'bank';

    final category = AppConstants.mockCategories.firstWhere(
      (c) => c.id == widget.categoryId,
      orElse: () => CategoryInfo(
        id: widget.categoryId,
        name: 'دسته ${widget.categoryId}',
        icon: Icons.folder_rounded,
        color: theme.colorScheme.primary,
      ),
    );

    Widget buildPanel({List<String>? banks, String? effectiveBank}) {
      return MessageListPanel(
        repository: _repository,
        initialSimFilter: widget.initialSimFilter,
        emptyTitle: effectiveBank != null
            ? 'پیامی از $effectiveBank یافت نشد'
            : 'پیامی در «${category.name}» نیست',
        emptySubtitle: _emptyMessageForCategory(widget.categoryId),
        onSimChanged: (sim) => setState(() => _simFilter = sim),
        extraFilterBar: isBankCategory && banks != null && banks.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BankFilterStrip(
                  banks: banks,
                  selectedBank: effectiveBank,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onSelectBank: (bank) => setState(() => _selectedBank = bank),
                ),
              )
            : null,
        streamFactory: (sim, query) => _repository.watchByCategory(
          widget.categoryId,
          simSlot: sim,
          bankName: effectiveBank,
          searchQuery: query,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: category.color.withValues(alpha: 0.2),
              child: Icon(category.icon, size: 16, color: category.color),
            ),
            const SizedBox(width: 8),
            Text(category.name),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward), // RTL back arrow
          onPressed: () => context.pop(),
        ),
      ),
      body: isBankCategory
          ? StreamBuilder<List<String>>(
              stream: _repository.watchDistinctBanks(simSlot: _simFilter),
              builder: (context, banksSnapshot) {
                final banks = banksSnapshot.data ?? const <String>[];
                final effectiveBank =
                    _selectedBank != null && banks.contains(_selectedBank)
                        ? _selectedBank
                        : null;
                return buildPanel(banks: banks, effectiveBank: effectiveBank);
              },
            )
          : buildPanel(),
    );
  }
}

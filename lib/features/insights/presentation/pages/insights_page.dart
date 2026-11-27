import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/debug_bank_sms_seeder.dart';
import '../../../../core/utils/jalali_date.dart';
import '../../../../data/sync/message_sync_service.dart';
import '../../../../domain/entities/financial_insights.dart';
import '../../../../domain/entities/message_entity.dart';
import '../../../../domain/repositories/message_repository.dart';
import '../../../../domain/usecases/compute_bank_balances.dart';
import '../../../../domain/usecases/compute_financial_insights.dart';
import '../../../inbox/presentation/widgets/message_detail_sheet.dart';
import '../widgets/bank_balance_card.dart';
import '../widgets/bank_transaction_tile.dart';
import '../widgets/monthly_cashflow_bar_chart.dart';
import '../widgets/shamsi_date_range_dialog.dart';

/// Financial Insights page backed by real `bank` SMS records in Drift SQLite.
///
/// Features:
/// - Dynamic bank filter chips ("همه بانک‌ها" + banks found in user's SMS)
/// - Total or per-bank (with per-card breakdown) balance card
/// - Shamsi time-range presets and custom Shamsi range picker
/// - Toman (default) / Rial quick currency switcher
/// - Dual-SIM filtering (`همه`, `سیم ۱`, `سیم ۲`)
/// - Monthly deposit vs withdrawal bar chart & interactive transaction list
class InsightsPage extends StatefulWidget {
  const InsightsPage({
    super.key,
    this.repository,
    this.syncService,
  });

  final IMessageRepository? repository;
  final MessageSyncService? syncService;

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late final IMessageRepository _repository;
  late final MessageSyncService _syncService;
  final _calculator = const ComputeFinancialInsights();
  final _balanceCalculator = const ComputeBankBalances();

  InsightsTimeFilter _timeFilter = InsightsTimeFilter.last6Months;
  InsightsTxFilter _txFilter = InsightsTxFilter.all;
  CurrencyUnit _currencyUnit = CurrencyUnit.toman;
  String? _selectedBank;
  int? _selectedSim;
  JalaliDate? _customStart;
  JalaliDate? _customEnd;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? AppDependencies.instance.messageRepository;
    _syncService = widget.syncService ?? AppDependencies.instance.syncService;
    _syncService.backfillBankMetadata();
  }

  Future<void> _onTimeFilterSelected(InsightsTimeFilter filter) async {
    if (filter == InsightsTimeFilter.custom) {
      final picked = await showShamsiDateRangeDialog(
        context,
        initialStart: _customStart,
        initialEnd: _customEnd,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _timeFilter = InsightsTimeFilter.custom;
        _customStart = picked.start;
        _customEnd = picked.end;
      });
      return;
    }

    setState(() => _timeFilter = filter);
  }

  Future<void> _handleDebugSeedAction(String action) async {
    final seeder = DebugBankSmsSeeder(repository: _repository);
    if (action == 'seed') {
      final count = await seeder.seedSampleBankData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count تراکنش آزمایشی از ۱۰ بانک در ۱۲ ماه اضافه شد')),
      );
    } else if (action == 'clear') {
      final deleted = await seeder.clearDemoData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$deleted تراکنش آزمایشی حذف شد')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateRange = InsightsDateRange.fromFilter(
      _timeFilter,
      customStart: _customStart,
      customEnd: _customEnd,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('تراکنش‌ها و آمار مالی'),
        actions: [
          if (kDebugMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.science_outlined),
              tooltip: 'داده‌های آزمایشی بانک‌ها',
              onSelected: _handleDebugSeedAction,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'seed',
                  child: Text('تولید ۵۰ تراکنش نمونه (۱۰ بانک / ۱۲ ماه)'),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Text('حذف تراکنش‌های آزمایشی'),
                ),
              ],
            ),
          PopupMenuButton<int?>(
            icon: Badge(
              isLabelVisible: _selectedSim != null,
              label: Text('$_selectedSim'),
              child: const Icon(Icons.sim_card_outlined),
            ),
            tooltip: 'فیلتر سیم‌کارت',
            initialValue: _selectedSim,
            onSelected: (sim) => setState(() => _selectedSim = sim),
            itemBuilder: (context) => const [
              PopupMenuItem(value: null, child: Text('هر دو سیم‌کارت')),
              PopupMenuItem(value: 1, child: Text('سیم‌کارت ۱')),
              PopupMenuItem(value: 2, child: Text('سیم‌کارت ۲')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: _repository.watchDistinctBanks(simSlot: _selectedSim),
        builder: (context, banksSnapshot) {
          final availableBanks = banksSnapshot.data ?? const <String>[];
          final effectiveBank =
              _selectedBank != null && availableBanks.contains(_selectedBank)
                  ? _selectedBank
                  : null;

          return StreamBuilder<List<MessageEntity>>(
            stream: _repository.watchBankBalanceMessages(
              simSlot: _selectedSim,
              bankName: effectiveBank,
            ),
            builder: (context, balanceSnapshot) {
              final balanceMessages =
                  balanceSnapshot.data ?? const <MessageEntity>[];
              final portfolio = _balanceCalculator.compute(balanceMessages);

              return StreamBuilder<List<MessageEntity>>(
                stream: _repository.watchBankTransactions(
                  simSlot: _selectedSim,
                  bankName: effectiveBank,
                  startDate: dateRange.start,
                  endDate: dateRange.end,
                ),
                builder: (context, txSnapshot) {
                  if (txSnapshot.connectionState == ConnectionState.waiting &&
                      !txSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = txSnapshot.data ?? const <MessageEntity>[];
                  final summary =
                      _calculator.compute(messages, range: dateRange);

                  final filteredTransactions = switch (_txFilter) {
                    InsightsTxFilter.all => summary.transactions,
                    InsightsTxFilter.credit => summary.transactions
                        .where((m) => m.txType == TransactionType.credit)
                        .toList(),
                    InsightsTxFilter.debit => summary.transactions
                        .where((m) => m.txType == TransactionType.debit)
                        .toList(),
                  };

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    children: [
                      // Dynamic User Bank Filter Strip
                      _BankFilterStrip(
                        banks: availableBanks,
                        selectedBank: effectiveBank,
                        onSelectBank: (bank) =>
                            setState(() => _selectedBank = bank),
                      ),
                      const SizedBox(height: 8),

                      // Shamsi Time Filter Chips
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: InsightsTimeFilter.values.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final filter = InsightsTimeFilter.values[index];
                            final selected = _timeFilter == filter;
                            return ChoiceChip(
                              label: Text(filter.label),
                              selected: selected,
                              avatar: filter == InsightsTimeFilter.custom
                                  ? const Icon(Icons.date_range_rounded, size: 16)
                                  : null,
                              onSelected: (_) => _onTimeFilterSelected(filter),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Active Shamsi Range Label + SIM Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'بازه: ${dateRange.startJalali.formatNumeric()} تا ${dateRange.endJalali.formatNumeric()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (_selectedSim != null)
                            Text(
                              'فیلتر: سیم‌کارت $_selectedSim',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Account / Portfolio Balance Card + Currency Unit Switcher
                      BankBalanceCard(
                        portfolio: portfolio,
                        selectedBank: effectiveBank,
                        unit: _currencyUnit,
                        onUnitChanged: (unit) =>
                            setState(() => _currencyUnit = unit),
                      ),
                      const SizedBox(height: 12),

                      // Cash Flow Overview Card (Deposits / Withdrawals / Net)
                      _SummaryOverviewCard(
                        summary: summary,
                        unit: _currencyUnit,
                        selectedBank: effectiveBank,
                      ),
                      const SizedBox(height: 14),

                      // Monthly Deposit vs Withdrawal Bar Chart
                      MonthlyCashflowBarChart(
                        months: summary.monthlyBreakdown,
                        unit: _currencyUnit,
                      ),
                      const SizedBox(height: 20),

                      // Transactions Section Header + Direction Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'تراکنش‌های بانکی (${filteredTransactions.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: InsightsTxFilter.values.map((filter) {
                              final selected = _txFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  visualDensity: VisualDensity.compact,
                                  label: Text(
                                    filter.label,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  selected: selected,
                                  showCheckmark: false,
                                  onSelected: (_) =>
                                      setState(() => _txFilter = filter),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (filteredTransactions.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 32,
                              horizontal: 20,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 40,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  effectiveBank != null
                                      ? 'تراکنشی برای $effectiveBank در این بازه یافت نشد'
                                      : 'پیامک بانکی در این بازه یافت نشد',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'فیلتر بانک یا بازه زمانی را تغییر دهید.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filteredTransactions.map(
                          (msg) => BankTransactionTile(
                            message: msg,
                            unit: _currencyUnit,
                            onTap: () => showMessageDetailSheet(
                              context: context,
                              message: msg,
                              repository: _repository,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _BankFilterStrip extends StatelessWidget {
  const _BankFilterStrip({
    required this.banks,
    required this.selectedBank,
    required this.onSelectBank,
  });

  final List<String> banks;
  final String? selectedBank;
  final ValueChanged<String?> onSelectBank;

  @override
  Widget build(BuildContext context) {
    final itemCount = 1 + banks.length;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              avatar: const Icon(Icons.account_balance_rounded, size: 16),
              label: const Text('همه بانک‌ها'),
              selected: selectedBank == null,
              onSelected: (_) => onSelectBank(null),
            );
          }

          final bankName = banks[index - 1];
          return ChoiceChip(
            label: Text(bankName),
            selected: selectedBank == bankName,
            onSelected: (_) => onSelectBank(bankName),
          );
        },
      ),
    );
  }
}

class _SummaryOverviewCard extends StatelessWidget {
  const _SummaryOverviewCard({
    required this.summary,
    required this.unit,
    this.selectedBank,
  });

  final FinancialInsightsSummary summary;
  final CurrencyUnit unit;
  final String? selectedBank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netColor = summary.netRial >= 0 ? AppColors.contacts : AppColors.otp;
    final netPrefix = summary.netRial > 0 ? '\u200E+' : '';
    final formattedNet = summary.netRial < 0
        ? '\u200E-${CurrencyFormatter.format(summary.netRial.abs(), unit)}'
        : '$netPrefix${CurrencyFormatter.format(summary.netRial, unit)}';

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedBank != null
                  ? 'گردش مالی • $selectedBank'
                  : 'خلاصه گردش مالی',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    title: 'مجموع واریز',
                    amount:
                        CurrencyFormatter.format(summary.totalCreditRial, unit),
                    color: AppColors.contacts,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    title: 'مجموع برداشت',
                    amount:
                        CurrencyFormatter.format(summary.totalDebitRial, unit),
                    color: AppColors.otp,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تراز خالص (${summary.transactionCount} تراکنش مبلغ‌دار)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    formattedNet,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: netColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

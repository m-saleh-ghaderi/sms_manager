import 'package:flutter/material.dart';

import '../../../../core/di/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/jalali_date.dart';
import '../../../../domain/entities/financial_insights.dart';
import '../../../../domain/entities/message_entity.dart';
import '../../../../domain/repositories/message_repository.dart';
import '../../../../domain/usecases/compute_financial_insights.dart';
import '../../../inbox/presentation/widgets/message_detail_sheet.dart';
import '../widgets/bank_transaction_tile.dart';
import '../widgets/monthly_cashflow_bar_chart.dart';
import '../widgets/shamsi_date_range_dialog.dart';

/// Financial Insights page backed by real `bank` SMS records in Drift SQLite.
///
/// Features:
/// - Shamsi time-range presets (`ماه جاری`, `۳ ماه اخیر`, `۶ ماه اخیر`, `یک سال اخیر`, `بازه دلخواه`)
/// - Toman (default) / Rial quick currency switcher
/// - Dual-SIM filtering (`همه`, `سیم ۱`, `سیم ۲`)
/// - Monthly deposit vs withdrawal bar chart & interactive transaction list
class InsightsPage extends StatefulWidget {
  const InsightsPage({
    super.key,
    this.repository,
  });

  final IMessageRepository? repository;

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late final IMessageRepository _repository;
  final _calculator = const ComputeFinancialInsights();

  InsightsTimeFilter _timeFilter = InsightsTimeFilter.last6Months;
  InsightsTxFilter _txFilter = InsightsTxFilter.all;
  CurrencyUnit _currencyUnit = CurrencyUnit.toman;
  int? _selectedSim;
  JalaliDate? _customStart;
  JalaliDate? _customEnd;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? AppDependencies.instance.messageRepository;
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
      body: StreamBuilder<List<MessageEntity>>(
        stream: _repository.watchBankTransactions(
          simSlot: _selectedSim,
          startDate: dateRange.start,
          endDate: dateRange.end,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data ?? const <MessageEntity>[];
          final summary = _calculator.compute(messages, range: dateRange);

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

              // Financial Overview Card + Currency Toggle
              _SummaryOverviewCard(
                summary: summary,
                unit: _currencyUnit,
                onUnitChanged: (unit) => setState(() => _currencyUnit = unit),
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
                          onSelected: (_) => setState(() => _txFilter = filter),
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
                          'پیامک بانکی در این بازه یافت نشد',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'بازه زمانی را تغییر دهید یا پیامک‌های جدید را همگام‌سازی کنید.',
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
      ),
    );
  }
}

class _SummaryOverviewCard extends StatelessWidget {
  const _SummaryOverviewCard({
    required this.summary,
    required this.unit,
    required this.onUnitChanged,
  });

  final FinancialInsightsSummary summary;
  final CurrencyUnit unit;
  final ValueChanged<CurrencyUnit> onUnitChanged;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'خلاصه وضعیت مالی',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Quick Toman / Rial Toggle
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _UnitPill(
                        label: 'تومان',
                        selected: unit == CurrencyUnit.toman,
                        onTap: () => onUnitChanged(CurrencyUnit.toman),
                      ),
                      _UnitPill(
                        label: 'ریال',
                        selected: unit == CurrencyUnit.rial,
                        onTap: () => onUnitChanged(CurrencyUnit.rial),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    title: 'مجموع واریز',
                    amount: CurrencyFormatter.format(summary.totalCreditRial, unit),
                    color: AppColors.contacts,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    title: 'مجموع برداشت',
                    amount: CurrencyFormatter.format(summary.totalDebitRial, unit),
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

class _UnitPill extends StatelessWidget {
  const _UnitPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
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

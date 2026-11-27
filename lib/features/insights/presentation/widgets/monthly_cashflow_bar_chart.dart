import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/financial_insights.dart';

/// Monthly grouped bar chart displaying deposit (credit) vs withdrawal (debit)
/// amounts across Shamsi months, with interactive month selection details.
class MonthlyCashflowBarChart extends StatefulWidget {
  const MonthlyCashflowBarChart({
    super.key,
    required this.months,
    required this.unit,
  });

  final List<MonthlyCashFlow> months;
  final CurrencyUnit unit;

  @override
  State<MonthlyCashflowBarChart> createState() =>
      _MonthlyCashflowBarChartState();
}

class _MonthlyCashflowBarChartState extends State<MonthlyCashflowBarChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant MonthlyCashflowBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex != null && _selectedIndex! >= widget.months.length) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = widget.months;

    if (months.isEmpty) {
      return const SizedBox.shrink();
    }

    var maxAmountRial = 0;
    for (final m in months) {
      maxAmountRial = math.max(maxAmountRial, math.max(m.creditRial, m.debitRial));
    }

    final activeIndex = _selectedIndex ??
        (months.lastIndexWhere((m) => m.creditRial > 0 || m.debitRial > 0));
    final selectedMonth = (activeIndex >= 0 && activeIndex < months.length)
        ? months[activeIndex]
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'نمودار ماهانه واریز و برداشت',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendDot(color: AppColors.contacts, label: 'واریز'),
                    SizedBox(width: 12),
                    _LegendDot(color: AppColors.otp, label: 'برداشت'),
                  ],
                ),
              ],
            ),

            // Interactive Month Detail Banner
            if (selectedMonth != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedMonth.monthName} ${selectedMonth.year} (${selectedMonth.transactionCount} تراکنش)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        Text(
                          'واریز: ${CurrencyFormatter.format(selectedMonth.creditRial, widget.unit)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.contacts,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'برداشت: ${CurrencyFormatter.format(selectedMonth.debitRial, widget.unit)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.otp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            if (maxAmountRial == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text(
                    'در این بازه زمانی تراکنش مالی ثبت نشده است.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              _BarChartPlotArea(
                months: months,
                unit: widget.unit,
                maxAmountRial: maxAmountRial,
                selectedIndex: activeIndex,
                onSelectMonth: (index) {
                  setState(() => _selectedIndex = index);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _BarChartPlotArea extends StatelessWidget {
  const _BarChartPlotArea({
    required this.months,
    required this.unit,
    required this.maxAmountRial,
    required this.selectedIndex,
    required this.onSelectMonth,
  });

  final List<MonthlyCashFlow> months;
  final CurrencyUnit unit;
  final int maxAmountRial;
  final int selectedIndex;
  final ValueChanged<int> onSelectMonth;

  static const double _chartHeight = 164;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gridColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.45);
    final yTicks = [maxAmountRial, maxAmountRial ~/ 2, 0];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Y-Axis Labels
        SizedBox(
          width: 54,
          height: _chartHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: yTicks
                .map(
                  (tick) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      CurrencyFormatter.formatCompact(tick, unit),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        // Bars + Gridlines
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const minColumnWidth = 46.0;
              final neededWidth = months.length * minColumnWidth;
              final contentWidth = math.max(constraints.maxWidth, neededWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    children: [
                      SizedBox(
                        height: _chartHeight,
                        child: Stack(
                          children: [
                            // Grid lines
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                3,
                                (_) => Divider(
                                  height: 1,
                                  thickness: 0.8,
                                  color: gridColor,
                                ),
                              ),
                            ),

                            // Grouped Bars
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(months.length, (i) {
                                final m = months[i];
                                final isSelected = i == selectedIndex;
                                final creditRatio =
                                    (m.creditRial / maxAmountRial)
                                        .clamp(0.0, 1.0);
                                final debitRatio =
                                    (m.debitRial / maxAmountRial)
                                        .clamp(0.0, 1.0);

                                return Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () => onSelectMonth(i),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: isSelected
                                          ? BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            )
                                          : null,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          _AnimatedBar(
                                            ratio: creditRatio,
                                            maxHeight: _chartHeight - 6,
                                            color: AppColors.contacts,
                                          ),
                                          const SizedBox(width: 4),
                                          _AnimatedBar(
                                            ratio: debitRatio,
                                            maxHeight: _chartHeight - 6,
                                            color: AppColors.otp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // X-Axis Month Labels
                      Row(
                        children: List.generate(months.length, (i) {
                          final m = months[i];
                          final isSelected = i == selectedIndex;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => onSelectMonth(i),
                              child: Text(
                                m.monthName,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  const _AnimatedBar({
    required this.ratio,
    required this.maxHeight,
    required this.color,
  });

  final double ratio;
  final double maxHeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final targetHeight = ratio <= 0 ? 3.0 : math.max(8.0, ratio * maxHeight);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: 13,
      height: targetHeight,
      decoration: BoxDecoration(
        color: ratio <= 0 ? color.withValues(alpha: 0.2) : color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

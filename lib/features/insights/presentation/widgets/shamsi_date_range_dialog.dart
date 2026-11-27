import 'package:flutter/material.dart';

import '../../../../core/utils/jalali_date.dart';

/// Opens a Material 3 Persian (Shamsi) calendar dialog to select an inclusive date range.
Future<({JalaliDate start, JalaliDate end})?> showShamsiDateRangeDialog(
  BuildContext context, {
  JalaliDate? initialStart,
  JalaliDate? initialEnd,
}) {
  return showDialog<({JalaliDate start, JalaliDate end})>(
    context: context,
    builder: (ctx) => _ShamsiDateRangeDialog(
      initialStart: initialStart,
      initialEnd: initialEnd,
    ),
  );
}

class _ShamsiDateRangeDialog extends StatefulWidget {
  const _ShamsiDateRangeDialog({
    this.initialStart,
    this.initialEnd,
  });

  final JalaliDate? initialStart;
  final JalaliDate? initialEnd;

  @override
  State<_ShamsiDateRangeDialog> createState() => _ShamsiDateRangeDialogState();
}

class _ShamsiDateRangeDialogState extends State<_ShamsiDateRangeDialog> {
  late JalaliDate _displayMonth;
  JalaliDate? _startDate;
  JalaliDate? _endDate;
  late final JalaliDate _today;

  @override
  void initState() {
    super.initState();
    _today = JalaliDate.fromDateTime(DateTime.now());
    _startDate = widget.initialStart ?? _today.startOfMonth;
    _endDate = widget.initialEnd ?? _today;
    _displayMonth = (_endDate ?? _today).startOfMonth;
  }

  void _onDayTapped(JalaliDate tapped) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = tapped;
        _endDate = null;
      } else {
        if (tapped < _startDate!) {
          _endDate = _startDate;
          _startDate = tapped;
        } else {
          _endDate = tapped;
        }
      }
    });
  }

  void _shiftMonth(int delta) {
    setState(() {
      _displayMonth = _displayMonth.addMonths(delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysCount =
        JalaliDate.daysInMonth(_displayMonth.year, _displayMonth.month);
    final firstWeekdayOffset = _displayMonth.startOfMonth.persianWeekday;
    final totalCells = firstWeekdayOffset + daysCount;

    final effectiveStart = _startDate;
    final effectiveEnd = _endDate ?? _startDate;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'انتخاب بازه زمانی شمسی',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              effectiveStart == null
                  ? 'تاریخ شروع را انتخاب کنید'
                  : _endDate == null
                      ? 'از ${effectiveStart.formatNumeric()} — تاریخ پایان را انتخاب کنید'
                      : 'از ${effectiveStart.formatNumeric()} تا ${effectiveEnd!.formatNumeric()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'ماه قبل',
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => _shiftMonth(-1),
                ),
                Text(
                  _displayMonth.formatMonthYear(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  tooltip: 'ماه بعد',
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => _shiftMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Weekday headers (Saturday -> Friday)
            Row(
              children: JalaliDate.shortWeekdayNames
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 6),

            // Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 2,
              ),
              itemCount: totalCells,
              itemBuilder: (context, index) {
                if (index < firstWeekdayOffset) {
                  return const SizedBox.shrink();
                }

                final dayNumber = index - firstWeekdayOffset + 1;
                final date =
                    JalaliDate(_displayMonth.year, _displayMonth.month, dayNumber);
                final isStart = effectiveStart == date;
                final isEnd = effectiveEnd == date;
                final isSelectedEdge = isStart || isEnd;
                final isInRange = effectiveStart != null &&
                    effectiveEnd != null &&
                    date > effectiveStart &&
                    date < effectiveEnd;
                final isToday = date == _today;

                Color? bgColor;
                Color textColor = theme.colorScheme.onSurface;
                if (isSelectedEdge) {
                  bgColor = theme.colorScheme.primary;
                  textColor = theme.colorScheme.onPrimary;
                } else if (isInRange) {
                  bgColor = theme.colorScheme.primaryContainer;
                  textColor = theme.colorScheme.onPrimaryContainer;
                }

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _onDayTapped(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: isSelectedEdge ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius:
                          isSelectedEdge ? null : BorderRadius.circular(8),
                      border: isToday && !isSelectedEdge
                          ? Border.all(color: theme.colorScheme.primary)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNumber',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: isSelectedEdge || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: effectiveStart == null
              ? null
              : () {
                  Navigator.of(context).pop((
                    start: effectiveStart,
                    end: effectiveEnd ?? effectiveStart,
                  ));
                },
          child: const Text('تایید بازه'),
        ),
      ],
    );
  }
}

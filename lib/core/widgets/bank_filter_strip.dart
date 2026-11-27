import 'package:flutter/material.dart';

import '../theme/bank_colors.dart';

/// Horizontal scrollable filter strip showing "همه بانک‌ها" plus each bank
/// detected in the user's messages with soft Image-1 pill styling.
class BankFilterStrip extends StatelessWidget {
  const BankFilterStrip({
    super.key,
    required this.banks,
    required this.selectedBank,
    required this.onSelectBank,
    this.padding = EdgeInsets.zero,
  });

  final List<String> banks;
  final String? selectedBank;
  final ValueChanged<String?> onSelectBank;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: 1 + banks.length,
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
          final brandColor = BankColors.colorFor(bankName);
          final readable = BankColors.readableAccent(brandColor, theme.brightness);
          final isSelected = selectedBank == bankName;

          return ChoiceChip(
            avatar: isSelected
                ? null
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: brandColor,
                      shape: BoxShape.circle,
                    ),
                  ),
            label: Text(
              bankName,
              style: TextStyle(
                color: readable,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            selected: isSelected,
            checkmarkColor: readable,
            backgroundColor: brandColor.withValues(alpha: isDark ? 0.18 : 0.11),
            selectedColor: brandColor.withValues(alpha: isDark ? 0.30 : 0.21),
            side: BorderSide(
              color: brandColor.withValues(
                alpha: isSelected
                    ? (isDark ? 0.72 : 0.58)
                    : (isDark ? 0.38 : 0.26),
              ),
              width: isSelected ? 1.2 : 0.9,
            ),
            onSelected: (_) => onSelectBank(bankName),
          );
        },
      ),
    );
  }
}

/// Shared card container with neutral background & border and a thin vertical
/// bank color stripe along the RTL start edge.
class BankAccentCard extends StatelessWidget {
  const BankAccentCard({
    super.key,
    required this.bankColor,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: 8),
    this.borderRadius = 14,
    this.elevation = 0.5,
    this.borderWidth = 0.8,
    this.borderColor,
    this.onTap,
  });

  final Color bankColor;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double elevation;
  final double borderWidth;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resolvedBorder = borderColor ??
        theme.colorScheme.outlineVariant.withValues(
          alpha: isDark ? 0.28 : 0.35,
        );

    return Card(
      margin: margin,
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: resolvedBorder,
          width: borderWidth,
        ),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: 4.0,
            child: ColoredBox(color: bankColor.withValues(alpha: 0.88)),
          ),
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 4.0),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small pill badge showing the bank's name in its dedicated soft brand color.
class BankNameBadge extends StatelessWidget {
  const BankNameBadge({
    super.key,
    required this.bankName,
  });

  final String bankName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = BankColors.colorFor(bankName);
    final readable = BankColors.readableAccent(brandColor, theme.brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: brandColor.withValues(alpha: isDark ? 0.22 : 0.13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: brandColor.withValues(alpha: isDark ? 0.45 : 0.30),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: brandColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            bankName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: readable,
              fontWeight: FontWeight.bold,
              fontSize: 10.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

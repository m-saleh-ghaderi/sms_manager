import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Presentation page for financial insights, deposits, and withdrawals.
///
/// Tab 2 of the bottom navigation shell.
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تراکنش‌ها و آمار مالی'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Monthly Overview Card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'خلاصه پیام‌های مالی این ماه',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          title: 'مجموع واریز',
                          amount: '۱۲,۴۵۰,۰۰۰ ریال',
                          color: AppColors.contacts,
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          title: 'مجموع برداشت',
                          amount: '۸,۷۲۰,۰۰۰ ریال',
                          color: AppColors.otp,
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section Title
          Text(
            'آخرین پیام‌های تراکنشی بانکی',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Placeholder transaction message items
          _TransactionPreviewItem(
            bankName: 'بانک ملت',
            details: 'واریز به حساب: ۵,۰۰۰,۰۰۰ ریال',
            date: 'امروز، ساعت ۱۴:۳۰',
            isDeposit: true,
          ),
          _TransactionPreviewItem(
            bankName: 'بانک سامان',
            details: 'برداشت خرید: ۱,۲۰۰,۰۰۰ ریال',
            date: 'دیروز، ساعت ۱۸:۱۵',
            isDeposit: false,
          ),
          _TransactionPreviewItem(
            bankName: 'بانک ملی',
            details: 'انتقال کارت به کارت: ۳,۰۰۰,۰۰۰ ریال',
            date: '۲ روز پیش',
            isDeposit: false,
          ),
        ],
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
          ),
        ],
      ),
    );
  }
}

class _TransactionPreviewItem extends StatelessWidget {
  const _TransactionPreviewItem({
    required this.bankName,
    required this.details,
    required this.date,
    required this.isDeposit,
  });

  final String bankName;
  final String details;
  final String date;
  final bool isDeposit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDeposit
              ? AppColors.contacts.withValues(alpha: 0.15)
              : AppColors.otp.withValues(alpha: 0.15),
          child: Icon(
            isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: isDeposit ? AppColors.contacts : AppColors.otp,
            size: 20,
          ),
        ),
        title: Text(bankName),
        subtitle: Text(details),
        trailing: Text(
          date,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

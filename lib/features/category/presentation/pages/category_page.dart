import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/category_info.dart';

/// Presentation page for displaying messages of a specific category.
///
/// In this design phase, demonstrates the category header, color theming,
/// and placeholder list structure before real database connection.
class CategoryPage extends StatelessWidget {
  const CategoryPage({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Find category details from mock definitions or fallback
    final category = AppConstants.mockCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryInfo(
        id: categoryId,
        name: 'دسته $categoryId',
        icon: Icons.folder_rounded,
        color: theme.colorScheme.primary,
      ),
    );

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
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: category.color.withValues(alpha: 0.1),
                child: Icon(
                  category.icon,
                  size: 44,
                  color: category.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'پیام‌های «${category.name}»',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لیست پیام‌های این دسته و قابلیت‌های فیلتر در فاز ۲ پس از اتصال دیتابیس نمایش داده خواهند شد.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

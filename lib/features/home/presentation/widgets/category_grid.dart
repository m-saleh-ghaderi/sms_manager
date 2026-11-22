import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../domain/entities/category_info.dart';
import 'category_card.dart';

/// Grid layout for displaying category cards.
///
/// Follows Single Responsibility Principle (SRP): Responsible solely for
/// the responsive 2-column grid layout and dispatching click events.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
  });

  final List<CategoryInfo> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          onTap: () {
            if (category.id == 'recent') {
              context.push(AppRouter.inboxPath);
            } else {
              context.push(AppRouter.categoryDetailPath(category.id));
            }
          },
        );
      },
    );
  }
}

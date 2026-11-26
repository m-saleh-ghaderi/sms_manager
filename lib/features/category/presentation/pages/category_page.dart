import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/app_dependencies.dart';
import '../../../../domain/entities/category_info.dart';
import '../../../../domain/repositories/message_repository.dart';
import '../../../inbox/presentation/widgets/message_list_panel.dart';

/// Displays locally persisted messages belonging to [categoryId].
class CategoryPage extends StatelessWidget {
  const CategoryPage({
    super.key,
    required this.categoryId,
    this.initialSimFilter,
    this.repository,
  });

  final String categoryId;
  final int? initialSimFilter;
  final IMessageRepository? repository;

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
    final repo = repository ?? AppDependencies.instance.messageRepository;

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
      ),
      body: MessageListPanel(
        repository: repo,
        initialSimFilter: initialSimFilter,
        emptyTitle: 'پیامی در «${category.name}» نیست',
        emptySubtitle: _emptyMessageForCategory(categoryId),
        streamFactory: (sim, query) => repo.watchByCategory(
          categoryId,
          simSlot: sim,
          searchQuery: query,
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';

/// Immutable value object holding message counts for a single category.
@immutable
class CategoryCount {
  const CategoryCount({
    required this.total,
    required this.unread,
  });

  final int total;
  final int unread;

  static const CategoryCount zero = CategoryCount(total: 0, unread: 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryCount &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          unread == other.unread;

  @override
  int get hashCode => Object.hash(total, unread);
}

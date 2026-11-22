import 'package:flutter/material.dart';

/// Immutable entity representing a message category.
///
/// Used by the presentation layer to display category cards in the
/// home page grid. Each category has a unique [id], a display [name],
/// an [icon], and a [color] for visual distinction.
///
/// In later phases, [messageCount] and [unreadCount] will come from
/// the database via Riverpod providers. Currently they hold mock values.
@immutable
class CategoryInfo {
  const CategoryInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.messageCount = 0,
    this.unreadCount = 0,
  });

  /// Unique identifier for the category (e.g. 'bank', 'otp').
  final String id;

  /// Persian display name (e.g. 'بانکی', 'کد تأیید').
  final String name;

  /// Material icon representing this category.
  final IconData icon;

  /// Accent color for the category's card and icon background.
  final Color color;

  /// Total number of messages in this category.
  final int messageCount;

  /// Number of unread messages in this category.
  final int unreadCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

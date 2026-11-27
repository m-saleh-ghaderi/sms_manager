import '../entities/category_count.dart';
import '../entities/message_entity.dart';

/// Abstract contract for persisting and querying SMS messages locally.
///
/// Follows Dependency Inversion Principle (DIP):
/// Presentation and sync layers depend on this interface rather than Drift directly.
abstract interface class IMessageRepository {
  /// Returns the highest `smsId` stored in the local database, or `null` if empty.
  Future<int?> getLatestSmsId();

  /// Inserts or updates a batch of [messages] while preserving user flags
  /// (`isStarred`, `isPinned`, and manual category overrides) on existing rows.
  Future<void> upsertMessages(List<MessageEntity> messages);

  /// Returns total stored message count, optionally filtered by [simSlot].
  Future<int> getTotalCount({int? simSlot});

  /// Watches total stored message count reactively.
  Stream<int> watchTotalCount({int? simSlot});

  /// Watches the latest messages ordered by pinned status then date descending.
  Stream<List<MessageEntity>> watchLatest({
    int? simSlot,
    int limit = 300,
    String? searchQuery,
  });

  /// Watches messages belonging to [categoryId] (including virtual IDs like
  /// `'recent'`, `'starred'`, `'pinned'`).
  Stream<List<MessageEntity>> watchByCategory(
    String categoryId, {
    int? simSlot,
    String? searchQuery,
  });

  /// Watches starred messages.
  Stream<List<MessageEntity>> watchStarred({
    int? simSlot,
    String? searchQuery,
  });

  /// Watches pinned messages.
  Stream<List<MessageEntity>> watchPinned({
    int? simSlot,
    String? searchQuery,
  });

  /// Watches total and unread counts mapped by category ID (including virtual categories).
  Stream<Map<String, CategoryCount>> watchCategoryCounts({int? simSlot});

  /// Watches bank category messages within `[startDate, endDate]` ordered newest-first.
  Stream<List<MessageEntity>> watchBankTransactions({
    int? simSlot,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Sets the starred state for the message with [smsId].
  Future<void> toggleStarred(int smsId, bool isStarred);

  /// Sets the pinned state for the message with [smsId].
  Future<void> togglePinned(int smsId, bool isPinned);

  /// Marks the message with [smsId] as read locally.
  Future<void> markAsRead(int smsId);

  /// Updates the primary category for the message with [smsId].
  Future<void> updateCategory(
    int smsId,
    String categoryId, {
    bool userOverride = true,
  });
}

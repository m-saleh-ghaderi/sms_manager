import 'package:flutter/foundation.dart';

import '../../core/utils/phone_normalizer.dart';

/// Represents the direction of a parsed financial transaction.
enum TransactionType {
  credit,
  debit,
}

/// Immutable domain entity representing a persisted SMS message in the local database.
///
/// Follows Clean Architecture: pure Dart entity independent of Drift/SQLite internals.
@immutable
class MessageEntity {
  const MessageEntity({
    this.id,
    required this.smsId,
    required this.address,
    required this.normalizedAddress,
    required this.body,
    required this.date,
    required this.isRead,
    this.simSlot,
    this.senderType = SenderType.service,
    this.primaryCategory = 'unknown',
    this.isStarred = false,
    this.isPinned = false,
    this.amountRial,
    this.txType,
    this.userOverride = false,
  });

  /// Local SQLite auto-increment primary key (null before initial persistence).
  final int? id;

  /// Unique `_id` from the Android SMS provider.
  final int smsId;

  /// Raw sender address or phone number.
  final String address;

  /// Normalized phone number (e.g. `09123456789`) or service identifier.
  final String normalizedAddress;

  /// Text content of the SMS.
  final String body;

  /// Received timestamp.
  final DateTime date;

  /// Whether the message is marked as read.
  final bool isRead;

  /// Dual-SIM slot index (`1`, `2`, or `null` when unknown).
  final int? simSlot;

  /// Origin classification of the sender.
  final SenderType senderType;

  /// Assigned primary category ID (matches IDs in `AppConstants.mockCategories`).
  final String primaryCategory;

  /// Whether the user starred/marked this message.
  final bool isStarred;

  /// Whether the user pinned this message as important.
  final bool isPinned;

  /// Parsed transaction amount in Rial (if applicable).
  final int? amountRial;

  /// Parsed transaction direction (if applicable).
  final TransactionType? txType;

  /// True when the user manually overrode [primaryCategory].
  final bool userOverride;

  MessageEntity copyWith({
    int? id,
    int? smsId,
    String? address,
    String? normalizedAddress,
    String? body,
    DateTime? date,
    bool? isRead,
    int? simSlot,
    SenderType? senderType,
    String? primaryCategory,
    bool? isStarred,
    bool? isPinned,
    int? amountRial,
    TransactionType? txType,
    bool? userOverride,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      smsId: smsId ?? this.smsId,
      address: address ?? this.address,
      normalizedAddress: normalizedAddress ?? this.normalizedAddress,
      body: body ?? this.body,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      simSlot: simSlot ?? this.simSlot,
      senderType: senderType ?? this.senderType,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      amountRial: amountRial ?? this.amountRial,
      txType: txType ?? this.txType,
      userOverride: userOverride ?? this.userOverride,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageEntity &&
          runtimeType == other.runtimeType &&
          smsId == other.smsId;

  @override
  int get hashCode => smsId.hashCode;

  @override
  String toString() =>
      'MessageEntity(smsId: $smsId, category: $primaryCategory, simSlot: $simSlot, starred: $isStarred, pinned: $isPinned)';
}

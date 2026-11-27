import 'package:drift/drift.dart';

/// Drift table definition for locally persisted SMS messages.
@TableIndex(name: 'idx_messages_category', columns: {#primaryCategory})
@TableIndex(name: 'idx_messages_date', columns: {#date})
@TableIndex(name: 'idx_messages_sim_slot', columns: {#simSlot})
@TableIndex(name: 'idx_messages_bank_name', columns: {#bankName})
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Unique `_id` from the Android SMS provider.
  IntColumn get smsId => integer().unique()();

  /// Raw sender address or phone number.
  TextColumn get address => text()();

  /// Normalized phone number or alphanumeric service identifier.
  TextColumn get normalizedAddress => text()();

  /// Full SMS text content.
  TextColumn get body => text()();

  /// Timestamp when the message was received.
  DateTimeColumn get date => dateTime()();

  /// Whether the message has been read.
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  /// Dual-SIM slot index (`1`, `2`, or `null`).
  IntColumn get simSlot => integer().nullable()();

  /// Sender classification (`contact`, `personal`, or `service`).
  TextColumn get senderType => text().withDefault(const Constant('service'))();

  /// Primary category identifier (e.g. `bank`, `otp`, `unknown`).
  TextColumn get primaryCategory =>
      text().withDefault(const Constant('unknown'))();

  /// User-marked star flag.
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();

  /// User-marked pin flag.
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  /// Parsed financial transaction amount in Rials (nullable).
  IntColumn get amountRial => integer().nullable()();

  /// Parsed transaction type (`credit` or `debit`, nullable).
  TextColumn get txType => text().nullable()();

  /// Canonical Persian bank display name (bank messages only).
  TextColumn get bankName => text().nullable()();

  /// Parsed post-transaction account/card balance in Rials (nullable).
  IntColumn get balanceRial => integer().nullable()();

  /// Last 4 digits of card/account number when present (nullable).
  TextColumn get cardTail => text().nullable()();

  /// Whether the user manually overrode [primaryCategory].
  BoolColumn get userOverride => boolean().withDefault(const Constant(false))();
}

import 'package:drift/drift.dart';

import '../../core/utils/phone_normalizer.dart';
import '../../domain/entities/category_count.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../db/app_database.dart';

/// Drift/SQLite implementation of [IMessageRepository].
///
/// Handles mapping between database rows ([Message]) and pure domain entities
/// ([MessageEntity]), reactive SQLite queries, and conflict-safe batch upserts.
class DriftMessageRepository implements IMessageRepository {
  DriftMessageRepository(this._db);

  final AppDatabase _db;

  static const int _upsertChunkSize = 400;

  @override
  Future<int?> getLatestSmsId() async {
    final maxExp = _db.messages.smsId.max();
    final query = _db.selectOnly(_db.messages)
      ..addColumns([maxExp])
      ..where(_db.messages.smsId.isBiggerThanValue(0));
    final row = await query.getSingleOrNull();
    return row?.read(maxExp);
  }

  @override
  Future<void> upsertMessages(List<MessageEntity> messages) async {
    if (messages.isEmpty) return;

    await _db.transaction(() async {
      for (var i = 0; i < messages.length; i += _upsertChunkSize) {
        final end = (i + _upsertChunkSize < messages.length)
            ? i + _upsertChunkSize
            : messages.length;
        final chunk = messages.sublist(i, end);
        final chunkSmsIds = chunk.map((m) => m.smsId).toList();

        // Preserve existing user actions (starred, pinned, read, manual category).
        final existingRows = await (_db.select(_db.messages)
              ..where((t) => t.smsId.isIn(chunkSmsIds)))
            .get();
        final existingBySmsId = {
          for (final row in existingRows) row.smsId: row,
        };

        // Clean up any temporary negative-smsId placeholders replaced by real provider rows.
        final incomingPositive = chunk.where((m) => m.smsId > 0).toList();
        if (incomingPositive.isNotEmpty) {
          final tempRows = await (_db.select(_db.messages)
                ..where((t) => t.smsId.isSmallerThanValue(0)))
              .get();
          for (final temp in tempRows) {
            final matchIndex = incomingPositive.indexWhere(
              (m) =>
                  m.normalizedAddress == temp.normalizedAddress &&
                  m.body == temp.body,
            );
            if (matchIndex != -1) {
              final incoming = incomingPositive[matchIndex];
              existingBySmsId.putIfAbsent(incoming.smsId, () => temp);
              await (_db.delete(_db.messages)
                    ..where((t) => t.smsId.equals(temp.smsId)))
                  .go();
            }
          }
        }

        await _db.batch((batch) {
          for (final entity in chunk) {
            final existing = existingBySmsId[entity.smsId];
            final merged = _mergeExistingFlags(entity, existing);
            final companion = _toCompanion(merged);

            batch.insert(
              _db.messages,
              companion,
              onConflict: DoUpdate(
                (_) => companion,
                target: [_db.messages.smsId],
              ),
            );
          }
        });
      }
    });
  }

  @override
  Future<int> getTotalCount({int? simSlot}) async {
    final countExp = _db.messages.id.count();
    final query = _db.selectOnly(_db.messages)..addColumns([countExp]);
    if (simSlot != null) {
      query.where(_db.messages.simSlot.equals(simSlot));
    }
    final row = await query.getSingleOrNull();
    return row?.read(countExp) ?? 0;
  }

  @override
  Stream<int> watchTotalCount({int? simSlot}) {
    final countExp = _db.messages.id.count();
    final query = _db.selectOnly(_db.messages)..addColumns([countExp]);
    if (simSlot != null) {
      query.where(_db.messages.simSlot.equals(simSlot));
    }
    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  @override
  Stream<List<MessageEntity>> watchLatest({
    int? simSlot,
    int limit = 300,
    String? searchQuery,
  }) {
    return _watchFilteredMessages(
      simSlot: simSlot,
      searchQuery: searchQuery,
      limit: limit,
    );
  }

  @override
  Stream<List<MessageEntity>> watchByCategory(
    String categoryId, {
    int? simSlot,
    String? bankName,
    String? searchQuery,
  }) {
    return switch (categoryId) {
      'recent' => watchLatest(
          simSlot: simSlot,
          searchQuery: searchQuery,
        ),
      'starred' => watchStarred(
          simSlot: simSlot,
          searchQuery: searchQuery,
        ),
      'pinned' => watchPinned(
          simSlot: simSlot,
          searchQuery: searchQuery,
        ),
      _ => _watchFilteredMessages(
          categoryId: categoryId,
          simSlot: simSlot,
          bankName: bankName,
          searchQuery: searchQuery,
        ),
    };
  }

  @override
  Stream<List<MessageEntity>> watchStarred({
    int? simSlot,
    String? searchQuery,
  }) {
    return _watchFilteredMessages(
      isStarred: true,
      simSlot: simSlot,
      searchQuery: searchQuery,
    );
  }

  @override
  Stream<List<MessageEntity>> watchPinned({
    int? simSlot,
    String? searchQuery,
  }) {
    return _watchFilteredMessages(
      isPinned: true,
      simSlot: simSlot,
      searchQuery: searchQuery,
    );
  }

  @override
  Stream<List<MessageEntity>> watchBankTransactions({
    int? simSlot,
    String? bankName,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _watchFilteredMessages(
      categoryId: 'bank',
      simSlot: simSlot,
      bankName: bankName,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Stream<List<String>> watchDistinctBanks({int? simSlot}) {
    final simFilter = simSlot != null ? 'AND sim_slot = ?' : '';
    final variables = simSlot != null
        ? [Variable.withInt(simSlot)]
        : const <Variable<Object>>[];

    final query = _db.customSelect(
      '''
      SELECT
        bank_name,
        COUNT(*) AS tx_count,
        MAX(date) AS latest_date
      FROM messages
      WHERE primary_category = 'bank'
        AND bank_name IS NOT NULL
        AND TRIM(bank_name) != ''
        $simFilter
      GROUP BY bank_name
      ORDER BY tx_count DESC, latest_date DESC
      ''',
      variables: variables,
      readsFrom: {_db.messages},
    );

    return query.watch().map(
          (rows) => rows.map((row) => row.read<String>('bank_name')).toList(),
        );
  }

  @override
  Stream<List<MessageEntity>> watchBankBalanceMessages({
    int? simSlot,
    String? bankName,
  }) {
    final query = _db.select(_db.messages)
      ..where((t) {
        Expression<bool> predicate =
            t.primaryCategory.equals('bank') & t.balanceRial.isNotNull();
        if (simSlot != null) {
          predicate = predicate & t.simSlot.equals(simSlot);
        }
        if (bankName != null) {
          predicate = predicate & t.bankName.equals(bankName);
        }
        return predicate;
      })
      ..orderBy([
        (t) => OrderingTerm.desc(t.date),
        (t) => OrderingTerm.desc(t.smsId),
      ]);

    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<List<MessageEntity>> getBankMessagesNeedingBackfill() async {
    final rows = await (_db.select(_db.messages)
          ..where(
            (t) =>
                t.primaryCategory.equals('bank') &
                (t.bankName.isNull() |
                    (t.amountRial.isNotNull() & t.txType.isNull())),
          ))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> updateBankMetadataBatch(List<MessageEntity> updated) async {
    if (updated.isEmpty) return;
    await _db.transaction(() async {
      await _db.batch((batch) {
        for (final msg in updated) {
          batch.update(
            _db.messages,
            MessagesCompanion(
              amountRial: Value(msg.amountRial),
              txType: Value(msg.txType?.name),
              bankName: Value(msg.bankName),
              balanceRial: Value(msg.balanceRial),
              cardTail: Value(msg.cardTail),
            ),
            where: (t) => t.smsId.equals(msg.smsId),
          );
        }
      });
    });
  }

  @override
  Future<int> deleteBySmsIdRange(int minSmsId, int maxSmsId) async {
    return (_db.delete(_db.messages)
          ..where(
            (t) =>
                t.smsId.isBiggerOrEqualValue(minSmsId) &
                t.smsId.isSmallerOrEqualValue(maxSmsId),
          ))
        .go();
  }

  @override
  Stream<Map<String, CategoryCount>> watchCategoryCounts({int? simSlot}) {
    final whereClause = simSlot != null ? 'WHERE sim_slot = ?' : '';
    final variables = simSlot != null
        ? [Variable.withInt(simSlot)]
        : const <Variable<Object>>[];

    final categoryQuery = _db.customSelect(
      '''
      SELECT
        primary_category,
        COUNT(*) AS total_count,
        COALESCE(SUM(CASE WHEN is_read = 0 THEN 1 ELSE 0 END), 0) AS unread_count
      FROM messages
      $whereClause
      GROUP BY primary_category
      ''',
      variables: variables,
      readsFrom: {_db.messages},
    );

    final virtualQuery = _db.customSelect(
      '''
      SELECT
        COUNT(*) AS total_all,
        COALESCE(SUM(CASE WHEN is_read = 0 THEN 1 ELSE 0 END), 0) AS unread_all,
        COALESCE(SUM(CASE WHEN is_starred = 1 THEN 1 ELSE 0 END), 0) AS total_starred,
        COALESCE(SUM(CASE WHEN is_starred = 1 AND is_read = 0 THEN 1 ELSE 0 END), 0) AS unread_starred,
        COALESCE(SUM(CASE WHEN is_pinned = 1 THEN 1 ELSE 0 END), 0) AS total_pinned,
        COALESCE(SUM(CASE WHEN is_pinned = 1 AND is_read = 0 THEN 1 ELSE 0 END), 0) AS unread_pinned
      FROM messages
      $whereClause
      ''',
      variables: variables,
      readsFrom: {_db.messages},
    );

    return categoryQuery.watch().asyncMap((categoryRows) async {
      final result = <String, CategoryCount>{};
      for (final row in categoryRows) {
        final id = row.read<String>('primary_category');
        result[id] = CategoryCount(
          total: row.read<int>('total_count'),
          unread: row.read<int>('unread_count'),
        );
      }

      final virtualRow = await virtualQuery.getSingle();
      result['recent'] = CategoryCount(
        total: virtualRow.read<int>('total_all'),
        unread: virtualRow.read<int>('unread_all'),
      );
      result['starred'] = CategoryCount(
        total: virtualRow.read<int>('total_starred'),
        unread: virtualRow.read<int>('unread_starred'),
      );
      result['pinned'] = CategoryCount(
        total: virtualRow.read<int>('total_pinned'),
        unread: virtualRow.read<int>('unread_pinned'),
      );

      return result;
    });
  }

  @override
  Future<void> toggleStarred(int smsId, bool isStarred) async {
    await (_db.update(_db.messages)..where((t) => t.smsId.equals(smsId)))
        .write(MessagesCompanion(isStarred: Value(isStarred)));
  }

  @override
  Future<void> togglePinned(int smsId, bool isPinned) async {
    await (_db.update(_db.messages)..where((t) => t.smsId.equals(smsId)))
        .write(MessagesCompanion(isPinned: Value(isPinned)));
  }

  @override
  Future<void> markAsRead(int smsId) async {
    await (_db.update(_db.messages)..where((t) => t.smsId.equals(smsId)))
        .write(const MessagesCompanion(isRead: Value(true)));
  }

  @override
  Future<void> updateCategory(
    int smsId,
    String categoryId, {
    bool userOverride = true,
  }) async {
    await (_db.update(_db.messages)..where((t) => t.smsId.equals(smsId))).write(
      MessagesCompanion(
        primaryCategory: Value(categoryId),
        userOverride: Value(userOverride),
      ),
    );
  }

  Stream<List<MessageEntity>> _watchFilteredMessages({
    String? categoryId,
    bool? isStarred,
    bool? isPinned,
    int? simSlot,
    String? bankName,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    final query = _db.select(_db.messages)
      ..where((t) {
        Expression<bool> predicate = const Constant(true);

        if (categoryId != null) {
          predicate = predicate & t.primaryCategory.equals(categoryId);
        }
        if (isStarred != null) {
          predicate = predicate & t.isStarred.equals(isStarred);
        }
        if (isPinned != null) {
          predicate = predicate & t.isPinned.equals(isPinned);
        }
        if (simSlot != null) {
          predicate = predicate & t.simSlot.equals(simSlot);
        }
        if (bankName != null) {
          predicate = predicate & t.bankName.equals(bankName);
        }
        if (startDate != null) {
          predicate = predicate & t.date.isBiggerOrEqualValue(startDate);
        }
        if (endDate != null) {
          predicate = predicate & t.date.isSmallerOrEqualValue(endDate);
        }

        final trimmed = searchQuery?.trim() ?? '';
        if (trimmed.isNotEmpty) {
          predicate =
              predicate & (t.address.contains(trimmed) | t.body.contains(trimmed));
        }

        return predicate;
      })
      ..orderBy([
        (t) => OrderingTerm.desc(t.isPinned),
        (t) => OrderingTerm.desc(t.date),
      ]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  MessageEntity _mergeExistingFlags(MessageEntity incoming, Message? existing) {
    if (existing == null) return incoming;
    final keepUserCategory = existing.userOverride;
    return incoming.copyWith(
      isStarred: existing.isStarred,
      isPinned: existing.isPinned,
      isRead: existing.isRead || incoming.isRead,
      userOverride: existing.userOverride,
      primaryCategory:
          keepUserCategory ? existing.primaryCategory : incoming.primaryCategory,
    );
  }

  MessagesCompanion _toCompanion(MessageEntity entity) {
    return MessagesCompanion.insert(
      smsId: entity.smsId,
      address: entity.address,
      normalizedAddress: entity.normalizedAddress,
      body: entity.body,
      date: entity.date,
      isRead: Value(entity.isRead),
      simSlot: Value(entity.simSlot),
      senderType: Value(entity.senderType.name),
      primaryCategory: Value(entity.primaryCategory),
      isStarred: Value(entity.isStarred),
      isPinned: Value(entity.isPinned),
      amountRial: Value(entity.amountRial),
      txType: Value(entity.txType?.name),
      bankName: Value(entity.bankName),
      balanceRial: Value(entity.balanceRial),
      cardTail: Value(entity.cardTail),
      userOverride: Value(entity.userOverride),
    );
  }

  MessageEntity _toEntity(Message row) {
    return MessageEntity(
      id: row.id,
      smsId: row.smsId,
      address: row.address,
      normalizedAddress: row.normalizedAddress,
      body: row.body,
      date: row.date,
      isRead: row.isRead,
      simSlot: row.simSlot,
      senderType: _parseSenderType(row.senderType),
      primaryCategory: row.primaryCategory,
      isStarred: row.isStarred,
      isPinned: row.isPinned,
      amountRial: row.amountRial,
      txType: _parseTxType(row.txType),
      bankName: row.bankName,
      balanceRial: row.balanceRial,
      cardTail: row.cardTail,
      userOverride: row.userOverride,
    );
  }

  SenderType _parseSenderType(String raw) {
    for (final value in SenderType.values) {
      if (value.name == raw) return value;
    }
    return SenderType.service;
  }

  TransactionType? _parseTxType(String? raw) {
    if (raw == null) return null;
    for (final value in TransactionType.values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

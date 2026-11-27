import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Offline SQLite database powered by Drift for storing and querying SMS messages.
@DriftDatabase(tables: [Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'sms_manager_db'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(messages, messages.bankName);
            await m.addColumn(messages, messages.balanceRial);
            await m.addColumn(messages, messages.cardTail);
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_messages_bank_name ON messages (bank_name)',
            );
          }
        },
      );
}

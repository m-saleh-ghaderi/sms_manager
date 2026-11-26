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
  int get schemaVersion => 1;
}

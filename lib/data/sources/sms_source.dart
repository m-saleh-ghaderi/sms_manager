import '../../domain/entities/sms_entity.dart';

/// Abstract contract for reading SMS messages from the device storage.
///
/// Follows Dependency Inversion Principle (DIP):
/// Allows switching between Android ContentResolver, Telephony, or mock data sources
/// without modifying higher layer business logic.
abstract interface class SmsSource {
  /// Reads inbox SMS messages.
  ///
  /// If [afterSmsId] is provided, only messages with `_id > afterSmsId` are returned.
  /// [limit] defines the maximum batch size.
  Future<List<SmsEntity>> readInbox({int? afterSmsId, int limit = 100});

  /// Returns the total count of messages currently in the Inbox.
  Future<int> getInboxCount();
}

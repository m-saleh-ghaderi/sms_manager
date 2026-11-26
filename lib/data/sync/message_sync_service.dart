import '../../core/utils/phone_normalizer.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../sources/contacts_source.dart';
import '../sources/sms_source.dart';

/// Synchronizes SMS messages from the Android inbox into the local database.
///
/// Follows Single Responsibility Principle (SRP):
/// Coordinates reading new messages since the last imported `smsId`,
/// resolving sender types from contacts, and persisting them via [IMessageRepository].
/// In Phase 2.4, the offline rule-based classifier will plug into this pipeline.
class MessageSyncService {
  const MessageSyncService({
    required this.smsSource,
    required this.contactsSource,
    required this.messageRepository,
  });

  final SmsSource smsSource;
  final ContactsSource contactsSource;
  final IMessageRepository messageRepository;

  /// Imports new SMS messages from the device inbox into local SQLite.
  ///
  /// Returns the number of synced messages.
  Future<int> syncInbox({int batchLimit = 500}) async {
    final latestSmsId = await messageRepository.getLatestSmsId();
    final rawMessages = await smsSource.readInbox(
      afterSmsId: latestSmsId,
      limit: batchLimit,
    );

    if (rawMessages.isEmpty) {
      return 0;
    }

    final contactNumbers = await contactsSource.getNormalizedNumbers();

    final entities = rawMessages.map((sms) {
      final normalized = normalizePhone(sms.address);
      final senderType = detectSenderType(sms.address, contactNumbers);
      final initialCategory =
          senderType == SenderType.contact ? 'contacts' : 'unknown';

      return MessageEntity(
        smsId: sms.smsId,
        address: sms.address,
        normalizedAddress: normalized,
        body: sms.body,
        date: sms.date,
        isRead: sms.isRead,
        simSlot: sms.simSlot,
        senderType: senderType,
        primaryCategory: initialCategory,
      );
    }).toList();

    await messageRepository.upsertMessages(entities);
    return entities.length;
  }
}

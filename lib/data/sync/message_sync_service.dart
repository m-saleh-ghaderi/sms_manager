import '../../core/utils/phone_normalizer.dart';
import '../../domain/classifier/message_classifier.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../sources/contacts_source.dart';
import '../sources/sms_source.dart';

/// Synchronizes SMS messages from the Android inbox into the local database.
///
/// Follows Single Responsibility Principle (SRP):
/// Coordinates reading new messages since the last imported `smsId`,
/// resolving sender types from contacts, classifying with [MessageClassifier],
/// and persisting them via [IMessageRepository].
class MessageSyncService {
  const MessageSyncService({
    required this.smsSource,
    required this.contactsSource,
    required this.messageRepository,
    this.classifier = const MessageClassifier(),
  });

  final SmsSource smsSource;
  final ContactsSource contactsSource;
  final IMessageRepository messageRepository;
  final MessageClassifier classifier;

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

      // Contacts category is determined by sender type, not body classifier.
      if (senderType == SenderType.contact) {
        return MessageEntity(
          smsId: sms.smsId,
          address: sms.address,
          normalizedAddress: normalized,
          body: sms.body,
          date: sms.date,
          isRead: sms.isRead,
          simSlot: sms.simSlot,
          senderType: senderType,
          primaryCategory: 'contacts',
        );
      }

      // Run offline rule-based classifier on the message body.
      final result = classifier.classify(
        body: sms.body,
        senderAddress: sms.address,
      );

      return MessageEntity(
        smsId: sms.smsId,
        address: sms.address,
        normalizedAddress: normalized,
        body: sms.body,
        date: sms.date,
        isRead: sms.isRead,
        simSlot: sms.simSlot,
        senderType: senderType,
        primaryCategory: result.categoryId,
        amountRial: result.amountRial,
        txType: result.txType,
      );
    }).toList();

    await messageRepository.upsertMessages(entities);
    return entities.length;
  }
}

import '../../core/utils/phone_normalizer.dart';
import '../../domain/classifier/message_classifier.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/sms_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../sources/contacts_source.dart';
import '../sources/sms_event_source.dart';
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

    final entities = rawMessages
        .map((sms) => _buildEntity(sms, contactNumbers))
        .toList();

    await messageRepository.upsertMessages(entities);
    return entities.length;
  }

  /// Classifies and persists a single live-received SMS payload immediately.
  Future<MessageEntity> syncSingleMessage(IncomingSmsPayload payload) async {
    final resolvedSmsId = await _resolveIncomingSmsId(payload);
    final contactNumbers = await contactsSource.getNormalizedNumbers();

    final sms = SmsEntity(
      smsId: resolvedSmsId,
      address: payload.address,
      body: payload.body,
      date: payload.date,
      isRead: false,
      simSlot: payload.simSlot,
    );

    final entity = _buildEntity(sms, contactNumbers);
    await messageRepository.upsertMessages([entity]);
    return entity;
  }

  Future<int> _resolveIncomingSmsId(IncomingSmsPayload payload) async {
    final minDate = payload.date.subtract(const Duration(minutes: 1));
    const delays = [
      Duration(milliseconds: 250),
      Duration(milliseconds: 450),
    ];

    for (final delay in delays) {
      await Future<void>.delayed(delay);
      final foundId = await smsSource.findRecentSmsId(
        address: payload.address,
        body: payload.body,
        minDate: minDate,
      );
      if (foundId != null && foundId > 0) {
        return foundId;
      }
    }

    // Fallback temporary negative ID; cleaned up on the next batch syncInbox().
    final millis = payload.date.millisecondsSinceEpoch;
    return millis > 0 ? -millis : -DateTime.now().millisecondsSinceEpoch;
  }

  MessageEntity _buildEntity(SmsEntity sms, Set<String> contactNumbers) {
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
  }
}

import 'package:flutter/services.dart';

import '../../domain/entities/sms_entity.dart';
import 'sms_source.dart';

/// Android implementation of [SmsSource] communicating with native Kotlin
/// ContentResolver via MethodChannel.
///
/// Features:
/// - Fast native querying directly from `content://sms/inbox`
/// - Accurate dual-SIM detection via SubscriptionManager
/// - Robust error handling
class AndroidSmsSource implements SmsSource {
  const AndroidSmsSource({
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel('com.example.sms_manager/sms');

  final MethodChannel _channel;

  @override
  Future<List<SmsEntity>> readInbox({int? afterSmsId, int limit = 100}) async {
    try {
      final arguments = <String, dynamic>{'limit': limit};
      if (afterSmsId != null) {
        arguments['afterId'] = afterSmsId;
      }

      final result = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'getInboxSms',
        arguments,
      );

      if (result == null || result.isEmpty) {
        return const [];
      }

      return result.map((item) {
        final map = Map<String, dynamic>.from(item);
        final id = (map['id'] as num?)?.toInt() ?? 0;
        final address = map['address'] as String? ?? '';
        final body = map['body'] as String? ?? '';
        final dateEpoch = (map['date'] as num?)?.toInt() ?? 0;
        final isRead = map['isRead'] as bool? ?? false;
        final simSlot = (map['simSlot'] as num?)?.toInt();

        return SmsEntity(
          smsId: id,
          address: address,
          body: body,
          date: DateTime.fromMillisecondsSinceEpoch(dateEpoch),
          isRead: isRead,
          simSlot: simSlot,
        );
      }).toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to read SMS inbox: ${e.message}');
    }
  }

  @override
  Future<int> getInboxCount() async {
    try {
      final count = await _channel.invokeMethod<int>('getInboxCount');
      return count ?? 0;
    } on PlatformException catch (e) {
      throw Exception('Failed to get inbox count: ${e.message}');
    }
  }
}

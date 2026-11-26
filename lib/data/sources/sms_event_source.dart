import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Immutable raw payload emitted by the native Android `SmsBroadcastReceiver`
/// before its `_id` in Android's SMS ContentProvider is necessarily resolved.
@immutable
class IncomingSmsPayload {
  const IncomingSmsPayload({
    required this.address,
    required this.body,
    required this.date,
    this.simSlot,
  });

  final String address;
  final String body;
  final DateTime date;
  final int? simSlot;
}

/// Abstract stream source for real-time incoming SMS events (DIP).
abstract interface class ISmsEventSource {
  Stream<IncomingSmsPayload> get incomingSms;
}

/// Android [EventChannel] implementation listening to `com.example.sms_manager/sms_events`.
class AndroidSmsEventSource implements ISmsEventSource {
  AndroidSmsEventSource({
    EventChannel? eventChannel,
  }) : _eventChannel =
            eventChannel ?? const EventChannel('com.example.sms_manager/sms_events');

  final EventChannel _eventChannel;
  Stream<IncomingSmsPayload>? _broadcastStream;

  @override
  Stream<IncomingSmsPayload> get incomingSms {
    return _broadcastStream ??= _eventChannel
        .receiveBroadcastStream()
        .where((event) => event is Map)
        .map((event) {
          final map = Map<String, dynamic>.from(event as Map);
          final dateEpoch = (map['date'] as num?)?.toInt() ??
              DateTime.now().millisecondsSinceEpoch;
          return IncomingSmsPayload(
            address: map['address'] as String? ?? '',
            body: map['body'] as String? ?? '',
            date: DateTime.fromMillisecondsSinceEpoch(dateEpoch),
            simSlot: (map['simSlot'] as num?)?.toInt(),
          );
        })
        .asBroadcastStream();
  }
}

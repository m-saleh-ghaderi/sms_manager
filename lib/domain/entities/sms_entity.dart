import 'package:flutter/foundation.dart';

/// Immutable domain entity representing a raw SMS message from the device inbox.
///
/// Follows Clean Architecture: pure Dart entity with zero framework dependencies.
@immutable
class SmsEntity {
  const SmsEntity({
    required this.smsId,
    required this.address,
    required this.body,
    required this.date,
    required this.isRead,
    this.simSlot,
  });

  /// The unique `_id` of the message in the Android SMS provider.
  final int smsId;

  /// The sender phone number or alphanumeric service address.
  final String address;

  /// The raw text content of the SMS.
  final String body;

  /// The date and time the message was received.
  final DateTime date;

  /// Whether the message has already been read in the system.
  final bool isRead;

  /// The SIM card slot index (e.g. 1 for SIM 1, 2 for SIM 2).
  final int? simSlot;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmsEntity &&
          runtimeType == other.runtimeType &&
          smsId == other.smsId;

  @override
  int get hashCode => smsId.hashCode;

  @override
  String toString() =>
      'SmsEntity(smsId: $smsId, address: $address, date: $date, simSlot: $simSlot)';
}

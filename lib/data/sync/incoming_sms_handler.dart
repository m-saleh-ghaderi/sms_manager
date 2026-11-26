import 'dart:async';

import '../sources/sms_event_source.dart';
import 'message_sync_service.dart';

/// Listens to real-time incoming SMS events from Android and persists them
/// immediately through [MessageSyncService] so reactive Drift UI streams update live.
class IncomingSmsHandler {
  IncomingSmsHandler({
    required this.eventSource,
    required this.syncService,
  });

  final ISmsEventSource eventSource;
  final MessageSyncService syncService;

  StreamSubscription<IncomingSmsPayload>? _subscription;
  Future<void> _processingQueue = Future<void>.value();
  final Map<String, DateTime> _recentSignatures = {};

  /// Begins listening to live incoming SMS broadcasts (idempotent).
  void start() {
    if (_subscription != null) return;
    _subscription = eventSource.incomingSms.listen(
      _enqueuePayload,
      onError: (_) {
        // Keep listener alive across transient platform stream errors.
      },
    );
  }

  void _enqueuePayload(IncomingSmsPayload payload) {
    if (_isDuplicateBurst(payload)) return;
    _processingQueue = _processingQueue.then((_) async {
      try {
        await syncService.syncSingleMessage(payload);
      } catch (_) {
        // Fallback batch sync on Home resume will recover any failed live event.
      }
    });
  }

  bool _isDuplicateBurst(IncomingSmsPayload payload) {
    final now = DateTime.now();
    _recentSignatures.removeWhere(
      (_, seenAt) => now.difference(seenAt) > const Duration(seconds: 10),
    );
    final signature = '${payload.address}|${payload.body}';
    final previous = _recentSignatures[signature];
    if (previous != null &&
        now.difference(previous) < const Duration(seconds: 5)) {
      return true;
    }
    _recentSignatures[signature] = now;
    return false;
  }

  /// Cancels the platform event subscription.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

import '../../data/db/app_database.dart';
import '../../data/repositories/drift_message_repository.dart';
import '../../data/sources/android_sms_source.dart';
import '../../data/sources/contacts_source.dart';
import '../../data/sources/sms_event_source.dart';
import '../../data/sources/sms_source.dart';
import '../../data/sync/incoming_sms_handler.dart';
import '../../data/sync/message_sync_service.dart';
import '../../domain/repositories/message_repository.dart';
import '../theme/theme_controller.dart';

/// Lightweight dependency container for app-wide data services.
///
/// Centralizes lifecycle of the SQLite [AppDatabase], repositories, sync services,
/// and UI controllers prior to Riverpod integration in Phase 3.
class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.messageRepository,
    required this.smsSource,
    required this.smsEventSource,
    required this.contactsSource,
    required this.syncService,
    required this.incomingSmsHandler,
    required this.themeController,
  });

  static AppDependencies? _instance;

  /// Returns the shared [AppDependencies] singleton, creating it on demand.
  static AppDependencies get instance {
    return _instance ??= _createDefault();
  }

  static AppDependencies _createDefault() {
    final database = AppDatabase();
    final messageRepository = DriftMessageRepository(database);
    const smsSource = AndroidSmsSource();
    final smsEventSource = AndroidSmsEventSource();
    const contactsSource = ContactsSource();
    final syncService = MessageSyncService(
      smsSource: smsSource,
      contactsSource: contactsSource,
      messageRepository: messageRepository,
    );
    final incomingSmsHandler = IncomingSmsHandler(
      eventSource: smsEventSource,
      syncService: syncService,
    );
    final themeController = ThemeController();

    return AppDependencies._(
      database: database,
      messageRepository: messageRepository,
      smsSource: smsSource,
      smsEventSource: smsEventSource,
      contactsSource: contactsSource,
      syncService: syncService,
      incomingSmsHandler: incomingSmsHandler,
      themeController: themeController,
    );
  }

  final AppDatabase database;
  final IMessageRepository messageRepository;
  final SmsSource smsSource;
  final ISmsEventSource smsEventSource;
  final ContactsSource contactsSource;
  final MessageSyncService syncService;
  final IncomingSmsHandler incomingSmsHandler;
  final ThemeController themeController;
}

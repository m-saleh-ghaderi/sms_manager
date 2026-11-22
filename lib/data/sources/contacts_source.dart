import 'package:flutter_contacts/flutter_contacts.dart';

import '../../core/utils/phone_normalizer.dart';

/// Data source responsible for fetching saved phone contacts and normalizing them.
///
/// Follows Single Responsibility Principle (SRP):
/// Isolates contacts fetching logic from classification and presentation.
class ContactsSource {
  const ContactsSource();

  /// Retrieves all phone numbers from the device contacts in normalized format.
  Future<Set<String>> getNormalizedNumbers() async {
    try {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone},
      );

      final normalizedSet = <String>{};
      for (final contact in contacts) {
        for (final phone in contact.phones) {
          final normalized = normalizePhone(phone.number);
          if (normalized.isNotEmpty) {
            normalizedSet.add(normalized);
          }
        }
      }
      return normalizedSet;
    } catch (_) {
      // If contacts cannot be fetched (e.g. permission temporarily unavailable), return empty set
      return const <String>{};
    }
  }
}

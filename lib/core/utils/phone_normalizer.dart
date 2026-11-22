/// Normalizes Iranian and international phone numbers into standard format.
///
/// Example:
/// - `+989123456789` -> `09123456789`
/// - `00989123456789` -> `09123456789`
/// - `989123456789` -> `09123456789`
/// - `(0912) 345-6789` -> `09123456789`
String normalizePhone(String raw) {
  var s = raw.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
  if (s.startsWith('+98')) {
    s = '0${s.substring(3)}';
  } else if (s.startsWith('0098')) {
    s = '0${s.substring(4)}';
  } else if (s.startsWith('98') && s.length == 12) {
    s = '0${s.substring(2)}';
  }
  return s;
}

/// Identifies whether the sender address is a saved contact, personal number, or service code.
enum SenderType {
  contact,
  personal,
  service,
}

/// Detects the [SenderType] based on the sender's address and the saved contacts set.
SenderType detectSenderType(String address, Set<String> contactNumbers) {
  final normalized = normalizePhone(address);
  if (contactNumbers.contains(normalized)) {
    return SenderType.contact;
  }
  // If it's a standard Iranian mobile number (09xxxxxxxxx) but not in contacts
  return RegExp(r'^09\d{9}$').hasMatch(normalized)
      ? SenderType.personal
      : SenderType.service;
}

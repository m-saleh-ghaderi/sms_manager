import '../../core/utils/text_normalizer.dart';

/// Canonical metadata describing an Iranian bank or neobank.
class _BankSpec {
  const _BankSpec({
    required this.canonicalName,
    this.bodyPhrases = const [],
    this.senderTokens = const [],
    this.senderWordTokens = const [],
  });

  final String canonicalName;
  final List<String> bodyPhrases;
  final List<String> senderTokens;
  final List<String> senderWordTokens;
}

/// Identifies the canonical Persian bank name from an SMS sender address
/// and/or normalized message body.
abstract final class BankIdentifier {
  static const List<_BankSpec> _specs = [
    _BankSpec(
      canonicalName: 'بلوبانک',
      bodyPhrases: ['بلوبانک', 'بلو بانک', 'بلوجونیور'],
      senderTokens: ['blubank', 'blu-bank'],
      senderWordTokens: ['blu'],
    ),
    _BankSpec(
      canonicalName: 'ویپاد',
      bodyPhrases: ['ویپاد'],
      senderTokens: ['wepod'],
    ),
    _BankSpec(
      canonicalName: 'بانکینو',
      bodyPhrases: ['بانکینو'],
      senderTokens: ['bankino'],
    ),
    _BankSpec(
      canonicalName: 'بانک ملت',
      bodyPhrases: ['بانک ملت', 'بهپرداخت ملت'],
      senderTokens: ['mellat', 'bankmellat', 'mellatbank'],
    ),
    _BankSpec(
      canonicalName: 'بانک ملی',
      bodyPhrases: ['بانک ملی'],
      senderTokens: ['mellibank', 'bankmelli'],
      senderWordTokens: ['bmi', 'melli'],
    ),
    _BankSpec(
      canonicalName: 'بانک صادرات',
      bodyPhrases: ['بانک صادرات'],
      senderTokens: ['saderat', 'banksaderat'],
      senderWordTokens: ['bsi'],
    ),
    _BankSpec(
      canonicalName: 'بانک سامان',
      bodyPhrases: ['بانک سامان'],
      senderTokens: ['saman', 'banksaman', 'sb24'],
    ),
    _BankSpec(
      canonicalName: 'بانک پاسارگاد',
      bodyPhrases: ['بانک پاسارگاد'],
      senderTokens: ['pasargad', 'bankpasargad'],
      senderWordTokens: ['bpi'],
    ),
    _BankSpec(
      canonicalName: 'بانک تجارت',
      bodyPhrases: ['بانک تجارت'],
      senderTokens: ['tejarat', 'banktejarat'],
    ),
    _BankSpec(
      canonicalName: 'بانک سپه',
      bodyPhrases: ['بانک سپه'],
      senderTokens: ['sepah', 'banksepah'],
    ),
    _BankSpec(
      canonicalName: 'بانک مسکن',
      bodyPhrases: ['بانک مسکن'],
      senderTokens: ['maskan', 'bankmaskan'],
    ),
    _BankSpec(
      canonicalName: 'بانک کشاورزی',
      bodyPhrases: ['بانک کشاورزی'],
      senderTokens: ['keshavarzi', 'bki'],
    ),
    _BankSpec(
      canonicalName: 'بانک رفاه',
      bodyPhrases: ['بانک رفاه'],
      senderTokens: ['refah', 'bankrefah'],
    ),
    _BankSpec(
      canonicalName: 'بانک پارسیان',
      bodyPhrases: ['بانک پارسیان'],
      senderTokens: ['parsian', 'pec'],
    ),
    _BankSpec(
      canonicalName: 'بانک اقتصاد نوین',
      bodyPhrases: ['اقتصاد نوین', 'بانک اقتصاد'],
      senderTokens: ['eghtesad', 'enbank'],
    ),
    _BankSpec(
      canonicalName: 'بانک شهر',
      bodyPhrases: ['بانک شهر'],
      senderTokens: ['shahrbank', 'bankshahr'],
      senderWordTokens: ['shahr'],
    ),
    _BankSpec(
      canonicalName: 'بانک آینده',
      bodyPhrases: ['بانک اینده'],
      senderTokens: ['ayandeh', 'ba24'],
    ),
    _BankSpec(
      canonicalName: 'بانک دی',
      bodyPhrases: ['بانک دی'],
      senderTokens: ['daybank', 'bankdey'],
      senderWordTokens: ['dey'],
    ),
    _BankSpec(
      canonicalName: 'بانک سرمایه',
      bodyPhrases: ['بانک سرمایه'],
      senderTokens: ['sarmayeh', 'sarmaye'],
    ),
    _BankSpec(
      canonicalName: 'بانک رسالت',
      bodyPhrases: ['بانک رسالت', 'قرض الحسنه رسالت'],
      senderTokens: ['resalat', 'rqbank'],
    ),
    _BankSpec(
      canonicalName: 'بانک مهر ایران',
      bodyPhrases: ['بانک مهر ایران', 'قرض الحسنه مهر', 'بانک مهر'],
      senderTokens: ['mehriran', 'qmb'],
      senderWordTokens: ['mehr'],
    ),
    _BankSpec(
      canonicalName: 'بانک کارآفرین',
      bodyPhrases: ['بانک کارافرین'],
      senderTokens: ['karafarin'],
    ),
    _BankSpec(
      canonicalName: 'بانک سینا',
      bodyPhrases: ['بانک سینا'],
      senderTokens: ['sinabank', 'banksina'],
      senderWordTokens: ['sina'],
    ),
    _BankSpec(
      canonicalName: 'بانک گردشگری',
      bodyPhrases: ['بانک گردشگری'],
      senderTokens: ['gardeshgari', 'tourismbank'],
    ),
    _BankSpec(
      canonicalName: 'بانک ایران زمین',
      bodyPhrases: ['بانک ایران زمین', 'ایران زمین'],
      senderTokens: ['iranzamin', 'iran zamin', 'izbank'],
    ),
    _BankSpec(
      canonicalName: 'پست بانک',
      bodyPhrases: ['پست بانک'],
      senderTokens: ['postbank'],
    ),
    _BankSpec(
      canonicalName: 'بانک توسعه تعاون',
      bodyPhrases: ['توسعه تعاون'],
      senderTokens: ['ttbank'],
    ),
    _BankSpec(
      canonicalName: 'بانک خاورمیانه',
      bodyPhrases: ['بانک خاورمیانه'],
      senderTokens: ['middleeastbank', 'mebank'],
    ),
    _BankSpec(
      canonicalName: 'بانک صنعت و معدن',
      bodyPhrases: ['بانک صنعت'],
      senderWordTokens: ['sanat', 'bim'],
    ),
    _BankSpec(
      canonicalName: 'بانک انصار',
      bodyPhrases: ['بانک انصار'],
      senderWordTokens: ['ansar'],
    ),
    _BankSpec(
      canonicalName: 'بانک حکمت',
      bodyPhrases: ['بانک حکمت'],
      senderWordTokens: ['hekmat'],
    ),
  ];

  /// Checks whether [word] matches on token boundaries in normalized [text].
  static bool containsWord(String text, String word) {
    final pattern = RegExp(
      '(?<![\\u0621-\\u064A\\u067E\\u0686\\u0698\\u06AF\\u06A9\\u06CCa-z0-9])${RegExp.escape(word)}(?![\\u0621-\\u064A\\u067E\\u0686\\u0698\\u06AF\\u06A9\\u06CCa-z0-9])',
    );
    return pattern.hasMatch(text);
  }

  /// Returns the matched canonical Iranian bank name, or `null` if no known
  /// bank signature appears in [normalizedText] or [normalizedAddress].
  static String? matchKnownBank({
    required String normalizedText,
    required String normalizedAddress,
  }) {
    // 1. Check bank names mentioned in the SMS body (handles numeric short codes like 30001414).
    for (final spec in _specs) {
      for (final phrase in spec.bodyPhrases) {
        if (normalizedText.contains(phrase)) {
          return spec.canonicalName;
        }
      }
    }

    // 2. Check distinctive bank sender identifiers.
    for (final spec in _specs) {
      for (final token in spec.senderTokens) {
        if (normalizedAddress.contains(token)) {
          return spec.canonicalName;
        }
      }
      for (final word in spec.senderWordTokens) {
        if (containsWord(normalizedAddress, word) ||
            normalizedAddress.contains('bank$word') ||
            normalizedAddress.contains('${word}bank')) {
          return spec.canonicalName;
        }
      }
    }

    return null;
  }

  /// Resolves a canonical bank label for an SMS already classified as `'bank'`.
  ///
  /// Falls back to a cleaned sender address so unknown/custom bank short codes
  /// still appear distinctly in the user's bank filter.
  static String resolveBankName({
    required String rawBody,
    required String rawAddress,
  }) {
    final normalizedText = normalizeText(rawBody);
    final normalizedAddress = normalizeText(rawAddress);

    final known = matchKnownBank(
      normalizedText: normalizedText,
      normalizedAddress: normalizedAddress,
    );
    if (known != null) {
      return known;
    }

    final trimmed = rawAddress.trim();
    return trimmed.isNotEmpty ? trimmed : 'سایر بانک‌ها';
  }
}

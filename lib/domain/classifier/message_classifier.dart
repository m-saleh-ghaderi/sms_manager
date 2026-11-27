import 'package:flutter/foundation.dart';

import '../../core/utils/text_normalizer.dart';
import '../entities/message_entity.dart';
import 'bank_identifier.dart';

/// Result of classifying a single SMS message.
@immutable
class ClassificationResult {
  const ClassificationResult({
    required this.categoryId,
    this.amountRial,
    this.txType,
    this.bankName,
    this.balanceRial,
    this.cardTail,
  });

  /// The primary category ID (e.g. `'bank'`, `'otp'`).
  final String categoryId;

  /// Parsed transaction amount in Rials (bank messages only).
  final int? amountRial;

  /// Credit or debit direction (bank messages only).
  final TransactionType? txType;

  /// Canonical Persian bank name or sender label (bank messages only).
  final String? bankName;

  /// Latest account/card balance in Rials extracted from `مانده` / `موجودی` (bank messages only).
  final int? balanceRial;

  /// Last 4 digits of card/account number when present (e.g. `'4532'`).
  final String? cardTail;

  @override
  String toString() =>
      'ClassificationResult(cat: $categoryId, bank: $bankName, amount: $amountRial, balance: $balanceRial, card: $cardTail, tx: $txType)';
}

/// Offline rule-based classifier for Iranian SMS messages.
///
/// Classifies messages into one of 12 automatic categories based on
/// keyword phrases, regex patterns, and sender address heuristics.
/// Categories `contacts`, `recent`, `starred`, and `pinned` are
/// handled elsewhere (by sender type or user action).
///
/// Rule priority: OTP → Bank → Bill → Government → Operator →
/// Order → Travel → Discount → Suspicious → Promo → Unknown.
class MessageClassifier {
  const MessageClassifier();

  /// Classifies a single SMS based on its [body] and [senderAddress].
  ClassificationResult classify({
    required String body,
    required String senderAddress,
  }) {
    final text = normalizeText(body);
    final addr = normalizeText(senderAddress);

    // ── 1. OTP / Verification Code (highest priority) ──
    if (_matchesOtp(text)) {
      return const ClassificationResult(categoryId: 'otp');
    }

    // ── 1.5. Strong Phishing / Scam Signals ──
    // Catch phishing attempts even if they impersonate banks, government, or short codes.
    if (_hasStrongPhishingSignal(text)) {
      return const ClassificationResult(categoryId: 'suspicious');
    }

    // ── 2. Bank / Financial ──
    final bankResult = _matchesBank(
      text: text,
      addr: addr,
      rawBody: body,
      rawAddress: senderAddress,
    );
    if (bankResult != null) {
      return bankResult;
    }

    // ── 3. Bill / Utility ──
    if (_matchesBill(text, addr)) {
      return const ClassificationResult(categoryId: 'bill');
    }

    // ── 4. Government / Public Services ──
    if (_matchesGovernment(text, addr)) {
      return const ClassificationResult(categoryId: 'government');
    }

    // ── 5. Telecom Operator ──
    if (_matchesOperator(text, addr)) {
      return const ClassificationResult(categoryId: 'operator');
    }

    // ── 6. Order / Delivery ──
    if (_matchesOrder(text, addr)) {
      return const ClassificationResult(categoryId: 'order');
    }

    // ── 7. Travel / Booking ──
    if (_matchesTravel(text, addr)) {
      return const ClassificationResult(categoryId: 'travel');
    }

    // ── 8. Discount / Coupon ──
    if (_matchesDiscount(text)) {
      return const ClassificationResult(categoryId: 'discount');
    }

    // ── 9. Suspicious / Phishing ──
    if (_matchesSuspicious(text)) {
      return const ClassificationResult(categoryId: 'suspicious');
    }

    // ── 10. Promotional / Advertising ──
    if (_matchesPromo(text, addr)) {
      return const ClassificationResult(categoryId: 'promo');
    }

    // ── Fallback ──
    return const ClassificationResult(categoryId: 'unknown');
  }

  /// Checks whether [word] appears as a standalone token in [text]
  /// (not as a substring inside another word, e.g. "پایا" in "پایان").
  static bool _containsWord(String text, String word) =>
      BankIdentifier.containsWord(text, word);

  // ─────────────────────────── OTP ───────────────────────────

  static const _otpPhrases = [
    'رمز یکبار',
    'رمز يکبار',
    'رمز پویا',
    'رمز پويا',
    'کد تایید',
    'کد تائید',
    'کد فعالسازی',
    'کد فعال سازی',
    'کد احراز',
    'کد ورود',
    'کد تغییر',
    'کد بازیابی',
    'کد عملیات',
    'رمز دوم',
    'رمز عملیات',
    'verification code',
    'your code is',
    'your code:',
    'otp',
    'one-time',
    'one time password',
    'login code',
    'security code',
    'verify code',
    'confirmation code',
    'activation code',
    'auth code',
  ];

  static final _otpRegex = RegExp(
    r'(?:code|کد|رمز)\s*[:=]?\s*\d{4,8}',
    caseSensitive: false,
  );

  bool _matchesOtp(String text) {
    for (final phrase in _otpPhrases) {
      if (text.contains(phrase)) return true;
    }
    return _otpRegex.hasMatch(text);
  }

  // ─────────────────────────── BANK ───────────────────────────

  static const _bankPhrases = [
    'واریز',
    'برداشت',
    'موجودی',
    'مانده حساب',
    'مانده:',
    'کارت بانک',
    'حساب بانک',
    'تراکنش',
    'انتقال وجه',
    'انتقال کارت',
    'خرید از',
    'خرید اینترنتی',
    'قسط',
    'سپرده',
    'سود سپرده',
    'صورتحساب بانک',
    'کارت به کارت',
    'ساتنا',
  ];

  /// Short bank terms that can appear as substrings in unrelated words
  /// (e.g. "پایا" in "پایان", "وام" in "دوام", "شبا" in "شبانه").
  static const _bankWordPhrases = [
    'پایا',
    'شبا',
    'وام',
  ];

  /// Regex matching card numbers like *1234, **1234, ***1234, ****1234
  static final _cardStarRegex = RegExp(r'\*{1,4}(\d{4})');

  /// Regex matching masked 16-digit PAN like `6037-****-****-4532` or `کارت 4532`
  static final _cardKeywordRegex = RegExp(
    r'(?:\b\d{4}[-\s*]{1,4}(?:\*{4}|x{4})[-\s*]{1,4}(\d{4})\b|(?:کارت|حساب)\s*[:=]?\s*\*?(\d{4})(?!\d|\s*(?:ریال|ريال|تومان|تومن)))',
  );

  /// Regex for Rial/Toman amounts like "1,500,000 ریال" or "150,000 تومان"
  static final _amountRegex = RegExp(
    r'(?:مبلغ|مقدار|مبلغ:?)?\s*([0-9][0-9,\.]*)\s*(?:ریال|ريال|تومان|تومن|rials?|tomans?)',
    caseSensitive: false,
  );

  /// Regex extracting balance after `مانده` / `موجودی` (with optional trailing Rial/Toman).
  static final _balanceRegex = RegExp(
    r'(?:مانده(?:\s+حساب|\s+قابل\s+برداشت|\s+فعلی)?|موجودی(?:\s+حساب|\s+فعلی)?|balance|bal)\s*[:=\-]?\s*([0-9][0-9,\.]*)(?:\s*(ریال|ريال|تومان|تومن|rials?|tomans?))?',
    caseSensitive: false,
  );

  ClassificationResult? _matchesBank({
    required String text,
    required String addr,
    required String rawBody,
    required String rawAddress,
  }) {
    final knownBank = BankIdentifier.matchKnownBank(
      normalizedText: text,
      normalizedAddress: addr,
    );
    var isBank = knownBank != null;

    if (!isBank && _containsWord(addr, 'بانک')) {
      isBank = true;
    }

    // Check bank action phrases in body
    if (!isBank) {
      for (final phrase in _bankPhrases) {
        if (text.contains(phrase)) {
          isBank = true;
          break;
        }
      }
    }

    // Check short bank terms with word boundaries
    if (!isBank) {
      for (final word in _bankWordPhrases) {
        if (_containsWord(text, word)) {
          isBank = true;
          break;
        }
      }
    }

    // Check card tail pattern
    if (!isBank && _cardStarRegex.hasMatch(text)) {
      isBank = true;
    }

    if (!isBank) return null;

    final tx = _parseTransaction(text);
    final balanceRial = _parseBalance(text);
    final cardTail = _parseCardTail(text);
    final bankName = knownBank ??
        BankIdentifier.resolveBankName(rawBody: rawBody, rawAddress: rawAddress);

    return ClassificationResult(
      categoryId: 'bank',
      amountRial: tx?.amountRial,
      txType: tx?.txType,
      bankName: bankName,
      balanceRial: balanceRial,
      cardTail: cardTail,
    );
  }

  // ─────────────────────────── BILL ───────────────────────────

  static const _billPhrases = [
    'قبض',
    'اببها',
    'برقبها',
    'گازبها',
    'تلفن ثابت',
    'عوارض',
    'شناسه قبض',
    'شناسه پرداخت',
    'بدهی قبض',
    'مبلغ قبض',
    'قبوض',
    'صورتحساب برق',
    'صورتحساب اب',
    'صورتحساب گاز',
    'صورتحساب تلفن',
    'خلافی خودرو',
    'عوارض خودرو',
    'بیمه شخص ثالث',
    'جریمه',
  ];

  bool _matchesBill(String text, String addr) {
    for (final phrase in _billPhrases) {
      if (text.contains(phrase)) return true;
    }
    return false;
  }

  // ────────────────────── GOVERNMENT ──────────────────────────

  static const _govPhrases = [
    'سامانه ثنا',
    'قوه قضاییه',
    'قوه قضائیه',
    'ابلاغیه',
    'سازمان ثبت',
    'ثبت احوال',
    'اداره مالیات',
    'سازمان مالیاتی',
    'مالیات بر ارزش',
    'بیمه تامین',
    'تامین اجتماعی',
    'سازمان بهزیستی',
    'سجام',
    'کد بورسی',
    'نیروی انتظامی',
    'پلیس فتا',
    'ناجا',
    'سازمان سنجش',
    'وزارت',
    'فرمانداری',
    'استانداری',
    'شهرداری',
    'دادگاه',
    'دادسرا',
    'پزشکی قانونی',
    'سازمان بورس',
    'بانک مرکزی',
    'سازمان امور',
  ];

  static const _govWordPhrases = [
    'ثنا',
  ];

  static const _govSenders = [
    'adliran', 'sana', 'epolice', 'dolat', 'gov', 'sanjesh', 'shahrdari',
  ];

  static const _govShortCodes = [
    '141', '110', '112', '114', '115', '123', '125',
  ];

  bool _matchesGovernment(String text, String addr) {
    for (final phrase in _govPhrases) {
      if (text.contains(phrase)) return true;
    }
    for (final word in _govWordPhrases) {
      if (_containsWord(text, word)) return true;
    }
    for (final sender in _govSenders) {
      if (_containsWord(addr, sender)) return true;
    }
    for (final code in _govShortCodes) {
      if (addr == code) return true;
    }
    return false;
  }

  // ─────────────────────── OPERATOR ──────────────────────────

  static const _operatorPhrases = [
    'ایرانسل',
    'همراه اول',
    'رایتل',
    'شاتل موبایل',
    'بسته اینترنت',
    'بسته مکالمه',
    'ترافیک اینترنت',
    'حجم باقیمانده',
    'حجم رایگان',
    'شارژ',
    'اعتبار حساب',
    'اعتبار شما',
    'مگابایت',
    'گیگابایت',
    'مکالمه رایگان',
    'سرویس پیامکی',
    'سرویس ارزش',
    'خط اختصاصی',
    'مخابرات',
  ];

  static const _operatorSenders = [
    'irancell', 'mci', 'mtn', 'rightel', 'shatel',
    '100', '1000', '2000',
  ];

  bool _matchesOperator(String text, String addr) {
    for (final phrase in _operatorPhrases) {
      if (text.contains(phrase)) return true;
    }
    for (final sender in _operatorSenders) {
      if (addr == sender || addr.startsWith('$sender ')) return true;
    }
    return false;
  }

  // ─────────────────────── ORDER ─────────────────────────────

  static const _orderPhrases = [
    'سفارش',
    'مرسوله',
    'بسته پستی',
    'ارسال بسته',
    'تحویل بسته',
    'کد رهگیری',
    'کد پیگیری',
    'پست پیشتاز',
    'تیپاکس',
    'پست سفارشی',
    'مرجوعی',
    'بازگشت مرسوله',
    'tracking',
    'ارسال شد',
    'تحویل داده شد',
    'در حال ارسال',
    'در مسیر تحویل',
    'ارسال از انبار',
    'صندوق پستی',
  ];

  static const _orderSenders = [
    'digikala', 'snappfood', 'tap30', 'divar', 'basalam',
    'torob', 'emalls', 'bamilo', 'takhfifan', 'netbarg',
    'snappbox', 'snappexpress', 'alopeyk', 'miare', 'post',
    'tipax',
  ];

  bool _matchesOrder(String text, String addr) {
    for (final phrase in _orderPhrases) {
      if (text.contains(phrase)) return true;
    }
    for (final sender in _orderSenders) {
      if (addr.contains(sender)) return true;
    }
    return false;
  }

  // ─────────────────────── TRAVEL ────────────────────────────

  static const _travelPhrases = [
    'پرواز',
    'بلیط هواپیما',
    'بلیط قطار',
    'بلیط اتوبوس',
    'رزرو هتل',
    'اقامتگاه',
    'فرودگاه',
    'ترمینال',
    'گیت پرواز',
    'بوردینگ',
    'boarding',
    'check-in',
    'چک-این',
    'ویزا',
    'پاسپورت',
    'گذرنامه',
  ];

  static const _travelSenders = [
    'alibaba', 'flytoday', 'snapptrip', 'trip.com',
    'jabama', 'shab.ir', 'hotelyar', 'iran air',
    'mahan', 'kish air', 'aseman', 'ata', 'caspian',
    'meraj', 'taban', 'varesh', 'zagros', 'qeshm air',
    'safarme', 'flightio', 'ghasedak24', 'charter',
    'safar724', 'mrbilit',
  ];

  bool _matchesTravel(String text, String addr) {
    for (final phrase in _travelPhrases) {
      if (text.contains(phrase)) return true;
    }
    for (final sender in _travelSenders) {
      if (addr.contains(sender)) return true;
    }
    return false;
  }

  // ─────────────────────── DISCOUNT ──────────────────────────

  static const _discountPhrases = [
    'کد تخفیف',
    'کوپن',
    'voucher',
    'coupon',
    'درصد تخفیف',
    'تخفیف ویژه',
    'بن تخفیف',
    'بن خرید',
    'اعتبار هدیه',
    'هدیه تخفیف',
  ];

  /// Matches "50% off" or "۳۰٪ تخفیف" etc.
  static final _discountPercentRegex = RegExp(
    r'\d{1,3}\s*[%٪]\s*(?:off|تخفیف)',
    caseSensitive: false,
  );

  bool _matchesDiscount(String text) {
    for (final phrase in _discountPhrases) {
      if (text.contains(phrase)) return true;
    }
    return _discountPercentRegex.hasMatch(text);
  }

  // ─────────────────────── SUSPICIOUS ────────────────────────

  /// High-confidence phishing signals checked before bank/government rules.
  static const _strongPhishingPhrases = [
    'برنده شدید',
    'برنده شده اید',
    'حساب شما مسدود',
    'برای جلوگیری از مسدود',
    'فیشینگ',
    'ارز دیجیتال رایگان',
    'سرمایهگذاری با سود',
    'سود تضمینی',
    'درامد میلیونی',
    'درامد روزانه',
    'کلیک کنید',
    'click here',
  ];

  static const _suspiciousPhrases = [
    ..._strongPhishingPhrases,
    'جایزه',
    'حساب مسدود',
    'بروزرسانی اطلاعات',
    'کسب درامد',
  ];

  /// Short links often used for phishing
  static final _suspiciousLinkRegex = RegExp(
    r'https?://(?:bit\.ly|goo\.gl|t\.co|is\.gd|rb\.gy|tinyurl|v\.gd|ow\.ly)/\S+',
    caseSensitive: false,
  );

  bool _hasStrongPhishingSignal(String text) {
    for (final phrase in _strongPhishingPhrases) {
      if (text.contains(phrase)) return true;
    }
    if (_suspiciousLinkRegex.hasMatch(text)) {
      const urgency = ['فوری', 'urgent', 'اکنون', 'سریع', 'همین الان', 'مسدود', 'ابلاغیه'];
      for (final word in urgency) {
        if (text.contains(word)) return true;
      }
    }
    return false;
  }

  bool _matchesSuspicious(String text) {
    for (final phrase in _suspiciousPhrases) {
      if (text.contains(phrase)) return true;
    }
    return _suspiciousLinkRegex.hasMatch(text);
  }

  // ─────────────────────── PROMO ─────────────────────────────

  static const _promoPhrases = [
    'تبلیغ',
    'پیشنهاد ویژه',
    'فروش ویژه',
    'جشنواره',
    'حراج',
    'فروش فوقالعاده',
    'فروش فوق العاده',
    'عضویت',
    'معرفی محصول',
    'ارسال رایگان',
    'نصب اپلیکیشن',
    'دانلود',
    'ثبت نام رایگان',
    'لغو ارسال 11',
    'لغو11',
    'لغو ارسال',
    'عدم دریافت',
    'unsub',
    'unsubscribe',
    'opt out',
    'opt-out',
    'بازاریابی',
    'همکاری در فروش',
    'نمایندگی',
  ];

  bool _matchesPromo(String text, String addr) {
    for (final phrase in _promoPhrases) {
      if (text.contains(phrase)) return true;
    }
    // Senders that are known promo channels
    if (addr.length <= 8 && RegExp(r'^\d+$').hasMatch(addr) && !_isKnownGovNumber(addr)) {
      // 4-8 digit short codes that aren't known gov/bank are often promo
      // But we can't be sure, so only flag if body also hints at marketing
      if (text.contains('خرید') || text.contains('فروش') || text.contains('محصول')) {
        return true;
      }
    }
    return false;
  }

  bool _isKnownGovNumber(String addr) {
    const govNumbers = {'110', '112', '114', '115', '123', '125', '141'};
    return govNumbers.contains(addr);
  }

  // ─────────────────── TRANSACTION PARSER ────────────────────

  _TransactionInfo? _parseTransaction(String text) {
    // Detect direction
    TransactionType? txType;
    if (text.contains('واریز') ||
        text.contains('واريز') ||
        text.contains('دریافت') ||
        text.contains('بستانکار') ||
        text.contains('deposit') ||
        text.contains('credit')) {
      txType = TransactionType.credit;
    } else if (text.contains('برداشت') ||
        text.contains('خرید') ||
        text.contains('خريد') ||
        text.contains('بدهکار') ||
        text.contains('کسر') ||
        text.contains('withdraw') ||
        text.contains('debit') ||
        text.contains('purchase')) {
      txType = TransactionType.debit;
    }

    // Extract amount (prefer an amount not preceded by balance keywords like مانده/موجودی)
    final matches = _amountRegex.allMatches(text).toList();
    if (matches.isEmpty) return null;

    RegExpMatch? selectedMatch;
    for (final m in matches) {
      final prefixStart = m.start >= 16 ? m.start - 16 : 0;
      final prefix = text.substring(prefixStart, m.start);
      final isBalance = prefix.contains('مانده') || prefix.contains('موجودی');
      if (!isBalance) {
        selectedMatch = m;
        break;
      }
    }
    final match = selectedMatch ?? matches.first;

    final rawAmount = match.group(1) ?? '';
    final cleanedAmount = rawAmount.replaceAll(RegExp(r'[,\.]'), '');
    final amount = int.tryParse(cleanedAmount);
    if (amount == null || amount <= 0) return null;

    // If unit is Toman, convert to Rial
    final unitPart = text.substring(match.start, match.end).toLowerCase();
    final isToman = unitPart.contains('تومان') ||
        unitPart.contains('تومن') ||
        unitPart.contains('toman');
    final amountRial = isToman ? amount * 10 : amount;

    return _TransactionInfo(
      amountRial: amountRial,
      txType: txType,
    );
  }

  int? _parseBalance(String text) {
    final match = _balanceRegex.firstMatch(text);
    if (match == null) return null;

    final rawAmount = (match.group(1) ?? '').replaceAll(RegExp(r'[,\.]+$'), '');
    final cleanedAmount = rawAmount.replaceAll(RegExp(r'[,\.]'), '');
    final amount = int.tryParse(cleanedAmount);
    if (amount == null || amount < 0) return null;

    final unit = (match.group(2) ?? '').toLowerCase();
    final isToman =
        unit.contains('تومان') || unit.contains('تومن') || unit.contains('toman');
    return isToman ? amount * 10 : amount;
  }

  String? _parseCardTail(String text) {
    final starMatch = _cardStarRegex.firstMatch(text);
    if (starMatch != null) return starMatch.group(1);

    final keywordMatch = _cardKeywordRegex.firstMatch(text);
    if (keywordMatch != null) {
      return keywordMatch.group(1) ?? keywordMatch.group(2);
    }
    return null;
  }
}

class _TransactionInfo {
  const _TransactionInfo({required this.amountRial, this.txType});
  final int amountRial;
  final TransactionType? txType;
}

import '../../domain/classifier/message_classifier.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import 'jalali_date.dart';
import 'phone_normalizer.dart';

/// Generates 50 realistic multi-month Persian bank SMS records for local QA/testing.
///
/// Only intended for `kDebugMode` testing across 10 Iranian banks,
/// 12 Shamsi months, dual-SIM slots, and multi-card balances without altering
/// real Android provider `smsId > 0` sync watermarks.
class DebugBankSmsSeeder {
  const DebugBankSmsSeeder({
    required this.repository,
    this.classifier = const MessageClassifier(),
  });

  static const int minDemoSmsId = -999999;
  static const int maxDemoSmsId = -900001;

  final IMessageRepository repository;
  final MessageClassifier classifier;

  /// Inserts or refreshes 50 realistic bank SMS spanning 12 Shamsi months and 10 banks.
  Future<int> seedSampleBankData() async {
    final now = DateTime.now();
    final currentMonth = JalaliDate.fromDateTime(now).startOfMonth;

    DateTime dateInOffsetMonth(int monthOffset, int day, int hour, int minute) {
      final targetMonth = currentMonth.addMonths(monthOffset);
      final clampedDay = day.clamp(
        1,
        JalaliDate.daysInMonth(targetMonth.year, targetMonth.month),
      );
      return JalaliDate(targetMonth.year, targetMonth.month, clampedDay)
          .toDateTime(hour: hour, minute: minute);
    }

    final samples = <({
      int smsId,
      String address,
      String body,
      DateTime date,
      int simSlot,
    })>[
      // ── ماه -11 (دی سال قبل) ──
      (
        smsId: -900001,
        address: 'BankMellat',
        body: 'واریز حقوق به حساب *4532 مبلغ 185,000,000 ریال مانده 210,000,000 ریال',
        date: dateInOffsetMonth(-11, 2, 9, 10),
        simSlot: 1,
      ),
      (
        smsId: -900002,
        address: 'Tejarat',
        body: 'بانک تجارت\nبرداشت 19,500,000 ریال از کارت *5401\nمانده: 45,000,000 ریال',
        date: dateInOffsetMonth(-11, 14, 16, 20),
        simSlot: 1,
      ),
      (
        smsId: -900003,
        address: 'BluBank',
        body: 'بلوبانک\nواریز ۵٬۵۰۰٬۰۰۰ تومان به *3318\nموجودی: ۱۲٬۳۰۰٬۰۰۰ تومان',
        date: dateInOffsetMonth(-11, 25, 11, 45),
        simSlot: 2,
      ),
      // ── ماه -10 (بهمن سال قبل) ──
      (
        smsId: -900004,
        address: 'BMI',
        body: 'بانک ملی ایران\nواریز: 120,000,000 ریال به *7700\nمانده: 175,000,000 ریال',
        date: dateInOffsetMonth(-10, 4, 10, 0),
        simSlot: 1,
      ),
      (
        smsId: -900005,
        address: 'BankSepah',
        body: 'بانک سپه\nبرداشت خرید: 14,200,000 ریال کارت *6610\nمانده 52,800,000',
        date: dateInOffsetMonth(-10, 17, 19, 30),
        simSlot: 1,
      ),
      (
        smsId: -900006,
        address: 'BluBank',
        body: 'بلوبانک\nخرید اینترنتی ۲٬۹۰۰٬۰۰۰ تومان از *3318\nموجودی: ۹٬۴۰۰٬۰۰۰ تومان',
        date: dateInOffsetMonth(-10, 26, 21, 15),
        simSlot: 2,
      ),
      // ── ماه -9 (اسفند سال قبل) ──
      (
        smsId: -900007,
        address: 'BankMellat',
        body: 'واریز عیدی و حقوق *4532 مبلغ 290,000,000 ریال مانده 380,000,000 ریال',
        date: dateInOffsetMonth(-9, 3, 9, 40),
        simSlot: 1,
      ),
      (
        smsId: -900008,
        address: '30001414',
        body: 'بانک ملت\nخرید شب عید مبلغ 42,000,000 ریال کارت *9911\nمانده 68,500,000',
        date: dateInOffsetMonth(-9, 15, 18, 55),
        simSlot: 1,
      ),
      (
        smsId: -900009,
        address: 'BankSaman',
        body: 'بانک سامان\nانتقال وجه: 33,000,000 ریال از *8811\nمانده: 78,000,000 ریال',
        date: dateInOffsetMonth(-9, 22, 13, 12),
        simSlot: 2,
      ),
      (
        smsId: -900010,
        address: 'BPI',
        body: 'بانک پاسارگاد\nواریز وجه 90,000,000 ریال کارت *5022\nمانده: 120,000,000 ریال',
        date: dateInOffsetMonth(-9, 28, 12, 5),
        simSlot: 1,
      ),
      // ── ماه -8 (فروردین) ──
      (
        smsId: -900011,
        address: 'Wepod',
        body: 'ویپاد\nواریز ۶٬۰۰۰٬۰۰۰ تومن به *2190\nموجودی: ۹٬۸۰۰٬۰۰۰ تومن',
        date: dateInOffsetMonth(-8, 6, 15, 30),
        simSlot: 2,
      ),
      (
        smsId: -900012,
        address: '+9830009111',
        body: 'بانک ملی\nمبلغ 26,000,000- ریال از کارت *7700\nمانده: 149,000,000 ریال',
        date: dateInOffsetMonth(-8, 14, 17, 10),
        simSlot: 1,
      ),
      (
        smsId: -900013,
        address: 'Tejarat',
        body: 'بانک تجارت\nواریز 80,000,000 ریال به حساب *5401\nمانده: 125,000,000 ریال',
        date: dateInOffsetMonth(-8, 23, 10, 45),
        simSlot: 1,
      ),
      // ── ماه -7 (اردیبهشت) ──
      (
        smsId: -900014,
        address: 'BankMellat',
        body: 'واریز به حساب *4532 مبلغ 210,000,000 ریال مانده 320,000,000 ریال',
        date: dateInOffsetMonth(-7, 2, 9, 20),
        simSlot: 1,
      ),
      (
        smsId: -900015,
        address: '10008520',
        body: 'بانک صادرات ایران\nپرداخت قبض 7,800,000 ریال از *6104\nمانده ۷۲٬۲۰۰٬۰۰۰ ریال',
        date: dateInOffsetMonth(-7, 11, 14, 5),
        simSlot: 1,
      ),
      (
        smsId: -900016,
        address: 'BankSepah',
        body: 'بانک سپه\nواریز 55,000,000 ریال به کارت *6610\nمانده 107,800,000 ریال',
        date: dateInOffsetMonth(-7, 19, 11, 30),
        simSlot: 1,
      ),
      (
        smsId: -900017,
        address: 'Keshavarzi',
        body: 'بانک کشاورزی\nبرداشت 16,500,000 ریال از *1145\nمانده: 48,000,000 ریال',
        date: dateInOffsetMonth(-7, 27, 16, 40),
        simSlot: 1,
      ),
      // ── ماه -6 (خرداد) ──
      (
        smsId: -900018,
        address: 'BankMellat',
        body: 'واریز حقوق مبلغ 220,000,000 ریال به حساب *4532 مانده 365,000,000 ریال',
        date: dateInOffsetMonth(-6, 5, 9, 15),
        simSlot: 1,
      ),
      (
        smsId: -900019,
        address: 'BluBank',
        body: 'بلوبانک\nخرید اینترنتی 3,200,000 تومان از کارت *3318\nموجودی: 14,500,000 تومان',
        date: dateInOffsetMonth(-6, 12, 17, 40),
        simSlot: 2,
      ),
      (
        smsId: -900020,
        address: 'BPI',
        body: 'بانک پاسارگاد\nخرید آنلاین 24,000,000 ریال کارت *5022\nمانده: 96,000,000 ریال',
        date: dateInOffsetMonth(-6, 20, 20, 10),
        simSlot: 1,
      ),
      (
        smsId: -900021,
        address: 'Tejarat',
        body: 'بانک تجارت\nانتقال کارت به کارت 35,000,000 ریال *5401\nمانده 90,000,000',
        date: dateInOffsetMonth(-6, 28, 12, 50),
        simSlot: 1,
      ),
      // ── ماه -5 (تیر) ──
      (
        smsId: -900022,
        address: '30001414',
        body: 'بانک ملت\nبرداشت 45,000,000 ریال از کارت *4532\nمانده 320,000,000 ریال',
        date: dateInOffsetMonth(-5, 8, 12, 10),
        simSlot: 1,
      ),
      (
        smsId: -900023,
        address: '10008520',
        body: 'بانک صادرات ایران\nواریز مبلغ ۸۵٬۰۰۰٬۰۰۰ ریال به حساب *6104\nمانده ۱۵۷٬۲۰۰٬۰۰۰ ریال',
        date: dateInOffsetMonth(-5, 16, 10, 5),
        simSlot: 1,
      ),
      (
        smsId: -900024,
        address: 'BankSaman',
        body: 'بانک سامان\nبرداشت خرید: 18,500,000 ریال کارت *8811\nمانده: 59,500,000 ریال',
        date: dateInOffsetMonth(-5, 24, 20, 30),
        simSlot: 2,
      ),
      (
        smsId: -900025,
        address: 'BankSepah',
        body: 'بانک سپه\nبرداشت قسط: 21,000,000 ریال از *6610\nمانده: 86,800,000 ریال',
        date: dateInOffsetMonth(-5, 29, 9, 55),
        simSlot: 1,
      ),
      // ── ماه -4 (مرداد) ──
      (
        smsId: -900026,
        address: 'BMI',
        body: 'بانک ملی ایران\nحساب *7700: 140,000,000+ ریال\nمانده: 289,000,000 ریال',
        date: dateInOffsetMonth(-4, 4, 8, 50),
        simSlot: 1,
      ),
      (
        smsId: -900027,
        address: '+9830009111',
        body: 'بانک ملی\nمبلغ 35,000,000- ریال از کارت *7700\nمانده 254,000,000',
        date: dateInOffsetMonth(-4, 15, 16, 22),
        simSlot: 1,
      ),
      (
        smsId: -900028,
        address: 'BPI',
        body: 'بانک پاسارگاد\nواریز وجه 75,000,000 ریال کارت *5022\nمانده حساب: 171,000,000 ریال',
        date: dateInOffsetMonth(-4, 21, 11, 15),
        simSlot: 1,
      ),
      (
        smsId: -900029,
        address: 'Wepod',
        body: 'ویپاد\nخرید 3,400,000 تومان از *2190\nموجودی: 6,400,000 تومان',
        date: dateInOffsetMonth(-4, 28, 18, 5),
        simSlot: 2,
      ),
      // ── ماه -3 (شهریور) ──
      (
        smsId: -900030,
        address: 'Wepod',
        body: 'ویپاد\nواریز 8,500,000 تومن به حساب *2190\nموجودی: 14,900,000 تومن',
        date: dateInOffsetMonth(-3, 6, 13, 5),
        simSlot: 2,
      ),
      (
        smsId: -900031,
        address: 'Wepod',
        body: 'ویپاد\nپرداخت قبض و خرید 2,900,000 تومان کارت *2190\nموجودی: 12,000,000 تومان',
        date: dateInOffsetMonth(-3, 14, 19, 45),
        simSlot: 2,
      ),
      (
        smsId: -900032,
        address: 'BSI',
        body: 'بانک صادرات\nانتقال وجه: ۲۵٬۰۰۰٬۰۰۰ ریال از *6104\nمانده: ۱۳۲٬۲۰۰٬۰۰۰ ریال',
        date: dateInOffsetMonth(-3, 21, 15, 12),
        simSlot: 1,
      ),
      (
        smsId: -900033,
        address: 'Tejarat',
        body: 'بانک تجارت\nواریز سود سپرده 18,500,000 ریال به *5401\nمانده: 108,500,000 ریال',
        date: dateInOffsetMonth(-3, 29, 8, 30),
        simSlot: 1,
      ),
      // ── ماه -2 (مهر) ──
      (
        smsId: -900034,
        address: 'BankMellat',
        body: 'واریز به حساب *4532 مبلغ 245,000,000 ریال\nمانده: 565,000,000 ریال',
        date: dateInOffsetMonth(-2, 3, 9, 30),
        simSlot: 1,
      ),
      (
        smsId: -900035,
        address: '30001414',
        body: 'بانک ملت\nخرید از فروشگاه مبلغ 28,000,000 ریال کارت *9911\nمانده 40,500,000',
        date: dateInOffsetMonth(-2, 11, 18, 10),
        simSlot: 1,
      ),
      (
        smsId: -900036,
        address: 'BluBank',
        body: 'بلوبانک\nواریز 9,500,000 تومان به *3318\nموجودی: 24,000,000 تومان',
        date: dateInOffsetMonth(-2, 19, 12, 40),
        simSlot: 2,
      ),
      (
        smsId: -900037,
        address: 'Keshavarzi',
        body: 'بانک کشاورزی\nواریز مبلغ 60,000,000 ریال به حساب *1145\nمانده: 108,000,000 ریال',
        date: dateInOffsetMonth(-2, 26, 14, 18),
        simSlot: 1,
      ),
      // ── ماه -1 (آبان) ──
      (
        smsId: -900038,
        address: 'BankSaman',
        body: 'بانک سامان\nواریز مبلغ 125,000,000 ریال به *8811\nمانده: 184,500,000 ریال',
        date: dateInOffsetMonth(-1, 5, 10, 20),
        simSlot: 2,
      ),
      (
        smsId: -900039,
        address: 'BankSaman',
        body: 'بانک سامان\nانتقال کارت به کارت 42,000,000 ریال *8811\nمانده: 142,500,000 ریال',
        date: dateInOffsetMonth(-1, 12, 21, 5),
        simSlot: 2,
      ),
      (
        smsId: -900040,
        address: 'BPI',
        body: 'بانک پاسارگاد\nخرید اینترنتی: 19,500,000 ریال کارت *5022\nمانده 151,500,000 ریال',
        date: dateInOffsetMonth(-1, 18, 16, 48),
        simSlot: 1,
      ),
      (
        smsId: -900041,
        address: 'Keshavarzi',
        body: 'بانک کشاورزی\nبرداشت قسط تسهیلات 14,000,000 ریال *1145\nمانده: 94,000,000 ریال',
        date: dateInOffsetMonth(-1, 24, 9, 0),
        simSlot: 1,
      ),
      (
        smsId: -900042,
        address: 'BluBank',
        body: 'بلوبانک\nخرید 4,800,000 تومان از *3318\nموجودی: 19,200,000 تومان',
        date: dateInOffsetMonth(-1, 28, 20, 15),
        simSlot: 2,
      ),
      // ── ماه جاری (آذر) ──
      (
        smsId: -900043,
        address: 'BankMellat',
        body: 'واریز حقوق به حساب *4532 مبلغ 260,000,000 ریال\nمانده 825,000,000 ریال',
        date: dateInOffsetMonth(0, 1, 9, 45),
        simSlot: 1,
      ),
      (
        smsId: -900044,
        address: '30001414',
        body: 'بانک ملت\nانتقال وجه: 12,500,000 ریال از کارت *9911\nمانده 28,000,000',
        date: dateInOffsetMonth(0, 2, 14, 20),
        simSlot: 1,
      ),
      (
        smsId: -900045,
        address: 'BMI',
        body: 'بانک ملی ایران\nواریز: 95,000,000 ریال به حساب *7700\nمانده: 349,000,000 ریال',
        date: dateInOffsetMonth(0, 3, 11, 10),
        simSlot: 1,
      ),
      (
        smsId: -900046,
        address: '+9830009111',
        body: 'بانک ملی\n28,000,000- ریال از کارت *7700\nمانده: 321,000,000 ریال',
        date: dateInOffsetMonth(0, 4, 17, 55),
        simSlot: 1,
      ),
      (
        smsId: -900047,
        address: '10008520',
        body: 'بانک صادرات\nسود سپرده واریز شد: ۱۲٬۴۰۰٬۰۰۰ ریال به *6104\nمانده: ۱۴۴٬۶۰۰٬۰۰۰ ریال',
        date: dateInOffsetMonth(0, 4, 22, 10),
        simSlot: 1,
      ),
      (
        smsId: -900048,
        address: 'BluBank',
        body: 'بلوبانک\nواریز کارت به کارت ۶٬۰۰۰٬۰۰۰ تومان به *3318\nموجودی: ۲۵٬۲۰۰٬۰۰۰ تومان',
        date: dateInOffsetMonth(0, 5, 13, 30),
        simSlot: 2,
      ),
      (
        smsId: -900049,
        address: 'Wepod',
        body: 'ویپاد\nبرداشت خرید ۳٬۱۰۰٬۰۰۰ تومن از *2190\nموجودی: ۸٬۹۰۰٬۰۰۰ تومن',
        date: dateInOffsetMonth(0, 5, 19, 15),
        simSlot: 2,
      ),
      (
        smsId: -900050,
        address: 'Keshavarzi',
        body: 'بانک کشاورزی\nاستعلام موجودی حساب *1145\nمانده حساب: 94,000,000 ریال',
        date: dateInOffsetMonth(0, 6, 8, 15),
        simSlot: 1,
      ),
    ];

    final entities = samples.map((sample) {
      final result = classifier.classify(
        body: sample.body,
        senderAddress: sample.address,
      );
      return MessageEntity(
        smsId: sample.smsId,
        address: sample.address,
        normalizedAddress: normalizePhone(sample.address),
        body: sample.body,
        date: sample.date,
        isRead: true,
        simSlot: sample.simSlot,
        senderType: SenderType.service,
        primaryCategory: 'bank',
        amountRial: result.amountRial,
        txType: result.txType,
        bankName: result.bankName,
        balanceRial: result.balanceRial,
        cardTail: result.cardTail,
      );
    }).toList();

    await repository.upsertMessages(entities);
    return entities.length;
  }

  /// Removes only synthetic demo records added by [seedSampleBankData].
  Future<int> clearDemoData() {
    return repository.deleteBySmsIdRange(minDemoSmsId, maxDemoSmsId);
  }
}

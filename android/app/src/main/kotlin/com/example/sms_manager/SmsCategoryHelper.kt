package com.example.sms_manager

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.ContactsContract
import androidx.core.content.ContextCompat

/**
 * Lightweight native classifier used by [SmsProcessingService] to display a
 * localized Persian category label in notifications even when Flutter is closed.
 */
object SmsCategoryHelper {
    data class CategoryBadge(
        val id: String,
        val notificationTitle: String,
        val contactName: String? = null,
    )

    fun classify(context: Context, address: String, body: String): CategoryBadge {
        val contactName = lookupContactName(context, address)
        if (contactName != null) {
            return CategoryBadge(
                id = "contacts",
                notificationTitle = "👤 پیام از مخاطب",
                contactName = contactName,
            )
        }

        val text = normalizeText(body)
        val addr = normalizeText(address)

        if (matchesAny(text, otpPhrases) || otpRegex.containsMatchIn(text)) {
            return CategoryBadge("otp", "🔑 کد تأیید")
        }

        if (hasStrongPhishingSignal(text)) {
            return CategoryBadge("suspicious", "⚠️ پیام مشکوک")
        }

        if (matchesBank(text, addr)) {
            return CategoryBadge("bank", "🏦 پیام بانکی")
        }

        if (matchesAny(text, billPhrases)) {
            return CategoryBadge("bill", "🧾 قبوض و پرداخت")
        }

        if (matchesGovernment(text, addr)) {
            return CategoryBadge("government", "🏛️ خدمات دولتی")
        }

        if (matchesOperator(text, addr)) {
            return CategoryBadge("operator", "📶 اپراتور")
        }

        if (matchesAny(text, orderPhrases) || matchesAny(addr, orderSenders)) {
            return CategoryBadge("order", "📦 سفارش و مرسوله")
        }

        if (matchesAny(text, travelPhrases) || matchesAny(addr, travelSenders)) {
            return CategoryBadge("travel", "✈️ سفر و رزرو")
        }

        if (matchesAny(text, discountPhrases) || discountPercentRegex.containsMatchIn(text)) {
            return CategoryBadge("discount", "🏷️ تخفیف‌ها")
        }

        if (matchesAny(text, suspiciousPhrases) || suspiciousLinkRegex.containsMatchIn(text)) {
            return CategoryBadge("suspicious", "⚠️ پیام مشکوک")
        }

        if (matchesPromo(text, addr)) {
            return CategoryBadge("promo", "📢 تبلیغاتی")
        }

        return CategoryBadge("unknown", "💬 پیامک جدید")
    }

    private fun lookupContactName(context: Context, address: String): String? {
        if (address.isBlank()) return null
        val hasPermission = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.READ_CONTACTS,
        ) == PackageManager.PERMISSION_GRANTED
        if (!hasPermission) return null

        return try {
            val uri = Uri.withAppendedPath(
                ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
                Uri.encode(address),
            )
            context.contentResolver.query(
                uri,
                arrayOf(ContactsContract.PhoneLookup.DISPLAY_NAME),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    cursor.getString(0)?.takeIf { it.isNotBlank() }
                } else {
                    null
                }
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun normalizeText(input: String): String {
        val sb = StringBuilder(input.length)
        for (ch in input) {
            when (ch) {
                'ي', 'ى', 'ئ' -> sb.append('ی')
                'ك' -> sb.append('ک')
                'ة' -> sb.append('ه')
                'آ', 'أ', 'إ', 'ٱ' -> sb.append('ا')
                in '۰'..'۹' -> sb.append(('0'.code + (ch.code - '۰'.code)).toChar())
                in '٠'..'٩' -> sb.append(('0'.code + (ch.code - '٠'.code)).toChar())
                '\u200C', '\u200F', '\u200E' -> sb.append(' ')
                else -> sb.append(ch.lowercaseChar())
            }
        }
        return sb.toString().replace(Regex("\\s+"), " ").trim()
    }

    private fun containsWord(text: String, word: String): Boolean {
        val boundary = "[\\u0621-\\u064A\\u067E\\u0686\\u0698\\u06AF\\u06A9\\u06CCa-z0-9]"
        val pattern = Regex("(?<!$boundary)${Regex.escape(word)}(?!$boundary)")
        return pattern.containsMatchIn(text)
    }

    private fun matchesAny(text: String, phrases: List<String>): Boolean {
        return phrases.any { text.contains(it) }
    }

    private fun hasStrongPhishingSignal(text: String): Boolean {
        if (matchesAny(text, strongPhishingPhrases)) return true
        if (suspiciousLinkRegex.containsMatchIn(text)) {
            return urgencyWords.any { text.contains(it) }
        }
        return false
    }

    private fun matchesBank(text: String, addr: String): Boolean {
        if (bankSenders.any { containsWord(addr, it) || addr.contains("bank$it") || addr.contains("${it}bank") }) {
            return true
        }
        if (matchesAny(text, bankNamePhrases)) return true
        if (matchesAny(text, bankPhrases)) return true
        if (bankWordPhrases.any { containsWord(text, it) }) return true
        return cardTailRegex.containsMatchIn(text)
    }

    private fun matchesGovernment(text: String, addr: String): Boolean {
        if (matchesAny(text, govPhrases)) return true
        if (containsWord(text, "ثنا")) return true
        if (govSenders.any { containsWord(addr, it) }) return true
        return govShortCodes.any { addr == it }
    }

    private fun matchesOperator(text: String, addr: String): Boolean {
        if (matchesAny(text, operatorPhrases)) return true
        return operatorSenders.any { addr == it || addr.startsWith("$it ") }
    }

    private fun matchesPromo(text: String, addr: String): Boolean {
        if (matchesAny(text, promoPhrases)) return true
        if (addr.length <= 8 && addr.all { it.isDigit() } && !govShortCodes.contains(addr)) {
            return text.contains("خرید") || text.contains("فروش") || text.contains("محصول")
        }
        return false
    }

    private val otpRegex = Regex("(?:code|کد|رمز)\\s*[:=]?\\s*\\d{4,8}", RegexOption.IGNORE_CASE)
    private val cardTailRegex = Regex("\\*{1,4}\\d{4}")
    private val discountPercentRegex = Regex("\\d{1,3}\\s*[%٪]\\s*(?:off|تخفیف)", RegexOption.IGNORE_CASE)
    private val suspiciousLinkRegex = Regex(
        "https?://(?:bit\\.ly|goo\\.gl|t\\.co|is\\.gd|rb\\.gy|tinyurl|v\\.gd|ow\\.ly)/\\S+",
        RegexOption.IGNORE_CASE,
    )

    private val otpPhrases = listOf(
        "رمز یکبار", "رمز پویا", "کد تایید", "کد تائید", "کد فعالسازی",
        "کد فعال سازی", "کد احراز", "کد ورود", "کد تغییر", "کد بازیابی",
        "کد عملیات", "رمز دوم", "رمز عملیات", "verification code",
        "your code is", "your code:", "otp", "one-time", "one time password",
        "login code", "security code", "verify code", "confirmation code",
        "activation code", "auth code",
    )

    private val bankPhrases = listOf(
        "واریز", "برداشت", "موجودی", "مانده حساب", "مانده:", "کارت بانک",
        "حساب بانک", "تراکنش", "انتقال وجه", "انتقال کارت", "خرید از",
        "خرید اینترنتی", "قسط", "سپرده", "سود سپرده", "صورتحساب بانک",
        "کارت به کارت", "ساتنا",
    )

    private val bankWordPhrases = listOf("پایا", "شبا", "وام")

    private val bankSenders = listOf(
        "bmi", "bsi", "bpi", "mellat", "tejarat", "saderat", "melli",
        "maskan", "sepah", "parsian", "pasargad", "eghtesad", "saman",
        "ansar", "keshavarzi", "refah", "shahr", "ayandeh", "dey",
        "resalat", "karafarin", "sina", "hekmat", "mehr", "gardeshgari",
        "sanat", "iran zamin", "بانک", "mellibank",
    )

    private val bankNamePhrases = listOf(
        "بانک ملی", "بانک ملت", "بانک صادرات", "بانک تجارت", "بانک سپه",
        "بانک مسکن", "بانک کشاورزی", "بانک رفاه", "بانک پاسارگاد",
        "بانک پارسیان", "بانک سامان", "بانک اقتصاد", "بانک شهر",
        "بانک اینده", "بانک دی", "بانک سرمایه", "بانک انصار",
        "بانک ایران زمین", "بانک کارافرین", "بانک سینا", "بانک حکمت",
        "بانک رسالت", "بانک مهر", "بانک گردشگری", "بانک صنعت",
    )

    private val billPhrases = listOf(
        "قبض", "اببها", "برقبها", "گازبها", "تلفن ثابت", "عوارض",
        "شناسه قبض", "شناسه پرداخت", "بدهی قبض", "مبلغ قبض", "قبوض",
        "صورتحساب برق", "صورتحساب اب", "صورتحساب گاز", "صورتحساب تلفن",
        "خلافی خودرو", "عوارض خودرو", "بیمه شخص ثالث", "جریمه",
    )

    private val govPhrases = listOf(
        "سامانه ثنا", "قوه قضاییه", "قوه قضائیه", "ابلاغیه", "سازمان ثبت",
        "ثبت احوال", "اداره مالیات", "سازمان مالیاتی", "مالیات بر ارزش",
        "بیمه تامین", "تامین اجتماعی", "سازمان بهزیستی", "سجام", "کد بورسی",
        "نیروی انتظامی", "پلیس فتا", "ناجا", "سازمان سنجش", "وزارت",
        "فرمانداری", "استانداری", "شهرداری", "دادگاه", "دادسرا",
        "پزشکی قانونی", "سازمان بورس", "بانک مرکزی", "سازمان امور",
    )

    private val govSenders = listOf(
        "adliran", "sana", "epolice", "dolat", "gov", "sanjesh", "shahrdari",
    )

    private val govShortCodes = listOf("141", "110", "112", "114", "115", "123", "125")

    private val operatorPhrases = listOf(
        "ایرانسل", "همراه اول", "رایتل", "شاتل موبایل", "بسته اینترنت",
        "بسته مکالمه", "ترافیک اینترنت", "حجم باقیمانده", "حجم رایگان",
        "شارژ", "اعتبار حساب", "اعتبار شما", "مگابایت", "گیگابایت",
        "مکالمه رایگان", "سرویس پیامکی", "سرویس ارزش", "خط اختصاصی", "مخابرات",
    )

    private val operatorSenders = listOf(
        "irancell", "mci", "mtn", "rightel", "shatel", "100", "1000", "2000",
    )

    private val orderPhrases = listOf(
        "سفارش", "مرسوله", "بسته پستی", "ارسال بسته", "تحویل بسته",
        "کد رهگیری", "کد پیگیری", "پست پیشتاز", "تیپاکس", "پست سفارشی",
        "مرجوعی", "بازگشت مرسوله", "tracking", "ارسال شد", "تحویل داده شد",
        "در حال ارسال", "در مسیر تحویل", "ارسال از انبار", "صندوق پستی",
    )

    private val orderSenders = listOf(
        "digikala", "snappfood", "tap30", "divar", "basalam",
        "torob", "emalls", "bamilo", "takhfifan", "netbarg",
        "snappbox", "snappexpress", "alopeyk", "miare", "post", "tipax",
    )

    private val travelPhrases = listOf(
        "پرواز", "بلیط هواپیما", "بلیط قطار", "بلیط اتوبوس", "رزرو هتل",
        "اقامتگاه", "فرودگاه", "ترمینال", "گیت پرواز", "بوردینگ",
        "boarding", "check-in", "چک-این", "ویزا", "پاسپورت", "گذرنامه",
    )

    private val travelSenders = listOf(
        "alibaba", "flytoday", "snapptrip", "trip.com", "jabama", "shab.ir",
        "hotelyar", "iran air", "mahan", "kish air", "aseman", "ata",
        "caspian", "meraj", "taban", "varesh", "zagros", "qeshm air",
        "safarme", "flightio", "ghasedak24", "charter", "safar724", "mrbilit",
    )

    private val discountPhrases = listOf(
        "کد تخفیف", "کوپن", "voucher", "coupon", "درصد تخفیف",
        "تخفیف ویژه", "بن تخفیف", "بن خرید", "اعتبار هدیه", "هدیه تخفیف",
    )

    private val strongPhishingPhrases = listOf(
        "برنده شدید", "برنده شده اید", "حساب شما مسدود", "برای جلوگیری از مسدود",
        "فیشینگ", "ارز دیجیتال رایگان", "سرمایهگذاری با سود", "سود تضمینی",
        "درامد میلیونی", "درامد روزانه", "کلیک کنید", "click here",
    )

    private val urgencyWords = listOf(
        "فوری", "urgent", "اکنون", "سریع", "همین الان", "مسدود", "ابلاغیه",
    )

    private val suspiciousPhrases = strongPhishingPhrases + listOf(
        "جایزه", "حساب مسدود", "بروزرسانی اطلاعات", "کسب درامد",
    )

    private val promoPhrases = listOf(
        "تبلیغ", "پیشنهاد ویژه", "فروش ویژه", "جشنواره", "حراج",
        "فروش فوقالعاده", "فروش فوق العاده", "عضویت", "معرفی محصول",
        "ارسال رایگان", "نصب اپلیکیشن", "دانلود", "ثبت نام رایگان",
        "لغو ارسال 11", "لغو11", "لغو ارسال", "عدم دریافت",
        "unsub", "unsubscribe", "opt out", "opt-out", "بازاریابی",
        "همکاری در فروش", "نمایندگی",
    )
}

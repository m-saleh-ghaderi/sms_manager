package com.example.sms_manager

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import java.util.concurrent.atomic.AtomicInteger

/**
 * Foreground service handling newly received SMS payloads in the background.
 *
 * Responsibilities:
 * 1. Satisfy Android background execution limits with an immediate short foreground state.
 * 2. Forward the raw SMS payload to Dart via [SmsEventBridge] when Flutter is active.
 * 3. Display a categorized notification with category label and message preview.
 */
class SmsProcessingService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        ensureNotificationChannels()

        val processingNotif = NotificationCompat.Builder(this, CHANNEL_PROCESSING)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("دریافت پیامک جدید")
            .setContentText("در حال دسته‌بندی...")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setSilent(true)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                FOREGROUND_NOTIF_ID,
                processingNotif,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SHORT_SERVICE,
            )
        } else {
            startForeground(FOREGROUND_NOTIF_ID, processingNotif)
        }

        if (intent != null) {
            val address = intent.getStringExtra(EXTRA_ADDRESS).orEmpty()
            val body = intent.getStringExtra(EXTRA_BODY).orEmpty()
            val dateMillis = intent.getLongExtra(EXTRA_DATE_MILLIS, System.currentTimeMillis())
            val simSlotExtra = intent.getIntExtra(EXTRA_SIM_SLOT, -1)
            val simSlot: Int? = if (simSlotExtra > 0) simSlotExtra else null

            if (body.isNotBlank()) {
                SmsEventBridge.emit(
                    mapOf(
                        "address" to address,
                        "body" to body,
                        "date" to dateMillis,
                        "simSlot" to simSlot,
                    ),
                )

                val badge = SmsCategoryHelper.classify(this, address, body)
                showSmsNotification(
                    address = address,
                    body = body,
                    simSlot = simSlot,
                    badge = badge,
                )
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf(startId)
        return START_NOT_STICKY
    }

    private fun ensureNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (manager.getNotificationChannel(CHANNEL_PROCESSING) == null) {
            val processingChannel = NotificationChannel(
                CHANNEL_PROCESSING,
                "پردازش پس‌زمینه پیامک",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "نمایش موقت هنگام دریافت پیامک جدید"
                setShowBadge(false)
            }
            manager.createNotificationChannel(processingChannel)
        }

        if (manager.getNotificationChannel(CHANNEL_NEW_SMS) == null) {
            val smsChannel = NotificationChannel(
                CHANNEL_NEW_SMS,
                "پیامک‌های دسته‌بندی‌شده",
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply {
                description = "اعلان دریافت پیامک جدید همراه با دسته‌بندی هوشمند"
                enableVibration(true)
            }
            manager.createNotificationChannel(smsChannel)
        }
    }

    private fun showSmsNotification(
        address: String,
        body: String,
        simSlot: Int?,
        badge: SmsCategoryHelper.CategoryBadge,
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS,
            ) == PackageManager.PERMISSION_GRANTED
            if (!granted) return
        }

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val contentIntent = PendingIntent.getActivity(this, 0, launchIntent, pendingIntentFlags)

        val senderDisplay = badge.contactName ?: address.ifBlank { "فرستنده ناشناس" }
        val normalizedPreview = body.replace(Regex("\\s+"), " ").trim()
        val shortPreview = if (normalizedPreview.length > 80) {
            normalizedPreview.take(80) + "…"
        } else {
            normalizedPreview
        }

        val notifId = notificationCounter.incrementAndGet()
        val builder = NotificationCompat.Builder(this, CHANNEL_NEW_SMS)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("${badge.notificationTitle} • $senderDisplay")
            .setContentText(shortPreview)
            .setStyle(NotificationCompat.BigTextStyle().bigText(normalizedPreview))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setContentIntent(contentIntent)
            .setAutoCancel(true)
            .setGroup(GROUP_KEY_SMS)

        if (simSlot != null) {
            builder.setSubText("سیم‌کارت $simSlot")
        }

        manager.notify(notifId, builder.build())

        val summaryNotif = NotificationCompat.Builder(this, CHANNEL_NEW_SMS)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("پیامک‌های جدید")
            .setContentText("پیامک‌های دسته‌بندی‌شده")
            .setGroup(GROUP_KEY_SMS)
            .setGroupSummary(true)
            .setAutoCancel(true)
            .setContentIntent(contentIntent)
            .build()

        manager.notify(SUMMARY_NOTIF_ID, summaryNotif)
    }

    companion object {
        private const val CHANNEL_PROCESSING = "sms_processing"
        private const val CHANNEL_NEW_SMS = "new_sms"
        private const val GROUP_KEY_SMS = "com.example.sms_manager.SMS_GROUP"
        private const val FOREGROUND_NOTIF_ID = 1001
        private const val SUMMARY_NOTIF_ID = 1002

        private const val EXTRA_ADDRESS = "address"
        private const val EXTRA_BODY = "body"
        private const val EXTRA_DATE_MILLIS = "dateMillis"
        private const val EXTRA_SIM_SLOT = "simSlot"

        private val notificationCounter = AtomicInteger(2000)

        fun start(
            context: Context,
            address: String,
            body: String,
            dateMillis: Long,
            simSlot: Int?,
        ) {
            val intent = Intent(context, SmsProcessingService::class.java).apply {
                putExtra(EXTRA_ADDRESS, address)
                putExtra(EXTRA_BODY, body)
                putExtra(EXTRA_DATE_MILLIS, dateMillis)
                putExtra(EXTRA_SIM_SLOT, simSlot ?: -1)
            }
            ContextCompat.startForegroundService(context, intent)
        }
    }
}

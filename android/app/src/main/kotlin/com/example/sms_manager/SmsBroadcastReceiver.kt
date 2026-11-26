package com.example.sms_manager

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Telephony
import android.telephony.SubscriptionManager

/**
 * Receives incoming SMS broadcasts (`android.provider.Telephony.SMS_RECEIVED`)
 * even while the app UI is closed, merges multi-part PDUs, resolves the SIM slot,
 * and hands off processing to [SmsProcessingService].
 */
class SmsBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isNullOrEmpty()) return

        val simSlot = resolveSimSlot(context, intent)

        // Multi-part SMS delivers multiple PDUs in one broadcast; group by sender.
        val groupedBodies = linkedMapOf<String, StringBuilder>()
        val groupedTimestamps = mutableMapOf<String, Long>()

        for (sms in messages) {
            val address = sms.displayOriginatingAddress ?: sms.originatingAddress.orEmpty()
            val partBody = sms.displayMessageBody ?: sms.messageBody.orEmpty()
            groupedBodies.getOrPut(address) { StringBuilder() }.append(partBody)
            groupedTimestamps.putIfAbsent(address, sms.timestampMillis)
        }

        for ((address, bodyBuilder) in groupedBodies) {
            val body = bodyBuilder.toString()
            if (body.isBlank()) continue
            val dateMillis = groupedTimestamps[address] ?: System.currentTimeMillis()
            SmsProcessingService.start(
                context = context,
                address = address,
                body = body,
                dateMillis = dateMillis,
                simSlot = simSlot,
            )
        }
    }

    private fun resolveSimSlot(context: Context, intent: Intent): Int? {
        val extras = intent.extras ?: return null
        val invalidSubId = SubscriptionManager.INVALID_SUBSCRIPTION_ID

        val subId = when {
            extras.containsKey("android.telephony.extra.SUBSCRIPTION_INDEX") ->
                extras.getInt("android.telephony.extra.SUBSCRIPTION_INDEX", invalidSubId)
            extras.containsKey("subscription") ->
                extras.getInt("subscription", invalidSubId)
            else -> invalidSubId
        }

        if (subId != invalidSubId && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            try {
                val sm = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
                val list = sm?.activeSubscriptionInfoList
                if (list != null) {
                    for (info in list) {
                        if (info.subscriptionId == subId) {
                            return info.simSlotIndex + 1
                        }
                    }
                }
            } catch (_: SecurityException) {
                // Fallback gracefully if READ_PHONE_STATE is not granted.
            }
        }

        // Fallback to slot extras present on some vendor devices
        val slotExtra = when {
            extras.containsKey("android.telephony.extra.SLOT_INDEX") ->
                extras.getInt("android.telephony.extra.SLOT_INDEX", -1)
            extras.containsKey("slot") ->
                extras.getInt("slot", -1)
            else -> -1
        }
        return if (slotExtra >= 0) slotExtra + 1 else null
    }
}

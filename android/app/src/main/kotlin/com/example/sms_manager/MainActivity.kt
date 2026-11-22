package com.example.sms_manager

import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.Telephony
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.sms_manager/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInboxSms" -> {
                    val afterId = (call.argument<Number>("afterId"))?.toLong()
                    val limit = call.argument<Int>("limit") ?: 100
                    try {
                        val messages = readInboxSms(afterId, limit)
                        result.success(messages)
                    } catch (e: Exception) {
                        result.error("SMS_READ_ERROR", e.localizedMessage, null)
                    }
                }
                "getInboxCount" -> {
                    try {
                        val count = getInboxCount()
                        result.success(count)
                    } catch (e: Exception) {
                        result.error("SMS_COUNT_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getSimSlotMap(): Map<Int, Int> {
        val simMap = mutableMapOf<Int, Int>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            try {
                val sm = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
                val list = sm?.activeSubscriptionInfoList
                if (list != null) {
                    for (info in list) {
                        // simSlotIndex is 0-indexed; convert to 1-indexed (1 or 2)
                        simMap[info.subscriptionId] = info.simSlotIndex + 1
                    }
                }
            } catch (_: SecurityException) {
                // If READ_PHONE_STATE is not granted, fallback gracefully
            }
        }
        return simMap
    }

    private fun readInboxSms(afterId: Long?, limit: Int): List<Map<String, Any?>> {
        val messages = mutableListOf<Map<String, Any?>>()
        val uri: Uri = Telephony.Sms.Inbox.CONTENT_URI
        val simMap = getSimSlotMap()

        val projection = arrayOf(
            Telephony.Sms._ID,
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE,
            Telephony.Sms.READ,
            Telephony.Sms.SUBSCRIPTION_ID
        )

        val selection: String?
        val selectionArgs: Array<String>?
        if (afterId != null) {
            selection = "${Telephony.Sms._ID} > ?"
            selectionArgs = arrayOf(afterId.toString())
        } else {
            selection = null
            selectionArgs = null
        }

        val sortOrder = "${Telephony.Sms.DATE} DESC LIMIT $limit"

        val cursor: Cursor? = contentResolver.query(
            uri,
            projection,
            selection,
            selectionArgs,
            sortOrder
        )

        cursor?.use {
            val idIndex = it.getColumnIndex(Telephony.Sms._ID)
            val addressIndex = it.getColumnIndex(Telephony.Sms.ADDRESS)
            val bodyIndex = it.getColumnIndex(Telephony.Sms.BODY)
            val dateIndex = it.getColumnIndex(Telephony.Sms.DATE)
            val readIndex = it.getColumnIndex(Telephony.Sms.READ)
            val subIdIndex = it.getColumnIndex(Telephony.Sms.SUBSCRIPTION_ID)

            while (it.moveToNext()) {
                val id = if (idIndex != -1) it.getLong(idIndex) else 0L
                val address = if (addressIndex != -1) it.getString(addressIndex) ?: "" else ""
                val body = if (bodyIndex != -1) it.getString(bodyIndex) ?: "" else ""
                val date = if (dateIndex != -1) it.getLong(dateIndex) else 0L
                val read = if (readIndex != -1) it.getInt(readIndex) == 1 else false
                val subId = if (subIdIndex != -1) it.getInt(subIdIndex) else -1
                val simSlot = simMap[subId] ?: if (subId > 0) subId else null

                messages.add(
                    mapOf(
                        "id" to id,
                        "address" to address,
                        "body" to body,
                        "date" to date,
                        "isRead" to read,
                        "simSlot" to simSlot
                    )
                )
            }
        }

        return messages
    }

    private fun getInboxCount(): Int {
        val uri: Uri = Telephony.Sms.Inbox.CONTENT_URI
        val cursor: Cursor? = contentResolver.query(
            uri,
            arrayOf("count(*)"),
            null,
            null,
            null
        )
        return cursor?.use {
            if (it.moveToFirst()) it.getInt(0) else 0
        } ?: 0
    }
}

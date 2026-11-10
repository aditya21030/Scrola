package com.example.scrola

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import com.example.scrola.service.ScrolaAccessibilityService
import com.example.scrola.service.ScrolaDataManager
import com.example.scrola.service.ScrolaOverlayService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val METHOD_CHANNEL = "com.scrola.app/native"
    private val EVENT_CHANNEL = "com.scrola.app/reel_events"

    private var eventSink: EventChannel.EventSink? = null
    private var reelEventReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val dataManager = ScrolaDataManager.getInstance(applicationContext)

        // MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "openAccessibilitySettings" -> {
                    openAccessibilitySettings()
                    result.success(true)
                }
                "isOverlayPermissionGranted" -> {
                    result.success(isOverlayPermissionGranted())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "startOverlayService" -> {
                    startOverlayService()
                    result.success(true)
                }
                "stopOverlayService" -> {
                    stopOverlayService()
                    result.success(true)
                }
                "updateOverlayStats" -> {
                    val today = call.argument<Int>("today") ?: dataManager.getTotalReelsToday()
                    val limit = call.argument<Int>("limit") ?: dataManager.getTotalLimit()
                    val session = call.argument<Int>("session") ?: dataManager.getSessionCount()
                    val platform = call.argument<String>("platform") ?: ""
                    val isFocus = call.argument<Boolean>("isFocus") ?: dataManager.isFocusModeActive()

                    ScrolaOverlayService.updateStats(this, today, limit, session, platform, isFocus)
                    result.success(true)
                }
                "syncLimits" -> {
                    val totalLimit = call.argument<Int>("totalLimit")
                    if (totalLimit != null) dataManager.setTotalLimit(totalLimit)

                    val instagramLimit = call.argument<Int>("instagramLimit")
                    if (instagramLimit != null) dataManager.setPlatformLimit("instagram", instagramLimit)

                    val youtubeLimit = call.argument<Int>("youtubeLimit")
                    if (youtubeLimit != null) dataManager.setPlatformLimit("youtube", youtubeLimit)

                    val facebookLimit = call.argument<Int>("facebookLimit")
                    if (facebookLimit != null) dataManager.setPlatformLimit("facebook", facebookLimit)

                    val snapchatLimit = call.argument<Int>("snapchatLimit")
                    if (snapchatLimit != null) dataManager.setPlatformLimit("snapchat", snapchatLimit)

                    val focusActive = call.argument<Boolean>("isFocusActive")
                    if (focusActive != null) dataManager.setFocusModeActive(focusActive)

                    val overlayEnabled = call.argument<Boolean>("isOverlayEnabled")
                    if (overlayEnabled != null) dataManager.setOverlayEnabled(overlayEnabled)

                    result.success(true)
                }
                "getNativeStats" -> {
                    val stats = mapOf(
                        "totalToday" to dataManager.getTotalReelsToday(),
                        "instagram" to dataManager.getPlatformReels("instagram"),
                        "youtube" to dataManager.getPlatformReels("youtube"),
                        "facebook" to dataManager.getPlatformReels("facebook"),
                        "snapchat" to dataManager.getPlatformReels("snapchat"),
                        "sessionCount" to dataManager.getSessionCount(),
                        "totalLimit" to dataManager.getTotalLimit(),
                        "isFocusActive" to dataManager.isFocusModeActive()
                    )
                    result.success(stats)
                }
                "resetSession" -> {
                    dataManager.resetSession()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // EventChannel for real-time reel tracking events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    registerReelReceiver()
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReelReceiver()
                    eventSink = null
                }
            }
        )
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expectedService = "${packageName}/${ScrolaAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        return enabledServices.contains(packageName) || enabledServices.contains(expectedService)
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(intent)
    }

    private fun isOverlayPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            ).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
        }
    }

    private fun startOverlayService() {
        if (!isOverlayPermissionGranted()) return
        val intent = Intent(this, ScrolaOverlayService::class.java).apply {
            action = ScrolaOverlayService.ACTION_START
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopOverlayService() {
        val intent = Intent(this, ScrolaOverlayService::class.java).apply {
            action = ScrolaOverlayService.ACTION_STOP
        }
        stopService(intent)
    }

    private fun registerReelReceiver() {
        if (reelEventReceiver != null) return
        reelEventReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == ScrolaAccessibilityService.BROADCAST_REEL_EVENT) {
                    val eventType = intent.getStringExtra(ScrolaAccessibilityService.EXTRA_EVENT_TYPE) ?: ""
                    val platform = intent.getStringExtra(ScrolaAccessibilityService.EXTRA_PLATFORM) ?: ""
                    val count = intent.getIntExtra(ScrolaAccessibilityService.EXTRA_COUNT, 0)
                    val total = intent.getIntExtra(ScrolaAccessibilityService.EXTRA_TOTAL, 0)

                    val payload = mapOf(
                        "eventType" to eventType,
                        "platform" to platform,
                        "count" to count,
                        "total" to total,
                        "timestamp" to System.currentTimeMillis()
                    )
                    runOnUiThread {
                        eventSink?.success(payload)
                    }
                }
            }
        }
        val filter = IntentFilter(ScrolaAccessibilityService.BROADCAST_REEL_EVENT)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(reelEventReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(reelEventReceiver, filter)
        }
    }

    private fun unregisterReelReceiver() {
        reelEventReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            reelEventReceiver = null
        }
    }

    override fun onDestroy() {
        unregisterReelReceiver()
        super.onDestroy()
    }
}

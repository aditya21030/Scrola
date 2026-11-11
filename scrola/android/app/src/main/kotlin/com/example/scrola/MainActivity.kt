package com.example.scrola

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
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
    private val REQUEST_CODE_NOTIFICATIONS = 1002

    private var eventSink: EventChannel.EventSink? = null
    private var reelEventReceiver: BroadcastReceiver? = null
    private var pendingNotificationResult: MethodChannel.Result? = null

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
                    val animate = call.argument<Boolean>("animateEntrance") ?: true
                    result.success(startOverlayService(animate))
                }
                "stopOverlayService" -> {
                    stopOverlayService()
                    result.success(true)
                }
                "refreshOverlayConfig" -> {
                    ScrolaOverlayService.refreshConfig(this)
                    result.success(true)
                }
                "isNotificationPermissionGranted" -> {
                    result.success(isNotificationPermissionGranted())
                }
                "requestNotificationPermission" -> {
                    requestNotificationPermission(result)
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

                    for (platform in ScrolaDataManager.SUPPORTED_PLATFORMS) {
                        val specificLimit = call.argument<Int>("${platform}Limit")
                        if (specificLimit != null) {
                            dataManager.setPlatformLimit(platform, specificLimit)
                        }
                    }

                    val platformLimitsMap = call.argument<Map<String, Any>>("platformLimits")
                    platformLimitsMap?.forEach { (platform, rawVal) ->
                        val intVal = (rawVal as? Number)?.toInt()
                        if (intVal != null) {
                            dataManager.setPlatformLimit(platform, intVal)
                        }
                    }

                    val focusActive = call.argument<Boolean>("isFocusActive")
                    if (focusActive != null) dataManager.setFocusModeActive(focusActive)

                    val overlayEnabled = call.argument<Boolean>("isOverlayEnabled")
                    if (overlayEnabled != null) dataManager.setOverlayEnabled(overlayEnabled)

                    val trackingEnabled = call.argument<Boolean>("isTrackingEnabled")
                    if (trackingEnabled != null) dataManager.setTrackingEnabled(trackingEnabled)

                    val platformLimitsEnabled = call.argument<Boolean>("platformLimitsEnabled")
                    if (platformLimitsEnabled != null) {
                        dataManager.setPlatformLimitsEnabled(platformLimitsEnabled)
                    }

                    val selectedPlatforms = call.argument<List<String>>("selectedPlatforms")
                    if (selectedPlatforms != null) {
                        dataManager.setSelectedPlatforms(selectedPlatforms.joinToString(","))
                    }

                    val stickToNotch = call.argument<Boolean>("stickToNotch")
                    if (stickToNotch != null) dataManager.setStickToNotch(stickToNotch)

                    val overlayExpanded = call.argument<Boolean>("overlayExpanded")
                    if (overlayExpanded != null) dataManager.setOverlayExpanded(overlayExpanded)

                    val overlaySize = call.argument<String>("overlaySize")
                    if (overlaySize != null) dataManager.setOverlaySize(overlaySize)

                    val skinIndex = call.argument<Int>("skinIndex")
                    if (skinIndex != null) dataManager.setSkinIndex(skinIndex)

                    if (ScrolaOverlayService.isServiceRunning) {
                        ScrolaOverlayService.refreshConfig(this)
                    }

                    result.success(true)
                }
                "getNativeStats" -> {
                    val stats = mutableMapOf<String, Any>(
                        "totalToday" to dataManager.getTotalReelsToday(),
                        "sessionCount" to dataManager.getSessionCount(),
                        "totalLimit" to dataManager.getTotalLimit(),
                        "isFocusActive" to dataManager.isFocusModeActive(),
                        "isTrackingEnabled" to dataManager.isTrackingEnabled(),
                        "isOverlayEnabled" to dataManager.isOverlayEnabled(),
                        "overlayExpanded" to dataManager.isOverlayExpanded()
                    )
                    for (platform in ScrolaDataManager.SUPPORTED_PLATFORMS) {
                        stats[platform] = dataManager.getPlatformReels(platform)
                    }
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

    private fun isNotificationPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU || isNotificationPermissionGranted()) {
            result.success(true)
            return
        }
        pendingNotificationResult?.success(false)
        pendingNotificationResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            REQUEST_CODE_NOTIFICATIONS
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_NOTIFICATIONS) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingNotificationResult?.success(granted)
            pendingNotificationResult = null
        }
    }

    private fun startOverlayService(animateEntrance: Boolean = true): Boolean {
        if (!isOverlayPermissionGranted()) return false
        return ScrolaOverlayService.start(this, animateEntrance)
    }

    private fun stopOverlayService() {
        ScrolaOverlayService.stop(this)
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

package com.example.scrola.service

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import com.example.scrola.MainActivity

class ScrolaOverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: LinearLayout? = null
    private var params: WindowManager.LayoutParams? = null

    private var watchedTextView: TextView? = null
    private var remainingTextView: TextView? = null
    private var isExpanded: Boolean = false
    private var stickToTopCentre: Boolean = true

    companion object {
        const val ACTION_START = "ACTION_START_OVERLAY"
        const val ACTION_STOP = "ACTION_STOP_OVERLAY"
        const val ACTION_UPDATE = "ACTION_UPDATE_OVERLAY"
        const val EXTRA_TODAY = "EXTRA_TODAY"
        const val EXTRA_LIMIT = "EXTRA_LIMIT"
        const val EXTRA_SESSION = "EXTRA_SESSION"
        const val EXTRA_PLATFORM = "EXTRA_PLATFORM"
        const val EXTRA_IS_FOCUS = "EXTRA_IS_FOCUS"

        private const val CHANNEL_ID = "scrola_overlay_channel"
        private const val NOTIFICATION_ID = 1001

        fun updateStats(
            context: Context,
            today: Int,
            limit: Int,
            session: Int,
            platform: String = "",
            isFocus: Boolean = false
        ) {
            val intent = Intent(context, ScrolaOverlayService::class.java).apply {
                action = ACTION_UPDATE
                putExtra(EXTRA_TODAY, today)
                putExtra(EXTRA_LIMIT, limit)
                putExtra(EXTRA_SESSION, session)
                putExtra(EXTRA_PLATFORM, platform)
                putExtra(EXTRA_IS_FOCUS, isFocus)
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startServiceForeground()
        initOverlay()
    }

    private fun startServiceForeground() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= 34) {
            try {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } catch (e: Exception) {
                startForeground(NOTIFICATION_ID, notification)
            }
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelf()
            }
            ACTION_UPDATE -> {
                val today = intent.getIntExtra(EXTRA_TODAY, 0)
                val limit = intent.getIntExtra(EXTRA_LIMIT, 40)
                val session = intent.getIntExtra(EXTRA_SESSION, 0)
                val platform = intent.getStringExtra(EXTRA_PLATFORM) ?: ""
                val isFocus = intent.getBooleanExtra(EXTRA_IS_FOCUS, false)
                updateUI(today, limit, session, platform, isFocus)
            }
        }
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Scrola Floating Counter",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows real-time reels notch pill counter"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val launchIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, launchIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Scrola Counter Active")
            .setContentText("Monitoring short-form video consumption")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun getTopSafeOffset(): Int {
        var topOffset = dpToPx(8)
        val resourceId = resources.getIdentifier("status_bar_height", "dimen", "android")
        if (resourceId > 0) {
            topOffset = resources.getDimensionPixelSize(resourceId) + dpToPx(4)
        }
        return topOffset
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initOverlay() {
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        // Notch Pill placement at top centre
        params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            dpToPx(42),
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            x = 0
            y = getTopSafeOffset()
        }

        // Black capsule pill (#101010 with #2A2A2A border)
        overlayView = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dpToPx(14), dpToPx(6), dpToPx(14), dpToPx(6))
            background = createPillBackground(Color.parseColor("#101010"), Color.parseColor("#2A2A2A"))
        }

        // Left: Reels Watched
        watchedTextView = TextView(this).apply {
            text = "0"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            paint.isFakeBoldText = true
        }

        // Center: Brainy Mascot Pill Marker
        val brainyMarker = View(this).apply {
            val size = dpToPx(16)
            layoutParams = LinearLayout.LayoutParams(size, size).apply {
                marginStart = dpToPx(10)
                marginEnd = dpToPx(10)
            }
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#FF6B24"))
                setStroke(dpToPx(2), Color.parseColor("#FFB27F"))
            }
        }

        // Right: Reels Remaining (Orange #FF6B24)
        remainingTextView = TextView(this).apply {
            text = "40"
            setTextColor(Color.parseColor("#FF6B24"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            paint.isFakeBoldText = true
        }

        overlayView?.addView(watchedTextView)
        overlayView?.addView(brainyMarker)
        overlayView?.addView(remainingTextView)

        setupTouchListener()

        try {
            windowManager?.addView(overlayView, params)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        val dataManager = ScrolaDataManager.getInstance(this)
        updateUI(
            dataManager.getTotalReelsToday(),
            dataManager.getTotalLimit(),
            dataManager.getSessionCount(),
            "",
            dataManager.isFocusModeActive()
        )
    }

    private fun createPillBackground(bgColor: Int, strokeColor: Int): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dpToPx(24).toFloat()
            setColor(bgColor)
            setStroke(dpToPx(1), strokeColor)
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun setupTouchListener() {
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        var hasMoved = false
        var lastTapTime = 0L

        overlayView?.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params?.x ?: 0
                    initialY = params?.y ?: 0
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    hasMoved = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - initialTouchX).toInt()
                    val dy = (event.rawY - initialTouchY).toInt()
                    if (Math.abs(dx) > 10 || Math.abs(dy) > 10) {
                        hasMoved = true
                        val metrics = resources.displayMetrics
                        val halfW = metrics.widthPixels / 2 - dpToPx(60)
                        val maxY = Math.max(0, metrics.heightPixels - dpToPx(90))
                        params?.x = (initialX + dx).coerceIn(-halfW, halfW)
                        params?.y = (initialY + dy).coerceIn(dpToPx(20), maxY)
                        try {
                            windowManager?.updateViewLayout(overlayView, params)
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (!hasMoved) {
                        val now = System.currentTimeMillis()
                        if (now - lastTapTime < 350) {
                            // Double tap launches Scrola directly
                            val launchIntent = Intent(this@ScrolaOverlayService, MainActivity::class.java).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(launchIntent)
                        } else {
                            // Single tap toggles Compact <-> Expanded
                            toggleExpandCollapse()
                        }
                        lastTapTime = now
                    }
                    true
                }
                else -> false
            }
        }
    }

    private fun toggleExpandCollapse() {
        isExpanded = !isExpanded
        params?.height = if (isExpanded) dpToPx(48) else dpToPx(42)
        val dataManager = ScrolaDataManager.getInstance(this)
        updateUI(
            dataManager.getTotalReelsToday(),
            dataManager.getTotalLimit(),
            dataManager.getSessionCount(),
            "",
            dataManager.isFocusModeActive()
        )
    }

    fun updateUI(today: Int, limit: Int, session: Int, platform: String, isFocus: Boolean) {
        val remaining = Math.max(0, limit - today)
        val isLimitReached = today >= limit || isFocus

        if (isExpanded) {
            watchedTextView?.text = "$today watched"
            remainingTextView?.text = if (isFocus) "LOCKED" else "$remaining left"
        } else {
            watchedTextView?.text = "$today"
            remainingTextView?.text = if (isFocus) "LOCK" else "$remaining"
        }

        val strokeColor = when {
            isFocus || isLimitReached -> Color.parseColor("#FF5252")
            today >= (limit * 0.8) -> Color.parseColor("#FFC15A")
            else -> Color.parseColor("#2A2A2A")
        }

        val rightColor = when {
            isFocus || isLimitReached -> Color.parseColor("#FF5252")
            today >= (limit * 0.8) -> Color.parseColor("#FFC15A")
            else -> Color.parseColor("#FF6B24")
        }

        remainingTextView?.setTextColor(rightColor)
        overlayView?.background = createPillBackground(Color.parseColor("#101010"), strokeColor)

        try {
            windowManager?.updateViewLayout(overlayView, params)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }

    override fun onDestroy() {
        super.onDestroy()
        if (overlayView != null) {
            try {
                if (overlayView?.isAttachedToWindow == true) {
                    windowManager?.removeView(overlayView)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
            overlayView = null
        }
    }
}

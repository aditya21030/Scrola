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

    private var countTextView: TextView? = null
    private var remainingTextView: TextView? = null
    private var isExpanded: Boolean = true

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
                "Scrola Floating Tracker",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows real-time reels screen time overlay"
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
            .setContentTitle("Scrola Active")
            .setContentText("Monitoring short-form video consumption")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
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

        params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 30
            y = 200
        }

        overlayView = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dpToPx(12), dpToPx(8), dpToPx(14), dpToPx(8))
            background = createPillBackground(Color.parseColor("#101010"), Color.parseColor("#FF6B24"))
        }

        // Mascot dot indicator
        val dotIndicator = View(this).apply {
            val size = dpToPx(10)
            layoutParams = LinearLayout.LayoutParams(size, size).apply {
                marginEnd = dpToPx(8)
            }
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#FF6B24"))
            }
        }

        countTextView = TextView(this).apply {
            text = "0 / 40"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            paint.isFakeBoldText = true
        }

        remainingTextView = TextView(this).apply {
            text = "  •  40 left"
            setTextColor(Color.parseColor("#A3A3A3"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
        }

        overlayView?.addView(dotIndicator)
        overlayView?.addView(countTextView)
        overlayView?.addView(remainingTextView)

        // Drag & Tap Interaction
        setupTouchListener()

        try {
            windowManager?.addView(overlayView, params)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Load initial stats from ScrolaDataManager
        val dataManager = ScrolaDataManager.getInstance(this)
        val today = dataManager.getTotalReelsToday()
        val limit = dataManager.getTotalLimit()
        val session = dataManager.getSessionCount()
        val isFocus = dataManager.isFocusModeActive()
        updateUI(today, limit, session, "", isFocus)
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

                        // Screen edge boundary clamping to prevent dragging off-screen
                        val metrics = resources.displayMetrics
                        val viewWidth = overlayView?.width ?: dpToPx(120)
                        val viewHeight = overlayView?.height ?: dpToPx(44)
                        val maxX = Math.max(0, metrics.widthPixels - viewWidth)
                        val maxY = Math.max(0, metrics.heightPixels - viewHeight - dpToPx(40))

                        params?.x = (initialX + dx).coerceIn(0, maxX)
                        params?.y = (initialY + dy).coerceIn(dpToPx(30), maxY)

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
                        toggleExpandCollapse()
                    }
                    true
                }
                else -> false
            }
        }
    }

    private fun toggleExpandCollapse() {
        isExpanded = !isExpanded
        remainingTextView?.visibility = if (isExpanded) View.VISIBLE else View.GONE
    }

    fun updateUI(today: Int, limit: Int, session: Int, platform: String, isFocus: Boolean) {
        val remaining = Math.max(0, limit - today)
        val isLimitReached = today >= limit || isFocus

        countTextView?.text = "$today / $limit"
        remainingTextView?.text = if (isFocus) {
            "  •  FOCUS LOCKED"
        } else if (isLimitReached) {
            "  •  LIMIT REACHED"
        } else {
            "  •  $remaining left"
        }

        // Color coding based on status
        val strokeColor = when {
            isFocus -> Color.parseColor("#FF5252")
            isLimitReached -> Color.parseColor("#FF5252")
            today >= (limit * 0.8) -> Color.parseColor("#FFC15A")
            else -> Color.parseColor("#FF6B24")
        }

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

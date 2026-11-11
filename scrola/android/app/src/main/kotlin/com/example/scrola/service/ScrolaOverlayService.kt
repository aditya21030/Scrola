package com.example.scrola.service

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.ValueAnimator
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
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.provider.Settings
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowInsets
import android.view.WindowManager
import android.view.animation.OvershootInterpolator
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import com.example.scrola.MainActivity
import kotlin.math.abs
import kotlin.math.max

class ScrolaOverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var rootContainer: FrameLayout? = null
    private var pillContainer: LinearLayout? = null
    private var params: WindowManager.LayoutParams? = null

    private var brainyView: BrainyOverlayView? = null
    private var primaryTextView: TextView? = null
    private var dividerView: View? = null
    private var secondaryTextView: TextView? = null
    private var closeButtonView: TextView? = null

    private var isExpanded: Boolean = false
    private var isViewAddedToWindow: Boolean = false
    @Volatile
    private var isStopping: Boolean = false
    private var stickToTopCentre: Boolean = true
    private var overlaySize: String = "Medium"
    private var lastPlatform: String = ""
    private var positionAnimator: ValueAnimator? = null
    private var entranceAnimatorSet: AnimatorSet? = null
    private var dismissAnimatorSet: AnimatorSet? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val longPressHandler = Handler(Looper.getMainLooper())
    private var longPressRunnable: Runnable? = null

    companion object {
        private const val TAG = "ScrolaOverlayService"
        const val ACTION_START = "ACTION_START_OVERLAY"
        const val ACTION_STOP = "ACTION_STOP_OVERLAY"
        const val ACTION_UPDATE = "ACTION_UPDATE_OVERLAY"
        const val ACTION_REFRESH_CONFIG = "ACTION_REFRESH_OVERLAY_CONFIG"
        const val ACTION_DISMISS_USER = "ACTION_DISMISS_OVERLAY_BY_USER"

        const val EXTRA_TODAY = "EXTRA_TODAY"
        const val EXTRA_LIMIT = "EXTRA_LIMIT"
        const val EXTRA_SESSION = "EXTRA_SESSION"
        const val EXTRA_PLATFORM = "EXTRA_PLATFORM"
        const val EXTRA_IS_FOCUS = "EXTRA_IS_FOCUS"
        const val EXTRA_ANIMATE_ENTRANCE = "EXTRA_ANIMATE_ENTRANCE"

        private const val CHANNEL_ID = "scrola_overlay_channel"
        private const val NOTIFICATION_ID = 1001

        @Volatile
        var isServiceRunning: Boolean = false
            private set

        @Volatile
        private var activeInstance: ScrolaOverlayService? = null

        fun start(context: Context, animateEntrance: Boolean = true): Boolean {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                Log.w(TAG, "Cannot start overlay: SYSTEM_ALERT_WINDOW not granted")
                return false
            }
            val instance = activeInstance
            if (isServiceRunning && instance != null && !instance.isStopping) {
                instance.mainHandler.post {
                    if (!instance.isStopping) {
                        instance.handleStartOrRefresh(animateEntrance = animateEntrance)
                    }
                }
                return true
            }
            val intent = Intent(context, ScrolaOverlayService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_ANIMATE_ENTRANCE, animateEntrance)
            }
            return startCompat(context, intent)
        }

        fun stop(context: Context) {
            activeInstance?.let { instance ->
                instance.isStopping = true
                instance.mainHandler.post {
                    instance.dismissAnimatorSet?.cancel()
                    instance.dismissAnimatorSet = null
                    instance.entranceAnimatorSet?.cancel()
                    instance.entranceAnimatorSet = null
                }
            }
            val intent = Intent(context, ScrolaOverlayService::class.java).apply {
                action = ACTION_STOP
            }
            try {
                context.stopService(intent)
            } catch (e: Exception) {
                Log.w(TAG, "Error stopping ScrolaOverlayService", e)
            }
        }

        fun refreshConfig(context: Context) {
            val instance = activeInstance
            if (!isServiceRunning || instance?.isStopping == true) return
            if (instance != null) {
                instance.mainHandler.post {
                    if (!instance.isStopping) {
                        instance.handleRefreshConfig()
                    }
                }
                return
            }
            val intent = Intent(context, ScrolaOverlayService::class.java).apply {
                action = ACTION_REFRESH_CONFIG
            }
            startCompat(context, intent)
        }

        fun updateStats(
            context: Context,
            today: Int,
            limit: Int,
            session: Int,
            platform: String = "",
            isFocus: Boolean = false
        ) {
            val dm = ScrolaDataManager.getInstance(context)
            if (!dm.isOverlayEnabled()) return
            if (!dm.isTrackingEnabled() && !dm.isFocusModeActive()) return
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                return
            }

            // Deliver updates directly when already running to avoid Android 12+ background FGS restrictions.
            val instance = activeInstance
            if (isServiceRunning && instance != null && !instance.isStopping) {
                instance.mainHandler.post {
                    if (!instance.isStopping) {
                        instance.handleLiveStatsUpdate(today, limit, session, platform, isFocus)
                    }
                }
                return
            }

            val intent = Intent(context, ScrolaOverlayService::class.java).apply {
                action = ACTION_UPDATE
                putExtra(EXTRA_TODAY, today)
                putExtra(EXTRA_LIMIT, limit)
                putExtra(EXTRA_SESSION, session)
                putExtra(EXTRA_PLATFORM, platform)
                putExtra(EXTRA_IS_FOCUS, isFocus)
            }
            startCompat(context, intent)
        }

        private fun startCompat(context: Context, intent: Intent): Boolean {
            return try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
                true
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start ScrolaOverlayService", e)
                false
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isServiceRunning = true
        isStopping = false
        activeInstance = this
        createNotificationChannel()
        startServiceForeground()
        loadConfigFromDataManager()
    }

    private fun loadConfigFromDataManager() {
        val dm = ScrolaDataManager.getInstance(this)
        stickToTopCentre = dm.isStickToNotch()
        isExpanded = dm.isOverlayExpanded()
        overlaySize = dm.getOverlaySize()
    }

    private fun startServiceForeground() {
        val notification = buildNotification()
        try {
            if (Build.VERSION.SDK_INT >= 34) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            Log.e(TAG, "startForeground failed", e)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val dm = ScrolaDataManager.getInstance(this)
        if (intent == null) {
            // START_STICKY process restart: only re-attach if Scrola overlay should be visible
            if (!dm.isOverlayEnabled() || (!dm.isTrackingEnabled() && !dm.isFocusModeActive())) {
                isStopping = true
                stopSelf()
                return START_NOT_STICKY
            }
            isStopping = false
            handleStartOrRefresh(animateEntrance = false)
            return START_STICKY
        }

        when (intent.action) {
            ACTION_STOP -> {
                isStopping = true
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_DISMISS_USER -> {
                dismissByUser(animateOut = false)
                return START_NOT_STICKY
            }
            ACTION_START -> {
                isStopping = false
                dismissAnimatorSet?.cancel()
                dismissAnimatorSet = null
                handleStartOrRefresh(
                    animateEntrance = intent.getBooleanExtra(EXTRA_ANIMATE_ENTRANCE, true)
                )
            }
            ACTION_REFRESH_CONFIG -> {
                handleRefreshConfig()
            }
            ACTION_UPDATE -> {
                val today = intent.getIntExtra(EXTRA_TODAY, dm.getTotalReelsToday())
                val limit = intent.getIntExtra(EXTRA_LIMIT, dm.getTotalLimit())
                val session = intent.getIntExtra(EXTRA_SESSION, dm.getSessionCount())
                val platform = intent.getStringExtra(EXTRA_PLATFORM) ?: lastPlatform
                val isFocus = intent.getBooleanExtra(EXTRA_IS_FOCUS, dm.isFocusModeActive())
                handleLiveStatsUpdate(today, limit, session, platform, isFocus)
            }
        }
        return START_STICKY
    }

    private fun shouldDisplayOverlay(dm: ScrolaDataManager): Boolean {
        return dm.isOverlayEnabled() && (dm.isTrackingEnabled() || dm.isFocusModeActive())
    }

    private fun handleStartOrRefresh(animateEntrance: Boolean) {
        val dm = ScrolaDataManager.getInstance(this)
        if (!shouldDisplayOverlay(dm)) {
            isStopping = true
            stopSelf()
            return
        }
        dismissAnimatorSet?.cancel()
        dismissAnimatorSet = null

        val wasAlreadyShowing = isViewAddedToWindow && rootContainer != null
        loadConfigFromDataManager()
        ensureOverlayAttached(hiddenForEntrance = !wasAlreadyShowing && animateEntrance)
        applyLayoutSizingAndPosition(animateSnap = false)
        updateUI(
            dm.getTotalReelsToday(),
            dm.getTotalLimit(),
            dm.getSessionCount(),
            lastPlatform,
            dm.isFocusModeActive()
        )
        if (!wasAlreadyShowing && animateEntrance) {
            playNotchDockEntranceAnimation()
        } else if (entranceAnimatorSet?.isRunning != true) {
            pillContainer?.apply {
                alpha = 1f
                translationY = 0f
                scaleX = 1f
                scaleY = 1f
            }
        }
    }

    private fun handleRefreshConfig() {
        val dm = ScrolaDataManager.getInstance(this)
        if (!shouldDisplayOverlay(dm)) {
            isStopping = true
            stopSelf()
            return
        }
        val previousStick = stickToTopCentre
        loadConfigFromDataManager()
        ensureOverlayAttached(hiddenForEntrance = false)
        applyLayoutSizingAndPosition(animateSnap = (!previousStick && stickToTopCentre))
        updateUI(
            dm.getTotalReelsToday(),
            dm.getTotalLimit(),
            dm.getSessionCount(),
            lastPlatform,
            dm.isFocusModeActive()
        )
    }

    private fun handleLiveStatsUpdate(
        today: Int,
        limit: Int,
        session: Int,
        platform: String,
        isFocus: Boolean
    ) {
        val dm = ScrolaDataManager.getInstance(this)
        if (!shouldDisplayOverlay(dm)) {
            isStopping = true
            stopSelf()
            return
        }
        if (platform.isNotEmpty()) lastPlatform = platform
        ensureOverlayAttached(hiddenForEntrance = false)
        updateUI(today, limit, session, lastPlatform, isFocus)
    }

    private fun ensureOverlayAttached(hiddenForEntrance: Boolean = false) {
        if (isViewAddedToWindow && rootContainer != null) return
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)) {
            initOverlay(hiddenForEntrance = hiddenForEntrance)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Scrola Floating Counter",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows Brainy in the notch pill counter"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val launchIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )

        val dismissIntent = Intent(this, ScrolaOverlayService::class.java).apply {
            action = ACTION_DISMISS_USER
        }
        val dismissPendingIntent = PendingIntent.getService(
            this,
            1,
            dismissIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Scrola Active")
            .setContentText("Brainy is guarding your feed (long-press pill to hide)")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setContentIntent(pendingIntent)
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Remove mascot",
                dismissPendingIntent
            )
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    /**
     * Computes Y offset using FLAG_LAYOUT_IN_SCREEN so the pill hugs directly
     * beneath the center camera notch/cutout without covering the camera lens.
     */
    private fun getNotchDockY(): Int {
        val screenW = resources.displayMetrics.widthPixels
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val cutout = windowManager?.currentWindowMetrics?.windowInsets?.displayCutout
                ?: rootContainer?.rootWindowInsets?.displayCutout
            if (cutout != null) {
                val centerMin = screenW * 0.2f
                val centerMax = screenW * 0.8f
                val centerRect = cutout.boundingRects.firstOrNull { rect ->
                    rect.top <= dpToPx(24) && rect.centerX() in centerMin.toInt()..centerMax.toInt()
                }
                if (centerRect != null && centerRect.bottom > 0) {
                    return centerRect.bottom + dpToPx(2)
                }
                if (cutout.safeInsetTop > 0) {
                    return cutout.safeInsetTop + dpToPx(2)
                }
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val cutout = rootContainer?.rootWindowInsets?.displayCutout
            if (cutout != null && cutout.safeInsetTop > 0) {
                return cutout.safeInsetTop + dpToPx(2)
            }
        }

        // Fallback if cutout hasn't attached yet: compact top notch band
        val statusRes = resources.getIdentifier("status_bar_height", "dimen", "android")
        val statusH = if (statusRes > 0) resources.getDimensionPixelSize(statusRes) else dpToPx(28)
        return max(dpToPx(6), statusH - dpToPx(4))
    }

    private data class PillMetrics(
        val mascotWidthDp: Int,
        val mascotHeightDp: Int,
        val primarySp: Float,
        val secondarySp: Float,
        val padH: Int,
        val padV: Int
    )

    private fun metricsForSize(size: String): PillMetrics {
        return when (size.lowercase()) {
            "small" -> PillMetrics(
                mascotWidthDp = 24,
                mascotHeightDp = 22,
                primarySp = 12f,
                secondarySp = 11f,
                padH = 10,
                padV = 4
            )
            "large" -> PillMetrics(
                mascotWidthDp = 34,
                mascotHeightDp = 31,
                primarySp = 14.5f,
                secondarySp = 13f,
                padH = 14,
                padV = 7
            )
            else -> PillMetrics(
                mascotWidthDp = 28,
                mascotHeightDp = 26,
                primarySp = 13f,
                secondarySp = 12f,
                padH = 12,
                padV = 5
            )
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initOverlay(hiddenForEntrance: Boolean = false) {
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val previous = rootContainer
        if (previous != null) {
            try {
                if (isViewAddedToWindow || previous.isAttachedToWindow) {
                    windowManager?.removeViewImmediate(previous)
                }
            } catch (e: Exception) {
                Log.w(TAG, "Failed removing prior overlay view", e)
            }
            rootContainer = null
            isViewAddedToWindow = false
        }

        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val dm = ScrolaDataManager.getInstance(this)
        val initialX = if (stickToTopCentre) 0 else dm.getFreeOverlayX()
        val savedFreeY = dm.getFreeOverlayY()
        val initialY = if (stickToTopCentre || savedFreeY < 0) getNotchDockY() else savedFreeY

        params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            x = initialX
            y = initialY
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }

        // Transparent wrapper allows smooth spring overshoot inside WindowManager bounds
        rootContainer = FrameLayout(this).apply {
            clipChildren = false
            clipToPadding = false
            setPadding(dpToPx(6), dpToPx(2), dpToPx(6), dpToPx(12))
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
                setOnApplyWindowInsetsListener { _, insets ->
                    if (stickToTopCentre) {
                        val targetY = getNotchDockY()
                        if (params?.y != targetY) {
                            params?.x = 0
                            params?.y = targetY
                            safeUpdateViewLayout()
                        }
                    }
                    insets
                }
            }
        }

        val m = metricsForSize(overlaySize)

        pillContainer = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dpToPx(m.padH), dpToPx(m.padV), dpToPx(m.padH + 2), dpToPx(m.padV))
            background = createPillBackground(Color.parseColor("#111111"), Color.parseColor("#2A2A2A"))
            elevation = dpToPx(10).toFloat()
        }

        // 1. Live reactive Brainy Mascot View (replaces old plain orange dot!)
        brainyView = BrainyOverlayView(this).apply {
            setSkinIndex(dm.getSkinIndex())
            setMood("happy")
        }
        val mascotLp = LinearLayout.LayoutParams(
            dpToPx(m.mascotWidthDp),
            dpToPx(m.mascotHeightDp)
        ).apply {
            rightMargin = dpToPx(8)
        }
        pillContainer?.addView(brainyView, mascotLp)

        // 2. Primary watched count
        primaryTextView = TextView(this).apply {
            text = "${dm.getTotalReelsToday()}"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, m.primarySp)
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            includeFontPadding = false
        }
        pillContainer?.addView(primaryTextView)

        // 3. Divider bar
        dividerView = View(this).apply {
            setBackgroundColor(Color.parseColor("#383838"))
        }
        val divLp = LinearLayout.LayoutParams(dpToPx(1), dpToPx(13)).apply {
            leftMargin = dpToPx(7)
            rightMargin = dpToPx(7)
        }
        pillContainer?.addView(dividerView, divLp)

        // 4. Secondary left / status label
        secondaryTextView = TextView(this).apply {
            val left = max(0, dm.getTotalLimit() - dm.getTotalReelsToday())
            text = if (isExpanded) "$left left" else "$left"
            setTextColor(Color.parseColor("#FF6B24"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, m.secondarySp)
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            includeFontPadding = false
        }
        pillContainer?.addView(secondaryTextView)

        // 5. Compact close / remove button visible cleanly when expanded
        closeButtonView = TextView(this).apply {
            text = "✕"
            gravity = Gravity.CENTER
            setTextColor(Color.parseColor("#E5E5E5"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 10.5f)
            typeface = Typeface.DEFAULT_BOLD
            includeFontPadding = false
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#262626"))
                setStroke(dpToPx(1), Color.parseColor("#3D3D3D"))
            }
            visibility = if (isExpanded) View.VISIBLE else View.GONE
            setOnClickListener {
                dismissByUser(animateOut = true)
            }
        }
        val closeLp = LinearLayout.LayoutParams(dpToPx(22), dpToPx(22)).apply {
            leftMargin = dpToPx(8)
        }
        pillContainer?.addView(closeButtonView, closeLp)

        val pillLp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT,
            Gravity.TOP or Gravity.CENTER_HORIZONTAL
        )
        rootContainer?.addView(pillContainer, pillLp)

        if (hiddenForEntrance) {
            pillContainer?.apply {
                translationY = dpToPx(14).toFloat()
                scaleX = 0.88f
                scaleY = 0.88f
                alpha = 0f
            }
        }

        setupTouchHandling()

        try {
            windowManager?.addView(rootContainer, params)
            isViewAddedToWindow = true
            updateUI(
                dm.getTotalReelsToday(),
                dm.getTotalLimit(),
                dm.getSessionCount(),
                lastPlatform,
                dm.isFocusModeActive()
            )
        } catch (e: Exception) {
            isViewAddedToWindow = false
            rootContainer = null
            Log.e(TAG, "windowManager.addView failed", e)
        }
    }

    private fun applyLayoutSizingAndPosition(animateSnap: Boolean) {
        val m = metricsForSize(overlaySize)
        pillContainer?.setPadding(
            dpToPx(m.padH),
            dpToPx(m.padV),
            dpToPx(m.padH + 2),
            dpToPx(m.padV)
        )
        brainyView?.layoutParams = (brainyView?.layoutParams as? LinearLayout.LayoutParams)?.apply {
            width = dpToPx(m.mascotWidthDp)
            height = dpToPx(m.mascotHeightDp)
        }
        primaryTextView?.setTextSize(TypedValue.COMPLEX_UNIT_SP, m.primarySp)
        secondaryTextView?.setTextSize(TypedValue.COMPLEX_UNIT_SP, m.secondarySp)

        val dm = ScrolaDataManager.getInstance(this)
        brainyView?.setSkinIndex(dm.getSkinIndex())

        if (stickToTopCentre) {
            val targetY = getNotchDockY()
            if (animateSnap && params != null) {
                animateWindowPosition(params!!.x, params!!.y, 0, targetY)
            } else {
                params?.x = 0
                params?.y = targetY
                safeUpdateViewLayout()
            }
        } else {
            val savedY = dm.getFreeOverlayY()
            params?.x = dm.getFreeOverlayX()
            params?.y = if (savedY >= 0) savedY else getNotchDockY() + dpToPx(24)
            safeUpdateViewLayout()
        }
    }

    private fun animateWindowPosition(fromX: Int, fromY: Int, toX: Int, toY: Int) {
        positionAnimator?.cancel()
        positionAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = 360L
            interpolator = OvershootInterpolator(1.05f)
            addUpdateListener { anim ->
                val t = anim.animatedFraction
                params?.x = (fromX + (toX - fromX) * t).toInt()
                params?.y = (fromY + (toY - fromY) * t).toInt()
                safeUpdateViewLayout()
            }
            start()
        }
    }

    private fun playNotchDockEntranceAnimation() {
        val pill = pillContainer ?: return
        entranceAnimatorSet?.cancel()
        entranceAnimatorSet = null
        pill.animate().cancel()

        val animatorsEnabled =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.O || ValueAnimator.areAnimatorsEnabled()
        if (!animatorsEnabled) {
            pill.translationY = 0f
            pill.scaleX = 1f
            pill.scaleY = 1f
            pill.alpha = 1f
            return
        }

        val startOffsetY = dpToPx(14).toFloat()
        pill.translationY = startOffsetY
        pill.scaleX = 0.88f
        pill.scaleY = 0.88f
        pill.alpha = 0f

        pill.post {
            if (isStopping || pillContainer !== pill) return@post

            val slideY = ObjectAnimator.ofFloat(pill, View.TRANSLATION_Y, startOffsetY, 0f)
            val scaleX = ObjectAnimator.ofFloat(pill, View.SCALE_X, 0.88f, 1f)
            val scaleY = ObjectAnimator.ofFloat(pill, View.SCALE_Y, 0.88f, 1f)
            val alpha = ObjectAnimator.ofFloat(pill, View.ALPHA, 0f, 1f)

            entranceAnimatorSet = AnimatorSet().apply {
                playTogether(slideY, scaleX, scaleY, alpha)
                duration = 250L
                interpolator = OvershootInterpolator(1.08f)
                addListener(object : AnimatorListenerAdapter() {
                    private fun settleFinalState() {
                        pill.translationY = 0f
                        pill.scaleX = 1f
                        pill.scaleY = 1f
                        pill.alpha = 1f
                    }

                    override fun onAnimationEnd(animation: Animator) = settleFinalState()
                    override fun onAnimationCancel(animation: Animator) = settleFinalState()
                })
                start()
            }
        }
    }

    private fun playMicroTapBounce() {
        val mascot = brainyView ?: return
        mascot.animate().cancel()
        mascot.scaleX = 0.84f
        mascot.scaleY = 0.84f
        mascot.animate()
            .scaleX(1f)
            .scaleY(1f)
            .setDuration(260L)
            .setInterpolator(OvershootInterpolator(2.0f))
            .start()
    }

    private fun createPillBackground(bgColor: Int, strokeColor: Int): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dpToPx(999).toFloat()
            setColor(bgColor)
            setStroke(dpToPx(1), strokeColor)
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun setupTouchHandling() {
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        var hasMoved = false
        var longPressed = false
        var lastTapTime = 0L

        pillContainer?.setOnTouchListener { _, event ->
            val currentParams = params ?: return@setOnTouchListener false
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = currentParams.x
                    initialY = currentParams.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    hasMoved = false
                    longPressed = false
                    longPressRunnable?.let { longPressHandler.removeCallbacks(it) }
                    longPressRunnable = Runnable {
                        if (!hasMoved) {
                            longPressed = true
                            performDismissHaptic()
                            dismissByUser(animateOut = true)
                        }
                    }
                    longPressHandler.postDelayed(longPressRunnable!!, 500L)
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - initialTouchX).toInt()
                    val dy = (event.rawY - initialTouchY).toInt()
                    if (abs(dx) > 10 || abs(dy) > 10) {
                        hasMoved = true
                        longPressRunnable?.let { longPressHandler.removeCallbacks(it) }
                    }
                    if (stickToTopCentre) {
                        // Locked cleanly at top notch when "Top Notch" mode is active
                        return@setOnTouchListener true
                    }
                    if (hasMoved) {
                        val metrics = resources.displayMetrics
                        val halfWidth = metrics.widthPixels / 2
                        val minY = getNotchDockY()
                        val maxY = metrics.heightPixels - dpToPx(110)

                        currentParams.x = (initialX + dx).coerceIn(
                            -(halfWidth - dpToPx(48)),
                            halfWidth - dpToPx(48)
                        )
                        currentParams.y = (initialY + dy).coerceIn(minY, maxY)
                        safeUpdateViewLayout()
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    longPressRunnable?.let { longPressHandler.removeCallbacks(it) }
                    if (longPressed) return@setOnTouchListener true

                    if (hasMoved && !stickToTopCentre) {
                        ScrolaDataManager.getInstance(this@ScrolaOverlayService)
                            .setFreeOverlayPosition(currentParams.x, currentParams.y)
                    } else if (!hasMoved) {
                        playMicroTapBounce()
                        val now = System.currentTimeMillis()
                        if (now - lastTapTime < 340L) {
                            val launchIntent = Intent(
                                this@ScrolaOverlayService,
                                MainActivity::class.java
                            ).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                            }
                            startActivity(launchIntent)
                            lastTapTime = 0L
                        } else {
                            toggleExpandCollapse()
                            lastTapTime = now
                        }
                    }
                    true
                }
                MotionEvent.ACTION_CANCEL -> {
                    longPressRunnable?.let { longPressHandler.removeCallbacks(it) }
                    false
                }
                else -> false
            }
        }
    }

    private fun performDismissHaptic() {
        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        if (vibrator != null && vibrator.hasVibrator()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(40L, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(40L)
            }
        }
    }

    private fun dismissByUser(animateOut: Boolean) {
        isStopping = true
        entranceAnimatorSet?.cancel()
        entranceAnimatorSet = null
        dismissAnimatorSet?.cancel()
        dismissAnimatorSet = null

        ScrolaDataManager.getInstance(this).setOverlayEnabled(false)
        val broadcast = Intent(ScrolaAccessibilityService.BROADCAST_REEL_EVENT).apply {
            setPackage(packageName)
            putExtra(ScrolaAccessibilityService.EXTRA_EVENT_TYPE, "overlay_dismissed")
            putExtra(ScrolaAccessibilityService.EXTRA_PLATFORM, "")
        }
        sendBroadcast(broadcast)

        val pill = pillContainer
        val animatorsEnabled =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.O || ValueAnimator.areAnimatorsEnabled()
        if (!animateOut || pill == null || !animatorsEnabled) {
            stopSelf()
            return
        }

        pill.animate().cancel()
        val scaleX = ObjectAnimator.ofFloat(pill, View.SCALE_X, pill.scaleX, 0.45f)
        val scaleY = ObjectAnimator.ofFloat(pill, View.SCALE_Y, pill.scaleY, 0.45f)
        val alpha = ObjectAnimator.ofFloat(pill, View.ALPHA, pill.alpha, 0f)
        dismissAnimatorSet = AnimatorSet().apply {
            playTogether(scaleX, scaleY, alpha)
            duration = 170L
            addListener(object : AnimatorListenerAdapter() {
                private var wasCancelled = false

                override fun onAnimationCancel(animation: Animator) {
                    wasCancelled = true
                }

                override fun onAnimationEnd(animation: Animator) {
                    if (!wasCancelled && isStopping) {
                        stopSelf()
                    }
                }
            })
            start()
        }
    }

    private fun toggleExpandCollapse() {
        isExpanded = !isExpanded
        val dm = ScrolaDataManager.getInstance(this)
        dm.setOverlayExpanded(isExpanded)
        updateUI(
            dm.getTotalReelsToday(),
            dm.getTotalLimit(),
            dm.getSessionCount(),
            lastPlatform,
            dm.isFocusModeActive()
        )
    }

    fun updateUI(today: Int, limit: Int, session: Int, platform: String, isFocus: Boolean) {
        val dm = ScrolaDataManager.getInstance(this)
        brainyView?.setSkinIndex(dm.getSkinIndex())

        val remaining = max(0, limit - today)
        val isLimitReached = limit > 0 && today >= limit
        val ratio = if (limit > 0) today.toFloat() / limit.toFloat() else 0f

        val mood = when {
            isFocus -> "focused"
            isLimitReached -> "sad"
            ratio >= 0.78f -> "tired"
            ratio >= 0.48f -> "neutral"
            else -> "happy"
        }
        brainyView?.setMood(mood)

        val shortPlatform = when (platform.lowercase()) {
            "instagram" -> " · IG"
            "youtube" -> " · YT"
            "tiktok" -> " · TT"
            "facebook" -> " · FB"
            "snapchat" -> " · SC"
            "x" -> " · X"
            "reddit" -> " · RD"
            "moj" -> " · MJ"
            else -> ""
        }

        if (isExpanded) {
            primaryTextView?.text = "$today watched"
            secondaryTextView?.text = if (isFocus) {
                "LOCKED"
            } else {
                "$remaining left$shortPlatform"
            }
            closeButtonView?.visibility = View.VISIBLE
        } else {
            primaryTextView?.text = "$today"
            secondaryTextView?.text = when {
                isFocus -> "LOCK"
                isLimitReached -> "0 left"
                else -> "$remaining left"
            }
            closeButtonView?.visibility = View.GONE
        }

        val strokeColor = when {
            isFocus || isLimitReached -> Color.parseColor("#FF5252")
            ratio >= 0.8f -> Color.parseColor("#FFC15A")
            else -> Color.parseColor("#2E2E2E")
        }

        val rightColor = when {
            isFocus || isLimitReached -> Color.parseColor("#FF5252")
            ratio >= 0.8f -> Color.parseColor("#FFC15A")
            else -> Color.parseColor("#FF6B24")
        }

        secondaryTextView?.setTextColor(rightColor)
        pillContainer?.background = createPillBackground(Color.parseColor("#111111"), strokeColor)

        safeUpdateViewLayout()
    }

    private fun safeUpdateViewLayout() {
        val container = rootContainer ?: return
        val currentParams = params ?: return
        if (!isViewAddedToWindow && !container.isAttachedToWindow) return
        try {
            windowManager?.updateViewLayout(container, currentParams)
        } catch (e: Exception) {
            Log.w(TAG, "updateViewLayout failed", e)
        }
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }

    override fun onDestroy() {
        isServiceRunning = false
        isStopping = true
        if (activeInstance === this) {
            activeInstance = null
        }
        entranceAnimatorSet?.cancel()
        entranceAnimatorSet = null
        dismissAnimatorSet?.cancel()
        dismissAnimatorSet = null
        longPressHandler.removeCallbacksAndMessages(null)
        positionAnimator?.cancel()
        positionAnimator = null
        val container = rootContainer
        if (container != null) {
            try {
                if (isViewAddedToWindow || container.isAttachedToWindow) {
                    windowManager?.removeViewImmediate(container)
                }
            } catch (e: Exception) {
                Log.w(TAG, "removeViewImmediate failed", e)
            }
            rootContainer = null
        }
        isViewAddedToWindow = false
        super.onDestroy()
    }
}

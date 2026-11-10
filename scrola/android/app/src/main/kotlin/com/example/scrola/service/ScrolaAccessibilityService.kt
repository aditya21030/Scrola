package com.example.scrola.service

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class ScrolaAccessibilityService : AccessibilityService() {

    private lateinit var dataManager: ScrolaDataManager
    private var lastScrollTimestamp: Long = 0L
    private var lastBlockTimestamp: Long = 0L
    private var currentPlatform: String? = null
    private var isInShortsFeed: Boolean = false

    companion object {
        const val BROADCAST_REEL_EVENT = "com.scrola.app.REEL_EVENT"
        const val EXTRA_EVENT_TYPE = "event_type"
        const val EXTRA_PLATFORM = "platform"
        const val EXTRA_COUNT = "count"
        const val EXTRA_TOTAL = "total"

        var isServiceRunning = false
            private set
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        dataManager = ScrolaDataManager.getInstance(this)
        isServiceRunning = true
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        val packageName = event.packageName?.toString() ?: return
        val platform = resolvePlatform(packageName)

        if (platform == null) {
            // User navigated away from tracked platforms
            if (isInShortsFeed) {
                isInShortsFeed = false
                currentPlatform = null
            }
            return
        }

        currentPlatform = platform

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                checkIfInShortsFeed(platform, event)
            }
            AccessibilityEvent.TYPE_VIEW_SCROLLED -> {
                handleScrollEvent(platform, event)
            }
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                if (!isInShortsFeed) {
                    checkIfInShortsFeed(platform, event)
                }
            }
        }
    }

    private fun resolvePlatform(packageName: String): String? {
        return when (packageName) {
            "com.instagram.android" -> "instagram"
            "com.google.android.youtube" -> "youtube"
            "com.facebook.katana" -> "facebook"
            "com.snapchat.android" -> "snapchat"
            else -> null
        }
    }

    private fun checkIfInShortsFeed(platform: String, event: AccessibilityEvent) {
        val rootNode = rootInActiveWindow ?: return

        isInShortsFeed = when (platform) {
            "instagram" -> isInstagramReels(rootNode, event)
            "youtube" -> isYouTubeShorts(rootNode, event)
            "facebook" -> isFacebookReels(rootNode, event)
            "snapchat" -> isSnapchatSpotlight(rootNode, event)
            else -> false
        }

        if (isInShortsFeed) {
            onShortsFeedEntered(platform)
        }
    }

    private fun isInstagramReels(root: AccessibilityNodeInfo, event: AccessibilityEvent): Boolean {
        val className = event.className?.toString() ?: ""
        if (className.contains("Clips", ignoreCase = true) || className.contains("ClipsViewer", ignoreCase = true)) {
            return true
        }

        // Modern Instagram Reels container IDs (specifically avoiding Stories "reel_viewer_container")
        val clipsContainer = root.findAccessibilityNodeInfosByViewId("com.instagram.android:id/clips_video_container")
        if (clipsContainer.isNotEmpty()) return true

        val clipsLayout = root.findAccessibilityNodeInfosByViewId("com.instagram.android:id/layout_clips_viewer")
        if (clipsLayout.isNotEmpty()) return true

        val clipsSwipe = root.findAccessibilityNodeInfosByViewId("com.instagram.android:id/clips_swipe_refresh_layout")
        if (clipsSwipe.isNotEmpty()) return true

        val clipsItem = root.findAccessibilityNodeInfosByViewId("com.instagram.android:id/clips_item_container")
        if (clipsItem.isNotEmpty()) return true

        // Content description tag
        val contentDesc = event.contentDescription?.toString() ?: ""
        if (contentDesc.contains("Reels, tab", ignoreCase = true) || contentDesc.startsWith("Reel by", ignoreCase = true)) {
            return true
        }

        return false
    }

    private fun isYouTubeShorts(root: AccessibilityNodeInfo, event: AccessibilityEvent): Boolean {
        val className = event.className?.toString() ?: ""
        if (className.contains("Shorts", ignoreCase = true)) {
            return true
        }

        val shortsNodes = root.findAccessibilityNodeInfosByViewId("com.google.android.youtube:id/shorts_container")
        if (shortsNodes.isNotEmpty()) return true

        val reelPlayer = root.findAccessibilityNodeInfosByViewId("com.google.android.youtube:id/reel_player_page_view")
        if (reelPlayer.isNotEmpty()) return true

        val reelRecycler = root.findAccessibilityNodeInfosByViewId("com.google.android.youtube:id/reel_recycler")
        if (reelRecycler.isNotEmpty()) return true

        val contentDesc = event.contentDescription?.toString() ?: ""
        if (contentDesc.contains("Shorts", ignoreCase = true)) {
            return true
        }

        return false
    }

    private fun isFacebookReels(root: AccessibilityNodeInfo, event: AccessibilityEvent): Boolean {
        val className = event.className?.toString() ?: ""
        if (className.contains("FbShorts", ignoreCase = true) || className.contains("Reels", ignoreCase = true)) {
            return true
        }
        val textNodes = root.findAccessibilityNodeInfosByText("Reels")
        return textNodes.isNotEmpty()
    }

    private fun isSnapchatSpotlight(root: AccessibilityNodeInfo, event: AccessibilityEvent): Boolean {
        val textNodes = root.findAccessibilityNodeInfosByText("Spotlight")
        return textNodes.isNotEmpty()
    }

    private fun onShortsFeedEntered(platform: String) {
        checkAndEnforceLimits(platform)

        if (dataManager.isOverlayEnabled()) {
            ScrolaOverlayService.updateStats(
                this,
                dataManager.getTotalReelsToday(),
                dataManager.getTotalLimit(),
                dataManager.getSessionCount(),
                platform,
                dataManager.isFocusModeActive()
            )
        }
    }

    private fun handleScrollEvent(platform: String, event: AccessibilityEvent) {
        val now = System.currentTimeMillis()

        // Debounce: A distinct reel swipe takes at least 1200ms
        if (now - lastScrollTimestamp < 1200) {
            return
        }

        val root = rootInActiveWindow
        val inFeed = if (root != null) {
            when (platform) {
                "instagram" -> isInstagramReels(root, event)
                "youtube" -> isYouTubeShorts(root, event)
                "facebook" -> isFacebookReels(root, event)
                "snapchat" -> isSnapchatSpotlight(root, event)
                else -> false
            }
        } else isInShortsFeed

        if (!inFeed) return

        lastScrollTimestamp = now

        // Check if limits are exceeded before counting
        val isBlocked = checkAndEnforceLimits(platform)
        if (isBlocked) {
            return
        }

        // Increment count
        val totalToday = dataManager.incrementReel(platform)
        val platformToday = dataManager.getPlatformReels(platform)

        if (dataManager.isOverlayEnabled()) {
            ScrolaOverlayService.updateStats(
                this,
                totalToday,
                dataManager.getTotalLimit(),
                dataManager.getSessionCount(),
                platform,
                dataManager.isFocusModeActive()
            )
        }

        val intent = Intent(BROADCAST_REEL_EVENT).apply {
            putExtra(EXTRA_EVENT_TYPE, "reel_watched")
            putExtra(EXTRA_PLATFORM, platform)
            putExtra(EXTRA_COUNT, platformToday)
            putExtra(EXTRA_TOTAL, totalToday)
        }
        sendBroadcast(intent)

        checkAndEnforceLimits(platform)
    }

    private fun checkAndEnforceLimits(platform: String): Boolean {
        val isFocus = dataManager.isFocusModeActive()
        val isLimitReached = dataManager.isPlatformLimitReached(platform)

        if (isFocus || isLimitReached) {
            triggerBlockAction(platform, isFocus)
            return true
        }
        return false
    }

    private fun triggerBlockAction(platform: String, isFocus: Boolean) {
        val now = System.currentTimeMillis()
        // Cooldown protection: Prevent multi-back press spam within 2 seconds
        if (now - lastBlockTimestamp < 2000) {
            return
        }
        lastBlockTimestamp = now

        // Haptic alert pattern
        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        if (vibrator != null && vibrator.hasVibrator()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(
                    VibrationEffect.createWaveform(
                        longArrayOf(0, 150, 100, 200),
                        -1
                    )
                )
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(longArrayOf(0, 150, 100, 200), -1)
            }
        }

        // Perform Back action to exit the feed
        performGlobalAction(GLOBAL_ACTION_BACK)

        val intent = Intent(BROADCAST_REEL_EVENT).apply {
            putExtra(EXTRA_EVENT_TYPE, if (isFocus) "focus_block_enforced" else "limit_block_enforced")
            putExtra(EXTRA_PLATFORM, platform)
        }
        sendBroadcast(intent)
    }

    override fun onInterrupt() {}
}

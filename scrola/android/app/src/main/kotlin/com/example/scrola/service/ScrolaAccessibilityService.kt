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
        if (!dataManager.isTrackingEnabled() && !dataManager.isFocusModeActive()) {
            isInShortsFeed = false
            return
        }
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
            "com.instagram.android", "com.instagram.lite" -> "instagram"
            "com.google.android.youtube" -> "youtube"
            "com.facebook.katana", "com.facebook.lite" -> "facebook"
            "com.snapchat.android" -> "snapchat"
            "com.zhiliaoapp.musically",
            "com.ss.android.ugc.trill",
            "com.zhiliaoapp.musically.go" -> "tiktok"
            "com.twitter.android" -> "x"
            "com.reddit.frontpage" -> "reddit"
            "in.mohalla.video", "in.mohalla.video.lite" -> "moj"
            else -> null
        }
    }

    private fun checkIfInShortsFeed(platform: String, event: AccessibilityEvent) {
        if (!dataManager.isPlatformSelected(platform) && !dataManager.isFocusModeActive()) {
            isInShortsFeed = false
            return
        }
        val rootNode = rootInActiveWindow ?: return

        val wasInFeed = isInShortsFeed
        isInShortsFeed = isPlatformInShortsFeed(platform, rootNode, event)

        if (isInShortsFeed && !wasInFeed) {
            onShortsFeedEntered(platform)
        }
    }

    private fun isPlatformInShortsFeed(
        platform: String,
        rootNode: AccessibilityNodeInfo,
        event: AccessibilityEvent
    ): Boolean {
        return when (platform) {
            "instagram" -> isInstagramReels(rootNode, event)
            "youtube" -> isYouTubeShorts(rootNode, event)
            "facebook" -> isFacebookReels(rootNode, event)
            "snapchat" -> isSnapchatSpotlight(rootNode, event)
            "tiktok" -> isTikTokFeed(rootNode, event)
            "x" -> isXVideosFeed(rootNode, event)
            "reddit" -> isRedditWatchFeed(rootNode, event)
            "moj" -> isMojFeed(rootNode, event)
            else -> false
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

    private fun isTikTokFeed(root: AccessibilityNodeInfo, event: AccessibilityEvent): Boolean {
        // Ignore comment drawers/input modals so reading comments does not count as reels
        if (root.findAccessibilityNodeInfosByText("Add comment").isNotEmpty()) {
            return false
        }
        val className = event.className?.toString() ?: ""
        if (className.contains("ViewPager", ignoreCase = true)) {
            return true
        }
        val forYou = root.findAccessibilityNodeInfosByText("For You")
        val following = root.findAccessibilityNodeInfosByText("Following")
        return forYou.isNotEmpty() || following.isNotEmpty()
    }

    private fun isXVideosFeed(root: AccessibilityNodeInfo, event: AccessibilityEvent): Boolean {
        val className = event.className?.toString() ?: ""
        if (className.contains("Immersive", ignoreCase = true) ||
            className.contains("VideoPlayer", ignoreCase = true) ||
            className.contains("ViewPager", ignoreCase = true)
        ) {
            return true
        }
        val viewIds = listOf(
            "com.twitter.android:id/immersive_video_pager",
            "com.twitter.android:id/video_player_view",
            "com.twitter.android:id/av_media_video_player"
        )
        return viewIds.any { root.findAccessibilityNodeInfosByViewId(it).isNotEmpty() }
    }

    private fun isRedditWatchFeed(root: AccessibilityNodeInfo, event: AccessibilityEvent): Boolean {
        val className = event.className?.toString() ?: ""
        if (className.contains("WatchFeed", ignoreCase = true) ||
            className.contains("VideoPager", ignoreCase = true) ||
            className.contains("VideoPlayer", ignoreCase = true)
        ) {
            return true
        }
        val viewIds = listOf(
            "com.reddit.frontpage:id/watch_feed",
            "com.reddit.frontpage:id/video_pager",
            "com.reddit.frontpage:id/video_player"
        )
        if (viewIds.any { root.findAccessibilityNodeInfosByViewId(it).isNotEmpty() }) {
            return true
        }
        val contentDesc = event.contentDescription?.toString() ?: ""
        return contentDesc.contains("Watch", ignoreCase = true) &&
            root.findAccessibilityNodeInfosByViewId("com.reddit.frontpage:id/video_container").isNotEmpty()
    }

    private fun isMojFeed(root: AccessibilityNodeInfo, event: AccessibilityEvent): Boolean {
        if (root.findAccessibilityNodeInfosByText("Add a comment").isNotEmpty()) {
            return false
        }
        val className = event.className?.toString() ?: ""
        if (className.contains("ViewPager", ignoreCase = true) ||
            className.contains("VideoPlayer", ignoreCase = true)
        ) {
            return true
        }
        return root.findAccessibilityNodeInfosByText("For You").isNotEmpty() ||
            root.findAccessibilityNodeInfosByText("Following").isNotEmpty()
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
        if (!dataManager.isPlatformSelected(platform) && !dataManager.isFocusModeActive()) {
            return
        }
        val now = System.currentTimeMillis()

        // Debounce: A distinct reel swipe takes at least 1200ms
        if (now - lastScrollTimestamp < 1200) {
            return
        }

        val root = rootInActiveWindow
        val inFeed = if (root != null) {
            isPlatformInShortsFeed(platform, root, event)
        } else isInShortsFeed

        isInShortsFeed = inFeed
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

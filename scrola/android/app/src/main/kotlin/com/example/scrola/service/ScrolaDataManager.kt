package com.example.scrola.service

import android.content.Context
import android.content.SharedPreferences
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ScrolaDataManager private constructor(context: Context) {

    private val prefs: SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    companion object {
        private const val PREFS_NAME = "scrola_core_prefs"
        private const val KEY_LAST_DATE = "last_date"
        private const val KEY_TOTAL_TODAY = "total_reels_today"
        private const val KEY_SESSION_COUNT = "session_count"
        private const val KEY_TOTAL_LIMIT = "total_daily_limit"
        private const val KEY_FOCUS_ACTIVE = "focus_mode_active"
        private const val KEY_OVERLAY_ENABLED = "overlay_enabled"
        private const val KEY_TRACKING_ENABLED = "tracking_enabled"
        private const val KEY_PLATFORM_LIMITS_ENABLED = "platform_limits_enabled"
        private const val KEY_SELECTED_PLATFORMS = "selected_platforms"
        private const val KEY_STICK_TO_NOTCH = "overlay_stick_to_notch"
        private const val KEY_OVERLAY_EXPANDED = "overlay_expanded"
        private const val KEY_OVERLAY_SIZE = "overlay_size"
        private const val KEY_SKIN_INDEX = "skin_index"
        private const val KEY_FREE_X = "overlay_free_x"
        private const val KEY_FREE_Y = "overlay_free_y"

        @Volatile
        private var instance: ScrolaDataManager? = null

        val SUPPORTED_PLATFORMS = listOf(
            "instagram",
            "youtube",
            "tiktok",
            "snapchat",
            "facebook",
            "x",
            "reddit",
            "moj"
        )

        fun getDefaultPlatformLimit(platform: String, fallbackTotal: Int = 40): Int {
            return when (platform.lowercase()) {
                "instagram" -> 20
                "youtube" -> 15
                "tiktok" -> 15
                "snapchat" -> 5
                "facebook" -> 10
                "x" -> 10
                "reddit" -> 10
                "moj" -> 10
                else -> fallbackTotal
            }
        }

        fun getInstance(context: Context): ScrolaDataManager {
            return instance ?: synchronized(this) {
                instance ?: ScrolaDataManager(context).also { instance = it }
            }
        }
    }

    init {
        checkAndResetDaily()
    }

    private fun getTodayDateString(): String {
        return SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
    }

    fun checkAndResetDaily() {
        val today = getTodayDateString()
        val lastDate = prefs.getString(KEY_LAST_DATE, "")
        if (today != lastDate) {
            val editor = prefs.edit()
                .putString(KEY_LAST_DATE, today)
                .putInt(KEY_TOTAL_TODAY, 0)
                .putInt(KEY_SESSION_COUNT, 0)
            for (platform in SUPPORTED_PLATFORMS) {
                editor.putInt("reels_$platform", 0)
            }
            editor.apply()
        }
    }

    fun incrementReel(platform: String): Int {
        checkAndResetDaily()
        val currentTotal = prefs.getInt(KEY_TOTAL_TODAY, 0) + 1
        val platformKey = "reels_$platform"
        val platformTotal = prefs.getInt(platformKey, 0) + 1

        val sessionCount = prefs.getInt(KEY_SESSION_COUNT, 0) + 1

        prefs.edit()
            .putInt(KEY_TOTAL_TODAY, currentTotal)
            .putInt(platformKey, platformTotal)
            .putInt(KEY_SESSION_COUNT, sessionCount)
            .apply()

        return currentTotal
    }

    fun getTotalReelsToday(): Int {
        checkAndResetDaily()
        return prefs.getInt(KEY_TOTAL_TODAY, 0)
    }

    fun getPlatformReels(platform: String): Int {
        checkAndResetDaily()
        return prefs.getInt("reels_$platform", 0)
    }

    fun getSessionCount(): Int {
        return prefs.getInt(KEY_SESSION_COUNT, 0)
    }

    fun resetSession() {
        prefs.edit().putInt(KEY_SESSION_COUNT, 0).apply()
    }

    fun getTotalLimit(): Int {
        return prefs.getInt(KEY_TOTAL_LIMIT, 40)
    }

    fun setTotalLimit(limit: Int) {
        prefs.edit().putInt(KEY_TOTAL_LIMIT, limit).apply()
    }

    fun getPlatformLimit(platform: String, defaultLimit: Int): Int {
        return prefs.getInt("limit_$platform", defaultLimit)
    }

    fun setPlatformLimit(platform: String, limit: Int) {
        prefs.edit().putInt("limit_$platform", limit).apply()
    }

    fun isFocusModeActive(): Boolean {
        return prefs.getBoolean(KEY_FOCUS_ACTIVE, false)
    }

    fun setFocusModeActive(active: Boolean) {
        prefs.edit().putBoolean(KEY_FOCUS_ACTIVE, active).apply()
    }

    fun isOverlayEnabled(): Boolean {
        return prefs.getBoolean(KEY_OVERLAY_ENABLED, true)
    }

    fun setOverlayEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_OVERLAY_ENABLED, enabled).apply()
    }

    fun isTrackingEnabled(): Boolean {
        return prefs.getBoolean(KEY_TRACKING_ENABLED, false)
    }

    fun setTrackingEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_TRACKING_ENABLED, enabled).apply()
    }

    fun isPlatformLimitsEnabled(): Boolean {
        return prefs.getBoolean(KEY_PLATFORM_LIMITS_ENABLED, false)
    }

    fun setPlatformLimitsEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_PLATFORM_LIMITS_ENABLED, enabled).apply()
    }

    fun getSelectedPlatforms(): Set<String> {
        val raw = prefs.getString(KEY_SELECTED_PLATFORMS, "instagram,youtube") ?: "instagram,youtube"
        return raw.split(",").map { it.trim().lowercase() }.filter { it.isNotEmpty() }.toSet()
    }

    fun setSelectedPlatforms(platformsCsv: String) {
        prefs.edit().putString(KEY_SELECTED_PLATFORMS, platformsCsv).apply()
    }

    fun isPlatformSelected(platform: String): Boolean {
        val selected = getSelectedPlatforms()
        return selected.isEmpty() || selected.contains(platform.lowercase())
    }

    fun isStickToNotch(): Boolean {
        return prefs.getBoolean(KEY_STICK_TO_NOTCH, true)
    }

    fun setStickToNotch(stick: Boolean) {
        prefs.edit().putBoolean(KEY_STICK_TO_NOTCH, stick).apply()
    }

    fun isOverlayExpanded(): Boolean {
        return prefs.getBoolean(KEY_OVERLAY_EXPANDED, false)
    }

    fun setOverlayExpanded(expanded: Boolean) {
        prefs.edit().putBoolean(KEY_OVERLAY_EXPANDED, expanded).apply()
    }

    fun getOverlaySize(): String {
        return prefs.getString(KEY_OVERLAY_SIZE, "Medium") ?: "Medium"
    }

    fun setOverlaySize(size: String) {
        prefs.edit().putString(KEY_OVERLAY_SIZE, size).apply()
    }

    fun getSkinIndex(): Int {
        return prefs.getInt(KEY_SKIN_INDEX, 0)
    }

    fun setSkinIndex(index: Int) {
        prefs.edit().putInt(KEY_SKIN_INDEX, index).apply()
    }

    fun getFreeOverlayX(): Int = prefs.getInt(KEY_FREE_X, 0)

    fun getFreeOverlayY(): Int = prefs.getInt(KEY_FREE_Y, -1)

    fun setFreeOverlayPosition(x: Int, y: Int) {
        prefs.edit()
            .putInt(KEY_FREE_X, x)
            .putInt(KEY_FREE_Y, y)
            .apply()
    }

    fun isPlatformLimitReached(platform: String): Boolean {
        val totalCount = getTotalReelsToday()
        val totalLimit = getTotalLimit()
        if (totalCount >= totalLimit) return true
        if (!isPlatformLimitsEnabled()) return false

        val count = getPlatformReels(platform)
        val limit = getPlatformLimit(
            platform,
            getDefaultPlatformLimit(platform, totalLimit)
        )
        return count >= limit
    }
}

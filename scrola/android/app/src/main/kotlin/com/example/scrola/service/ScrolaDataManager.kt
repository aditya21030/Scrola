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

        @Volatile
        private var instance: ScrolaDataManager? = null

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
            prefs.edit()
                .putString(KEY_LAST_DATE, today)
                .putInt(KEY_TOTAL_TODAY, 0)
                .putInt("reels_instagram", 0)
                .putInt("reels_youtube", 0)
                .putInt("reels_facebook", 0)
                .putInt("reels_snapchat", 0)
                .putInt(KEY_SESSION_COUNT, 0)
                .apply()
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

    fun isPlatformLimitReached(platform: String): Boolean {
        val count = getPlatformReels(platform)
        val limit = getPlatformLimit(platform, when (platform) {
            "instagram" -> 20
            "youtube" -> 15
            "facebook" -> 10
            "snapchat" -> 5
            else -> 40
        })
        val totalCount = getTotalReelsToday()
        val totalLimit = getTotalLimit()

        return (count >= limit) || (totalCount >= totalLimit)
    }
}

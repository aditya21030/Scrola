import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';
import 'gamification_engine.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  @visibleForTesting
  static void resetForTest() {
    _instance = null;
    _prefs = null;
  }

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _prefs = await SharedPreferences.getInstance();
      _instance = StorageService._();
      _instance!._ensureJoinedDate();
      _instance!._checkDailyReset();
      _instance!._applySavedHaptics();
    }
    return _instance!;
  }

  static const List<String> supportedPlatformIds = [
    'instagram',
    'youtube',
    'tiktok',
    'snapchat',
    'facebook',
    'x',
    'reddit',
    'moj',
  ];

  static const Map<String, int> defaultPlatformLimits = {
    'instagram': 20,
    'youtube': 15,
    'tiktok': 15,
    'snapchat': 5,
    'facebook': 10,
    'x': 10,
    'reddit': 10,
    'moj': 10,
  };

  static const String _keyOnboardingComplete = 'scrola_onboarding_complete';
  static const String _keySelectedGoal = 'scrola_selected_goal';
  static const String _keySelectedPlatforms = 'scrola_selected_platforms';

  static const String _keyLastDate = 'scrola_last_date';
  static const String _keyTotalToday = 'scrola_total_today';
  static const String _keySessionReels = 'scrola_session_reels';
  static const String _keyScreenTimeSec = 'scrola_screen_time_sec';
  static const String _keyFocusMinsToday = 'scrola_focus_mins_today';
  static const String _keyFocusSessionsToday = 'scrola_focus_sessions_today';

  static String _countKey(String platformId) => 'scrola_${platformId.toLowerCase()}';
  static String _limitKey(String platformId) =>
      'scrola_${platformId.toLowerCase()}_limit';

  static const String _keyStreakDays = 'scrola_streak_days';
  static const String _keyLastStreakDate = 'scrola_last_streak_date';
  static const String _keyXPTotal = 'scrola_xp_total';
  static const String _keyCurrentLevel = 'scrola_current_level';
  static const String _keyEquippedSkin = 'scrola_equipped_skin';

  static const String _keyTotalLimit = 'scrola_total_limit';

  static const String _keyTrackingEnabled = 'scrola_tracking_enabled';
  static const String _keyPlatformLimitsEnabled = 'scrola_platform_limits_enabled';
  static const String _keyOverlayEnabled = 'scrola_overlay_enabled';
  static const String _keyOverlayStickToNotch = 'scrola_overlay_notch';
  static const String _keyOverlayExpanded = 'scrola_overlay_expanded';
  static const String _keyOverlaySize = 'scrola_overlay_size';
  static const String _keyOverlayReactToPace = 'scrola_overlay_react_to_pace';

  static const String _keyBlockAtLimit = 'scrola_block_at_limit';
  static const String _keyNightBlock = 'scrola_night_block';
  static const String _keyWorkBlock = 'scrola_work_block';
  static const String _keyNightBlockDays = 'scrola_night_block_days';
  static const String _keyWorkBlockDays = 'scrola_work_block_days';
  static const String _keyStrictBlocking = 'scrola_strict_blocking';
  static const String _keyWaitBeforeUnlock = 'scrola_wait_before_unlock';
  static const String _keyShowBrainyOnBlock = 'scrola_show_brainy_on_block';
  static const String _keyDetoxActive = 'scrola_detox_active';
  static const String _keyDetoxDays = 'scrola_detox_days';
  static const String _keyDetoxEndEpochMs = 'scrola_detox_end_epoch_ms';
  static const String _keyDailyBlocksCount = 'scrola_daily_blocks_count';
  static const String _keyEmergencyUnlocksUsedToday =
      'scrola_emergency_unlocks_today';

  static const String _keyHapticsEnabled = 'scrola_haptics_enabled';
  static const String _keyHapticIntensity = 'scrola_haptic_intensity';

  static const String _keyDailyXpCollectedDate = 'scrola_daily_xp_collected_date';
  static const String _keyClaimedRewards = 'scrola_claimed_rewards';
  static const String _keyDailyHistory = 'scrola_daily_history';

  static const String _keyFocusActive = 'scrola_focus_active';
  static const String _keyFocusPaused = 'scrola_focus_paused';
  static const String _keyFocusDurationMinutes = 'scrola_focus_duration_minutes';
  static const String _keyFocusEndEpochMs = 'scrola_focus_end_epoch_ms';
  static const String _keyFocusRemainingSec = 'scrola_focus_remaining_sec';
  static const String _keyFocusBlockedAttempts = 'scrola_focus_blocked_attempts';

  static const String _keyDisplayName = 'scrola_display_name';
  static const String _keyUsername = 'scrola_username';
  static const String _keyEmail = 'scrola_email';
  static const String _keyJoinedDate = 'scrola_joined_date';
  static const String _keyIsProSubscribed = 'scrola_pro_subscribed';
  static const String _keyProPlan = 'scrola_pro_plan';

  static const String _keyNotifWarnNearLimit = 'scrola_notif_warn_near_limit';
  static const String _keyNotifThresholds = 'scrola_notif_thresholds';
  static const String _keyNotifStreakReminder = 'scrola_notif_streak_reminder';
  static const String _keyNotifFocusEnd = 'scrola_notif_focus_end';
  static const String _keyNotifLevelUps = 'scrola_notif_level_ups';
  static const String _keyNotifWeeklyReport = 'scrola_notif_weekly_report';
  static const String _keyNotifQuietHours = 'scrola_notif_quiet_hours';

  void _applySavedHaptics() {
    HapticService.isEnabled = hapticsEnabled;
    final idx = _prefs?.getInt(_keyHapticIntensity) ?? 1;
    HapticService.intensity = HapticIntensity.values[idx.clamp(0, 2)];
  }

  void _ensureJoinedDate() {
    final existing = _prefs?.getString(_keyJoinedDate);
    if (existing == null || existing.isEmpty) {
      _prefs?.setString(_keyJoinedDate, _getTodayString());
    }
  }

  static String formatDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _getTodayString() => formatDateKey(DateTime.now());

  void _checkDailyReset() {
    final today = _getTodayString();
    final lastDate = _prefs?.getString(_keyLastDate) ?? '';
    if (today != lastDate) {
      if (lastDate.isNotEmpty) {
        final prevTotal = _prefs?.getInt(_keyTotalToday) ?? 0;
        final prevFocus = _prefs?.getInt(_keyFocusMinsToday) ?? 0;
        final prevBlocks = _prefs?.getInt(_keyDailyBlocksCount) ?? 0;
        _saveHistoryEntrySync(
          lastDate,
          reels: prevTotal,
          limit: totalLimit,
          focusMinutes: prevFocus,
          blocks: prevBlocks,
        );
        final lastDt = DateTime.tryParse(lastDate);
        final todayDt = DateTime.tryParse(today);
        if (lastDt != null && todayDt != null) {
          final gapDays = todayDt.difference(lastDt).inDays;
          if (gapDays == 1 && prevTotal <= totalLimit) {
            final nextStreak = (_prefs?.getInt(_keyStreakDays) ?? 0) + 1;
            _prefs?.setInt(_keyStreakDays, nextStreak);
            _prefs?.setString(_keyLastStreakDate, lastDate);
          } else if (prevTotal > totalLimit || gapDays > 1) {
            _prefs?.setInt(_keyStreakDays, 0);
          }
        }
      }
      _prefs?.setString(_keyLastDate, today);
      _prefs?.setInt(_keyTotalToday, 0);
      for (final platformId in supportedPlatformIds) {
        _prefs?.setInt(_countKey(platformId), 0);
      }
      _prefs?.setInt(_keySessionReels, 0);
      _prefs?.setInt(_keyScreenTimeSec, 0);
      _prefs?.setInt(_keyFocusMinsToday, 0);
      _prefs?.setInt(_keyFocusSessionsToday, 0);
      _prefs?.setInt(_keyDailyBlocksCount, 0);
      _prefs?.setInt(_keyEmergencyUnlocksUsedToday, 0);
    }
  }

  // Onboarding
  bool get isOnboardingComplete => _prefs?.getBool(_keyOnboardingComplete) ?? false;
  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs?.setBool(_keyOnboardingComplete, complete);
  }

  String get selectedGoal => _prefs?.getString(_keySelectedGoal) ?? 'Stay under a daily limit';
  Future<void> setSelectedGoal(String goal) async {
    await _prefs?.setString(_keySelectedGoal, goal);
  }

  static List<String> normalizeSelectedPlatformIds(Iterable<String> rawIds) {
    final selectedSet = rawIds
        .map((e) => e.trim().toLowerCase())
        .where((e) => supportedPlatformIds.contains(e))
        .toSet();
    final ordered = [
      for (final id in supportedPlatformIds)
        if (selectedSet.contains(id)) id,
    ];
    return ordered.isEmpty ? const ['instagram', 'youtube'] : ordered;
  }

  static Map<String, int> allocateLimitsForPlatforms({
    required int totalLimit,
    required List<String> selectedIds,
  }) {
    final normalized = normalizeSelectedPlatformIds(selectedIds);
    final count = normalized.length;
    final clampedTotal = totalLimit < 0 ? 0 : totalLimit;
    final base = clampedTotal ~/ count;
    final remainder = clampedTotal % count;
    return {
      for (int i = 0; i < count; i++)
        normalized[i]: base + (i < remainder ? 1 : 0),
    };
  }

  List<String> get selectedPlatforms => normalizeSelectedPlatformIds(
      _prefs?.getStringList(_keySelectedPlatforms) ?? ['instagram', 'youtube']);
  Future<void> setSelectedPlatforms(List<String> platforms) async {
    await _prefs?.setStringList(
        _keySelectedPlatforms, normalizeSelectedPlatformIds(platforms));
  }

  // Daily Consumption Counts
  int get totalReelsToday => _prefs?.getInt(_keyTotalToday) ?? 0;
  int reelsForPlatform(String platformId) =>
      _prefs?.getInt(_countKey(platformId)) ?? 0;
  int get instagramReels => reelsForPlatform('instagram');
  int get youtubeReels => reelsForPlatform('youtube');
  int get tiktokReels => reelsForPlatform('tiktok');
  int get facebookReels => reelsForPlatform('facebook');
  int get snapchatReels => reelsForPlatform('snapchat');
  int get xReels => reelsForPlatform('x');
  int get redditReels => reelsForPlatform('reddit');
  int get mojReels => reelsForPlatform('moj');
  int get sessionReels => _prefs?.getInt(_keySessionReels) ?? 0;
  int get screenTimeSeconds => _prefs?.getInt(_keyScreenTimeSec) ?? 0;
  int get focusMinutesToday => _prefs?.getInt(_keyFocusMinsToday) ?? 0;
  int get focusSessionsToday => _prefs?.getInt(_keyFocusSessionsToday) ?? 0;

  Map<String, Map<String, int>> _readHistoryMap() {
    final raw = _prefs?.getString(_keyDailyHistory);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final result = <String, Map<String, int>>{};
      for (final entry in decoded.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is Map) {
          result[key] = {
            'reels': (value['reels'] as num?)?.toInt() ?? 0,
            'limit': (value['limit'] as num?)?.toInt() ?? totalLimit,
            'focusMinutes': (value['focusMinutes'] as num?)?.toInt() ?? 0,
            'blocks': (value['blocks'] as num?)?.toInt() ?? 0,
          };
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  void _saveHistoryEntrySync(
    String dateKey, {
    required int reels,
    required int limit,
    required int focusMinutes,
    required int blocks,
  }) {
    final map = _readHistoryMap();
    map[dateKey] = {
      'reels': reels,
      'limit': limit,
      'focusMinutes': focusMinutes,
      'blocks': blocks,
    };
    if (map.length > 60) {
      final sortedKeys = map.keys.toList()..sort();
      for (final oldKey in sortedKeys.take(map.length - 60)) {
        map.remove(oldKey);
      }
    }
    _prefs?.setString(_keyDailyHistory, jsonEncode(map));
  }

  Future<void> _recordTodayHistory() async {
    _saveHistoryEntrySync(
      _getTodayString(),
      reels: totalReelsToday,
      limit: totalLimit,
      focusMinutes: focusMinutesToday,
      blocks: dailyBlocksCount,
    );
  }

  Map<String, Map<String, int>> get dailyHistory {
    final map = _readHistoryMap();
    map[_getTodayString()] = {
      'reels': totalReelsToday,
      'limit': totalLimit,
      'focusMinutes': focusMinutesToday,
      'blocks': dailyBlocksCount,
    };
    return map;
  }

  Future<void> recordReel(String platform) async {
    _checkDailyReset();
    await _prefs?.setInt(_keyTotalToday, totalReelsToday + 1);
    await _prefs?.setInt(_keySessionReels, sessionReels + 1);
    await _prefs?.setInt(_keyScreenTimeSec, screenTimeSeconds + 30);

    final normalized = platform.trim().toLowerCase();
    if (normalized.isNotEmpty) {
      await _prefs?.setInt(_countKey(normalized), reelsForPlatform(normalized) + 1);
    }
    await _recordTodayHistory();
  }

  Future<void> recordFocusCompleted(int minutes) async {
    _checkDailyReset();
    await _prefs?.setInt(_keyFocusMinsToday, focusMinutesToday + minutes);
    await _prefs?.setInt(_keyFocusSessionsToday, focusSessionsToday + 1);
    await _recordTodayHistory();
  }

  Future<void> syncCounts({
    required int total,
    Map<String, int>? platformCounts,
    required int session,
  }) async {
    _checkDailyReset();
    await _prefs?.setInt(_keyTotalToday, total);
    if (platformCounts != null) {
      for (final entry in platformCounts.entries) {
        await _prefs?.setInt(_countKey(entry.key), entry.value);
      }
    }
    await _prefs?.setInt(_keySessionReels, session);
    await _prefs?.setInt(_keyScreenTimeSec, total * 30);
    await _recordTodayHistory();
  }

  Future<void> resetSession() async {
    await _prefs?.setInt(_keySessionReels, 0);
  }

  Future<void> resetDailyStats() async {
    await _prefs?.setString(_keyLastDate, _getTodayString());
    await _prefs?.setInt(_keyTotalToday, 0);
    for (final platformId in supportedPlatformIds) {
      await _prefs?.setInt(_countKey(platformId), 0);
    }
    await _prefs?.setInt(_keySessionReels, 0);
    await _prefs?.setInt(_keyScreenTimeSec, 0);
    await _prefs?.setInt(_keyFocusMinsToday, 0);
    await _prefs?.setInt(_keyFocusSessionsToday, 0);
    await _prefs?.setInt(_keyDailyBlocksCount, 0);
    await _prefs?.setInt(_keyEmergencyUnlocksUsedToday, 0);
    await _recordTodayHistory();
  }

  // Limits
  int get totalLimit => _prefs?.getInt(_keyTotalLimit) ?? 40;
  int limitForPlatform(String platformId) {
    final normalized = platformId.trim().toLowerCase();
    final allocated = allocateLimitsForPlatforms(
      totalLimit: totalLimit,
      selectedIds: selectedPlatforms,
    );
    if (!platformLimitsEnabled) {
      return allocated[normalized] ?? 0;
    }
    return savedLimitForPlatform(normalized);
  }

  /// Returns the persisted per-app limit (falling back to the current equal
  /// allocation if never customized), regardless of whether per-app caps are
  /// currently enforced.
  int savedLimitForPlatform(String platformId) {
    final normalized = platformId.trim().toLowerCase();
    final allocated = allocateLimitsForPlatforms(
      totalLimit: totalLimit,
      selectedIds: selectedPlatforms,
    );
    return _prefs?.getInt(_limitKey(normalized)) ??
        allocated[normalized] ??
        defaultPlatformLimits[normalized] ??
        10;
  }

  Map<String, int> get allPlatformLimits => {
        for (final id in supportedPlatformIds) id: limitForPlatform(id),
      };

  int get instagramLimit => limitForPlatform('instagram');
  int get youtubeLimit => limitForPlatform('youtube');
  int get tiktokLimit => limitForPlatform('tiktok');
  int get facebookLimit => limitForPlatform('facebook');
  int get snapchatLimit => limitForPlatform('snapchat');
  int get xLimit => limitForPlatform('x');
  int get redditLimit => limitForPlatform('reddit');
  int get mojLimit => limitForPlatform('moj');

  Future<void> setLimits({
    int? total,
    int? instagram,
    int? youtube,
    int? facebook,
    int? snapchat,
    Map<String, int>? platformLimits,
  }) async {
    if (total != null) await _prefs?.setInt(_keyTotalLimit, total);
    if (instagram != null) {
      await _prefs?.setInt(_limitKey('instagram'), instagram);
    }
    if (youtube != null) await _prefs?.setInt(_limitKey('youtube'), youtube);
    if (facebook != null) await _prefs?.setInt(_limitKey('facebook'), facebook);
    if (snapchat != null) await _prefs?.setInt(_limitKey('snapchat'), snapchat);
    if (platformLimits != null) {
      for (final entry in platformLimits.entries) {
        final normalized = entry.key.trim().toLowerCase();
        await _prefs?.setInt(_limitKey(normalized), entry.value);
      }
    }
  }

  Future<void> clearCustomPlatformLimits() async {
    for (final id in supportedPlatformIds) {
      await _prefs?.remove(_limitKey(id));
    }
  }

  // Gamification
  int get streakDays => _prefs?.getInt(_keyStreakDays) ?? 0;
  String get lastStreakDate => _prefs?.getString(_keyLastStreakDate) ?? '';
  int get xpTotal => _prefs?.getInt(_keyXPTotal) ?? 320;
  int get currentLevel => GamificationEngine.getLevelForXP(xpTotal).level;

  BrainySkin get equippedSkin {
    final idx = _prefs?.getInt(_keyEquippedSkin) ?? 0;
    return BrainySkin.values[idx.clamp(0, BrainySkin.values.length - 1)];
  }

  Future<void> setEquippedSkin(BrainySkin skin) async {
    await _prefs?.setInt(_keyEquippedSkin, skin.index);
  }

  Future<void> addXP(int xp) async {
    final newXP = (xpTotal + xp).clamp(0, 1 << 30);
    await _prefs?.setInt(_keyXPTotal, newXP);
    await _prefs?.setInt(_keyCurrentLevel, GamificationEngine.getLevelForXP(newXP).level);
  }

  bool get isDailyXpCollectedToday =>
      _prefs?.getString(_keyDailyXpCollectedDate) == _getTodayString();

  Future<bool> markDailyXpCollectedToday() async {
    if (isDailyXpCollectedToday) return false;
    await _prefs?.setString(_keyDailyXpCollectedDate, _getTodayString());
    return true;
  }

  List<String> get claimedRewards =>
      List<String>.unmodifiable(_prefs?.getStringList(_keyClaimedRewards) ?? const []);

  bool isRewardClaimed(String rewardId) =>
      (_prefs?.getStringList(_keyClaimedRewards) ?? const []).contains(rewardId);

  Future<bool> markRewardClaimed(String rewardId) async {
    final existing = List<String>.from(
      _prefs?.getStringList(_keyClaimedRewards) ?? const [],
    );
    if (existing.contains(rewardId)) return false;
    existing.add(rewardId);
    await _prefs?.setStringList(_keyClaimedRewards, existing);
    return true;
  }

  Future<void> updateStreak(int days) async {
    await _prefs?.setInt(_keyStreakDays, days);
    await _prefs?.setString(_keyLastStreakDate, _getTodayString());
  }

  // Focus Session State
  bool get focusIsActive => _prefs?.getBool(_keyFocusActive) ?? false;
  bool get focusIsPaused => _prefs?.getBool(_keyFocusPaused) ?? false;
  int get focusDurationMinutes => _prefs?.getInt(_keyFocusDurationMinutes) ?? 25;
  int get focusEndEpochMs => _prefs?.getInt(_keyFocusEndEpochMs) ?? 0;
  int get focusRemainingSeconds => _prefs?.getInt(_keyFocusRemainingSec) ?? 0;
  int get focusBlockedAttempts => _prefs?.getInt(_keyFocusBlockedAttempts) ?? 0;

  Future<void> saveFocusSessionState({
    required bool isActive,
    required bool isPaused,
    required int durationMinutes,
    required int endEpochMs,
    required int remainingSeconds,
    required int blockedAttempts,
  }) async {
    await _prefs?.setBool(_keyFocusActive, isActive);
    await _prefs?.setBool(_keyFocusPaused, isPaused);
    await _prefs?.setInt(_keyFocusDurationMinutes, durationMinutes);
    await _prefs?.setInt(_keyFocusEndEpochMs, endEpochMs);
    await _prefs?.setInt(_keyFocusRemainingSec, remainingSeconds);
    await _prefs?.setInt(_keyFocusBlockedAttempts, blockedAttempts);
  }

  Future<void> clearFocusSessionState() async {
    await _prefs?.setBool(_keyFocusActive, false);
    await _prefs?.setBool(_keyFocusPaused, false);
    await _prefs?.setInt(_keyFocusEndEpochMs, 0);
    await _prefs?.setInt(_keyFocusRemainingSec, 0);
    await _prefs?.setInt(_keyFocusBlockedAttempts, 0);
  }

  // Toggles & Overlay Settings
  // Master switch defaults OFF: opening the app never auto-activates Scrola.
  bool get isTrackingEnabled => _prefs?.getBool(_keyTrackingEnabled) ?? false;
  Future<void> setTrackingEnabled(bool enabled) async {
    await _prefs?.setBool(_keyTrackingEnabled, enabled);
  }

  bool get platformLimitsEnabled =>
      _prefs?.getBool(_keyPlatformLimitsEnabled) ?? false;
  Future<void> setPlatformLimitsEnabled(bool enabled) async {
    await _prefs?.setBool(_keyPlatformLimitsEnabled, enabled);
  }

  bool get isOverlayEnabled => _prefs?.getBool(_keyOverlayEnabled) ?? true;
  Future<void> setOverlayEnabled(bool enabled) async {
    await _prefs?.setBool(_keyOverlayEnabled, enabled);
  }

  bool get overlayStickToNotch => _prefs?.getBool(_keyOverlayStickToNotch) ?? true;
  Future<void> setOverlayStickToNotch(bool stick) async {
    await _prefs?.setBool(_keyOverlayStickToNotch, stick);
  }

  bool get overlayExpanded => _prefs?.getBool(_keyOverlayExpanded) ?? false;
  Future<void> setOverlayExpanded(bool expanded) async {
    await _prefs?.setBool(_keyOverlayExpanded, expanded);
  }

  String get overlaySize => _prefs?.getString(_keyOverlaySize) ?? 'Medium';
  Future<void> setOverlaySize(String size) async {
    await _prefs?.setString(_keyOverlaySize, size);
  }

  bool get overlayReactToPace =>
      _prefs?.getBool(_keyOverlayReactToPace) ?? true;
  Future<void> setOverlayReactToPace(bool react) async {
    await _prefs?.setBool(_keyOverlayReactToPace, react);
  }

  // Blocking & Detox
  bool get blockAtLimitEnabled => _prefs?.getBool(_keyBlockAtLimit) ?? true;
  Future<void> setBlockAtLimitEnabled(bool enabled) async {
    await _prefs?.setBool(_keyBlockAtLimit, enabled);
  }

  bool get nightBlockEnabled => _prefs?.getBool(_keyNightBlock) ?? true;
  Future<void> setNightBlockEnabled(bool enabled) async {
    await _prefs?.setBool(_keyNightBlock, enabled);
  }

  bool get workBlockEnabled => _prefs?.getBool(_keyWorkBlock) ?? false;
  Future<void> setWorkBlockEnabled(bool enabled) async {
    await _prefs?.setBool(_keyWorkBlock, enabled);
  }

  List<String> get nightBlockDays => List<String>.unmodifiable(
      _prefs?.getStringList(_keyNightBlockDays) ??
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
  Future<void> setNightBlockDays(List<String> days) async {
    await _prefs?.setStringList(_keyNightBlockDays, days);
  }

  List<String> get workBlockDays => List<String>.unmodifiable(
      _prefs?.getStringList(_keyWorkBlockDays) ??
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']);
  Future<void> setWorkBlockDays(List<String> days) async {
    await _prefs?.setStringList(_keyWorkBlockDays, days);
  }

  bool get strictBlocking => _prefs?.getBool(_keyStrictBlocking) ?? false;
  Future<void> setStrictBlocking(bool strict) async {
    await _prefs?.setBool(_keyStrictBlocking, strict);
  }

  bool get waitBeforeUnlock => _prefs?.getBool(_keyWaitBeforeUnlock) ?? true;
  Future<void> setWaitBeforeUnlock(bool wait) async {
    await _prefs?.setBool(_keyWaitBeforeUnlock, wait);
  }

  bool get showBrainyOnBlock => _prefs?.getBool(_keyShowBrainyOnBlock) ?? true;
  Future<void> setShowBrainyOnBlock(bool show) async {
    await _prefs?.setBool(_keyShowBrainyOnBlock, show);
  }

  int get dailyBlocksCount => _prefs?.getInt(_keyDailyBlocksCount) ?? 0;
  Future<void> incrementDailyBlocksCount() async {
    _checkDailyReset();
    await _prefs?.setInt(_keyDailyBlocksCount, dailyBlocksCount + 1);
    await _recordTodayHistory();
  }

  int get emergencyUnlocksUsedToday =>
      _prefs?.getInt(_keyEmergencyUnlocksUsedToday) ?? 0;
  Future<void> incrementEmergencyUnlocksUsed() async {
    _checkDailyReset();
    await _prefs?.setInt(
      _keyEmergencyUnlocksUsedToday,
      emergencyUnlocksUsedToday + 1,
    );
  }

  int get detoxDays => _prefs?.getInt(_keyDetoxDays) ?? 1;
  int get detoxEndEpochMs => _prefs?.getInt(_keyDetoxEndEpochMs) ?? 0;

  bool get isDetoxActive {
    final active = _prefs?.getBool(_keyDetoxActive) ?? false;
    if (!active) return false;
    final endMs = detoxEndEpochMs;
    if (endMs > 0 && DateTime.now().millisecondsSinceEpoch >= endMs) {
      _prefs?.setBool(_keyDetoxActive, false);
      _prefs?.setInt(_keyDetoxEndEpochMs, 0);
      return false;
    }
    return true;
  }

  Future<void> setDetoxActive(bool active, {int? days}) async {
    await _prefs?.setBool(_keyDetoxActive, active);
    if (days != null) {
      await _prefs?.setInt(_keyDetoxDays, days);
    }
    if (active) {
      final durationDays = days ?? detoxDays;
      final endMs = DateTime.now()
          .add(Duration(days: durationDays.clamp(1, 30)))
          .millisecondsSinceEpoch;
      await _prefs?.setInt(_keyDetoxEndEpochMs, endMs);
    } else {
      await _prefs?.setInt(_keyDetoxEndEpochMs, 0);
    }
  }

  // Notifications
  bool get notifWarnNearLimit => _prefs?.getBool(_keyNotifWarnNearLimit) ?? true;
  List<String> get notifThresholds => List<String>.unmodifiable(
      _prefs?.getStringList(_keyNotifThresholds) ?? const ['80%', '100%']);
  bool get notifStreakReminder =>
      _prefs?.getBool(_keyNotifStreakReminder) ?? true;
  bool get notifFocusEnd => _prefs?.getBool(_keyNotifFocusEnd) ?? true;
  bool get notifLevelUps => _prefs?.getBool(_keyNotifLevelUps) ?? true;
  bool get notifWeeklyReport => _prefs?.getBool(_keyNotifWeeklyReport) ?? false;
  bool get notifQuietHours => _prefs?.getBool(_keyNotifQuietHours) ?? true;

  bool get anyNotificationsEnabled =>
      notifWarnNearLimit ||
      notifStreakReminder ||
      notifFocusEnd ||
      notifLevelUps ||
      notifWeeklyReport;

  Future<void> setNotificationConfig({
    bool? warnNearLimit,
    List<String>? thresholds,
    bool? streakReminder,
    bool? focusEnd,
    bool? levelUps,
    bool? weeklyReport,
    bool? quietHours,
  }) async {
    if (warnNearLimit != null) {
      await _prefs?.setBool(_keyNotifWarnNearLimit, warnNearLimit);
    }
    if (thresholds != null) {
      await _prefs?.setStringList(_keyNotifThresholds, thresholds);
    }
    if (streakReminder != null) {
      await _prefs?.setBool(_keyNotifStreakReminder, streakReminder);
    }
    if (focusEnd != null) {
      await _prefs?.setBool(_keyNotifFocusEnd, focusEnd);
    }
    if (levelUps != null) {
      await _prefs?.setBool(_keyNotifLevelUps, levelUps);
    }
    if (weeklyReport != null) {
      await _prefs?.setBool(_keyNotifWeeklyReport, weeklyReport);
    }
    if (quietHours != null) {
      await _prefs?.setBool(_keyNotifQuietHours, quietHours);
    }
  }

  // Haptics
  bool get hapticsEnabled => _prefs?.getBool(_keyHapticsEnabled) ?? true;
  Future<void> setHapticsEnabled(bool enabled) async {
    HapticService.isEnabled = enabled;
    await _prefs?.setBool(_keyHapticsEnabled, enabled);
  }

  HapticIntensity get hapticIntensity {
    final idx = _prefs?.getInt(_keyHapticIntensity) ?? 1;
    return HapticIntensity.values[idx.clamp(0, 2)];
  }

  Future<void> setHapticIntensity(HapticIntensity intensity) async {
    HapticService.intensity = intensity;
    await _prefs?.setInt(_keyHapticIntensity, intensity.index);
  }

  // Profile & Subscription
  String get displayName => _prefs?.getString(_keyDisplayName) ?? 'Alex';
  String get username => _prefs?.getString(_keyUsername) ?? 'alex';
  String get email => _prefs?.getString(_keyEmail) ?? 'alex@scrola.app';
  String get joinedDateIso =>
      _prefs?.getString(_keyJoinedDate) ?? _getTodayString();

  String get joinedMonthYear {
    final dt = DateTime.tryParse(joinedDateIso) ?? DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[(dt.month - 1).clamp(0, 11)]} ${dt.year}';
  }

  bool get isProSubscribed => _prefs?.getBool(_keyIsProSubscribed) ?? false;
  String get proPlan => _prefs?.getString(_keyProPlan) ?? 'yearly';

  Future<void> setProSubscription({
    bool? subscribed,
    String? plan,
  }) async {
    if (subscribed != null) {
      await _prefs?.setBool(_keyIsProSubscribed, subscribed);
    }
    if (plan != null) {
      await _prefs?.setString(_keyProPlan, plan);
    }
  }

  Future<void> setProfile({
    String? displayName,
    String? username,
    String? email,
  }) async {
    if (displayName != null) await _prefs?.setString(_keyDisplayName, displayName);
    if (username != null) await _prefs?.setString(_keyUsername, username);
    if (email != null) await _prefs?.setString(_keyEmail, email);
  }
}

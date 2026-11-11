import 'package:shared_preferences/shared_preferences.dart';
import 'haptic_service.dart';
import 'gamification_engine.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _prefs = await SharedPreferences.getInstance();
      _instance = StorageService._();
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

  static const String _keyNightBlock = 'scrola_night_block';
  static const String _keyWorkBlock = 'scrola_work_block';
  static const String _keyStrictBlocking = 'scrola_strict_blocking';
  static const String _keyDetoxActive = 'scrola_detox_active';

  static const String _keyHapticsEnabled = 'scrola_haptics_enabled';
  static const String _keyHapticIntensity = 'scrola_haptic_intensity';

  static const String _keyDisplayName = 'scrola_display_name';
  static const String _keyUsername = 'scrola_username';
  static const String _keyEmail = 'scrola_email';

  void _applySavedHaptics() {
    HapticService.isEnabled = hapticsEnabled;
    final idx = _prefs?.getInt(_keyHapticIntensity) ?? 1;
    HapticService.intensity = HapticIntensity.values[idx.clamp(0, 2)];
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _checkDailyReset() {
    final today = _getTodayString();
    final lastDate = _prefs?.getString(_keyLastDate) ?? '';
    if (today != lastDate) {
      _prefs?.setString(_keyLastDate, today);
      _prefs?.setInt(_keyTotalToday, 0);
      for (final platformId in supportedPlatformIds) {
        _prefs?.setInt(_countKey(platformId), 0);
      }
      _prefs?.setInt(_keySessionReels, 0);
      _prefs?.setInt(_keyScreenTimeSec, 0);
      _prefs?.setInt(_keyFocusMinsToday, 0);
      _prefs?.setInt(_keyFocusSessionsToday, 0);
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

  Future<void> recordReel(String platform) async {
    _checkDailyReset();
    await _prefs?.setInt(_keyTotalToday, totalReelsToday + 1);
    await _prefs?.setInt(_keySessionReels, sessionReels + 1);
    await _prefs?.setInt(_keyScreenTimeSec, screenTimeSeconds + 30);

    final normalized = platform.trim().toLowerCase();
    if (normalized.isNotEmpty) {
      await _prefs?.setInt(_countKey(normalized), reelsForPlatform(normalized) + 1);
    }
  }

  Future<void> recordFocusCompleted(int minutes) async {
    _checkDailyReset();
    await _prefs?.setInt(_keyFocusMinsToday, focusMinutesToday + minutes);
    await _prefs?.setInt(_keyFocusSessionsToday, focusSessionsToday + 1);
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
  }

  Future<void> resetSession() async {
    await _prefs?.setInt(_keySessionReels, 0);
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
        await _prefs?.setInt(_limitKey(entry.key), entry.value);
      }
    }
  }

  // Gamification
  int get streakDays => _prefs?.getInt(_keyStreakDays) ?? 7;
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
    final newXP = xpTotal + xp;
    await _prefs?.setInt(_keyXPTotal, newXP);
    await _prefs?.setInt(_keyCurrentLevel, GamificationEngine.getLevelForXP(newXP).level);
  }

  Future<void> updateStreak(int days) async {
    await _prefs?.setInt(_keyStreakDays, days);
    await _prefs?.setString(_keyLastStreakDate, _getTodayString());
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

  // Blocking & Detox
  bool get nightBlockEnabled => _prefs?.getBool(_keyNightBlock) ?? true;
  Future<void> setNightBlockEnabled(bool enabled) async {
    await _prefs?.setBool(_keyNightBlock, enabled);
  }

  bool get workBlockEnabled => _prefs?.getBool(_keyWorkBlock) ?? false;
  Future<void> setWorkBlockEnabled(bool enabled) async {
    await _prefs?.setBool(_keyWorkBlock, enabled);
  }

  bool get strictBlocking => _prefs?.getBool(_keyStrictBlocking) ?? false;
  Future<void> setStrictBlocking(bool strict) async {
    await _prefs?.setBool(_keyStrictBlocking, strict);
  }

  bool get isDetoxActive => _prefs?.getBool(_keyDetoxActive) ?? false;
  Future<void> setDetoxActive(bool active) async {
    await _prefs?.setBool(_keyDetoxActive, active);
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

  // Profile
  String get displayName => _prefs?.getString(_keyDisplayName) ?? 'Alex';
  String get username => _prefs?.getString(_keyUsername) ?? 'alex';
  String get email => _prefs?.getString(_keyEmail) ?? 'alex@scrola.app';

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

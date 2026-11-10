import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _prefs = await SharedPreferences.getInstance();
      _instance = StorageService._();
      _instance!._checkDailyReset();
    }
    return _instance!;
  }

  static const String _keyLastDate = 'scrola_last_date';
  static const String _keyTotalToday = 'scrola_total_today';
  static const String _keyInstagram = 'scrola_instagram';
  static const String _keyYouTube = 'scrola_youtube';
  static const String _keyFacebook = 'scrola_facebook';
  static const String _keySnapchat = 'scrola_snapchat';
  static const String _keySessionReels = 'scrola_session_reels';
  static const String _keyScreenTimeSec = 'scrola_screen_time_sec';

  static const String _keyStreakDays = 'scrola_streak_days';
  static const String _keyLastStreakDate = 'scrola_last_streak_date';
  static const String _keyXPTotal = 'scrola_xp_total';
  static const String _keyCurrentLevel = 'scrola_current_level';

  static const String _keyTotalLimit = 'scrola_total_limit';
  static const String _keyInstagramLimit = 'scrola_instagram_limit';
  static const String _keyYouTubeLimit = 'scrola_youtube_limit';
  static const String _keyFacebookLimit = 'scrola_facebook_limit';
  static const String _keySnapchatLimit = 'scrola_snapchat_limit';

  static const String _keyTrackingEnabled = 'scrola_tracking_enabled';
  static const String _keyOverlayEnabled = 'scrola_overlay_enabled';

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
      _prefs?.setInt(_keyInstagram, 0);
      _prefs?.setInt(_keyYouTube, 0);
      _prefs?.setInt(_keyFacebook, 0);
      _prefs?.setInt(_keySnapchat, 0);
      _prefs?.setInt(_keySessionReels, 0);
      _prefs?.setInt(_keyScreenTimeSec, 0);
    }
  }

  // Daily Consumption Counts
  int get totalReelsToday => _prefs?.getInt(_keyTotalToday) ?? 0;
  int get instagramReels => _prefs?.getInt(_keyInstagram) ?? 0;
  int get youtubeReels => _prefs?.getInt(_keyYouTube) ?? 0;
  int get facebookReels => _prefs?.getInt(_keyFacebook) ?? 0;
  int get snapchatReels => _prefs?.getInt(_keySnapchat) ?? 0;
  int get sessionReels => _prefs?.getInt(_keySessionReels) ?? 0;
  int get screenTimeSeconds => _prefs?.getInt(_keyScreenTimeSec) ?? 0;

  Future<void> recordReel(String platform) async {
    _checkDailyReset();
    final newTotal = totalReelsToday + 1;
    await _prefs?.setInt(_keyTotalToday, newTotal);
    await _prefs?.setInt(_keySessionReels, sessionReels + 1);

    // Approximate ~30 seconds average per reel
    await _prefs?.setInt(_keyScreenTimeSec, screenTimeSeconds + 30);

    switch (platform.toLowerCase()) {
      case 'instagram':
        await _prefs?.setInt(_keyInstagram, instagramReels + 1);
        break;
      case 'youtube':
        await _prefs?.setInt(_keyYouTube, youtubeReels + 1);
        break;
      case 'facebook':
        await _prefs?.setInt(_keyFacebook, facebookReels + 1);
        break;
      case 'snapchat':
        await _prefs?.setInt(_keySnapchat, snapchatReels + 1);
        break;
    }
  }

  Future<void> syncCounts({
    required int total,
    required int instagram,
    required int youtube,
    required int facebook,
    required int snapchat,
    required int session,
  }) async {
    _checkDailyReset();
    await _prefs?.setInt(_keyTotalToday, total);
    await _prefs?.setInt(_keyInstagram, instagram);
    await _prefs?.setInt(_keyYouTube, youtube);
    await _prefs?.setInt(_keyFacebook, facebook);
    await _prefs?.setInt(_keySnapchat, snapchat);
    await _prefs?.setInt(_keySessionReels, session);
    await _prefs?.setInt(_keyScreenTimeSec, total * 30);
  }

  Future<void> resetSession() async {
    await _prefs?.setInt(_keySessionReels, 0);
  }

  // Limits
  int get totalLimit => _prefs?.getInt(_keyTotalLimit) ?? 40;
  int get instagramLimit => _prefs?.getInt(_keyInstagramLimit) ?? 20;
  int get youtubeLimit => _prefs?.getInt(_keyYouTubeLimit) ?? 15;
  int get facebookLimit => _prefs?.getInt(_keyFacebookLimit) ?? 10;
  int get snapchatLimit => _prefs?.getInt(_keySnapchatLimit) ?? 5;

  Future<void> setLimits({
    int? total,
    int? instagram,
    int? youtube,
    int? facebook,
    int? snapchat,
  }) async {
    if (total != null) await _prefs?.setInt(_keyTotalLimit, total);
    if (instagram != null) await _prefs?.setInt(_keyInstagramLimit, instagram);
    if (youtube != null) await _prefs?.setInt(_keyYouTubeLimit, youtube);
    if (facebook != null) await _prefs?.setInt(_keyFacebookLimit, facebook);
    if (snapchat != null) await _prefs?.setInt(_keySnapchatLimit, snapchat);
  }

  // Gamification (Streak & XP)
  int get streakDays => _prefs?.getInt(_keyStreakDays) ?? 7;
  String get lastStreakDate => _prefs?.getString(_keyLastStreakDate) ?? '';
  int get xpTotal => _prefs?.getInt(_keyXPTotal) ?? 320;
  int get currentLevel => _prefs?.getInt(_keyCurrentLevel) ?? 4;

  Future<void> addXP(int xp) async {
    final newXP = xpTotal + xp;
    await _prefs?.setInt(_keyXPTotal, newXP);
  }

  Future<void> setLevel(int level) async {
    await _prefs?.setInt(_keyCurrentLevel, level);
  }

  Future<void> updateStreak(int days) async {
    await _prefs?.setInt(_keyStreakDays, days);
    await _prefs?.setString(_keyLastStreakDate, _getTodayString());
  }

  // Toggles
  bool get isTrackingEnabled => _prefs?.getBool(_keyTrackingEnabled) ?? true;
  Future<void> setTrackingEnabled(bool enabled) async {
    await _prefs?.setBool(_keyTrackingEnabled, enabled);
  }

  bool get isOverlayEnabled => _prefs?.getBool(_keyOverlayEnabled) ?? true;
  Future<void> setOverlayEnabled(bool enabled) async {
    await _prefs?.setBool(_keyOverlayEnabled, enabled);
  }
}

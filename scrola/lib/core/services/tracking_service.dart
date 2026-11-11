import 'dart:async';
import 'package:flutter/foundation.dart';
import 'focus_mode_service.dart';
import 'gamification_engine.dart';
import 'haptic_service.dart';
import 'scrola_native_bridge.dart';
import 'storage_service.dart';

class TrackingService extends ChangeNotifier {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  StorageService? _storage;
  StreamSubscription<ReelEvent>? _eventSubscription;

  bool _isAccessibilityGranted = false;
  bool _isOverlayGranted = false;
  bool _isInitialized = false;

  bool get isAccessibilityGranted => _isAccessibilityGranted;
  bool get isOverlayGranted => _isOverlayGranted;
  bool get isInitialized => _isInitialized;

  // Profile
  String get displayName => _storage?.displayName ?? 'Alex';
  String get username => _storage?.username ?? 'alex';
  String get email => _storage?.email ?? 'alex@scrola.app';

  // Onboarding & Goal
  bool get isOnboardingComplete => _storage?.isOnboardingComplete ?? false;
  String get selectedGoal => _storage?.selectedGoal ?? 'Stay under a daily limit';
  List<String> get selectedPlatforms => _storage?.selectedPlatforms ?? ['instagram', 'youtube'];

  // Real-time metrics
  int get totalReelsToday => _storage?.totalReelsToday ?? 0;
  int get totalLimit => _storage?.totalLimit ?? 40;
  int get remainingReels => (totalLimit - totalReelsToday).clamp(0, totalLimit);
  bool get isLimitReached => totalReelsToday >= totalLimit;

  int get instagramReels => _storage?.instagramReels ?? 0;
  int get instagramLimit => _storage?.instagramLimit ?? 20;

  int get youtubeReels => _storage?.youtubeReels ?? 0;
  int get youtubeLimit => _storage?.youtubeLimit ?? 15;

  int get facebookReels => _storage?.facebookReels ?? 0;
  int get facebookLimit => _storage?.facebookLimit ?? 10;

  int get snapchatReels => _storage?.snapchatReels ?? 0;
  int get snapchatLimit => _storage?.snapchatLimit ?? 5;

  int get sessionReels => _storage?.sessionReels ?? 0;
  int get screenTimeMinutes => (_storage?.screenTimeSeconds ?? 0) ~/ 60;
  int get focusMinutesToday => _storage?.focusMinutesToday ?? 50;
  int get focusSessionsToday => _storage?.focusSessionsToday ?? 2;

  // Gamification
  int get streakDays => _storage?.streakDays ?? 7;
  int get xpTotal => _storage?.xpTotal ?? 320;
  int get currentLevel => _storage?.currentLevel ?? 4;
  BrainySkin get equippedSkin => _storage?.equippedSkin ?? BrainySkin.classic;

  // Settings
  bool get isOverlayEnabled => _storage?.isOverlayEnabled ?? true;
  bool get overlayStickToNotch => _storage?.overlayStickToNotch ?? true;
  bool get overlayExpanded => _storage?.overlayExpanded ?? false;
  String get overlaySize => _storage?.overlaySize ?? 'Medium';
  bool get nightBlockEnabled => _storage?.nightBlockEnabled ?? true;
  bool get workBlockEnabled => _storage?.workBlockEnabled ?? false;
  bool get strictBlocking => _storage?.strictBlocking ?? false;
  bool get isDetoxActive => _storage?.isDetoxActive ?? false;
  bool get hapticsEnabled => _storage?.hapticsEnabled ?? true;
  HapticIntensity get hapticIntensity => _storage?.hapticIntensity ?? HapticIntensity.medium;

  String get screenTimeFormatted {
    final mins = screenTimeMinutes;
    if (mins < 60) {
      return '${mins}m';
    }
    final hrs = mins ~/ 60;
    final remainingMins = mins % 60;
    return '${hrs}h ${remainingMins}m';
  }

  String get resetTimeFormatted {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    final hrs = diff.inHours;
    final mins = diff.inMinutes % 60;
    return '${hrs}h ${mins}m';
  }

  BrainyMood get currentMood {
    return GamificationEngine.evaluateMood(
      reelsWatched: totalReelsToday,
      dailyLimit: totalLimit,
      isFocusModeActive: FocusModeService().isActive,
      isDetoxOrNightBlock: isDetoxActive,
    );
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _storage = await StorageService.getInstance();
    await checkPermissions();
    await syncLimitsWithNative();
    await syncFromNative();

    _eventSubscription?.cancel();
    _eventSubscription = ScrolaNativeBridge.reelEventsStream.listen(
      _handleNativeReelEvent,
      onError: (err) {
        debugPrint('Reel stream error: $err');
      },
    );

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> syncFromNative() async {
    try {
      final stats = await ScrolaNativeBridge.getNativeStats();
      if (stats.isNotEmpty && _storage != null) {
        final nativeTotal = (stats['totalToday'] as num?)?.toInt() ?? 0;
        final nativeIG = (stats['instagram'] as num?)?.toInt() ?? 0;
        final nativeYT = (stats['youtube'] as num?)?.toInt() ?? 0;
        final nativeFB = (stats['facebook'] as num?)?.toInt() ?? 0;
        final nativeSC = (stats['snapchat'] as num?)?.toInt() ?? 0;
        final nativeSession = (stats['sessionCount'] as num?)?.toInt() ?? 0;

        await _storage!.syncCounts(
          total: nativeTotal,
          instagram: nativeIG,
          youtube: nativeYT,
          facebook: nativeFB,
          snapchat: nativeSC,
          session: nativeSession,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing from native: $e');
    }
  }

  Future<void> checkPermissions() async {
    _isAccessibilityGranted = await ScrolaNativeBridge.isAccessibilityServiceEnabled();
    _isOverlayGranted = await ScrolaNativeBridge.isOverlayPermissionGranted();
    notifyListeners();
  }

  Future<void> requestAccessibilityPermission() async {
    await ScrolaNativeBridge.openAccessibilitySettings();
  }

  Future<void> requestOverlayPermission() async {
    await ScrolaNativeBridge.requestOverlayPermission();
  }

  Future<void> completeOnboarding({
    required String goal,
    required int dailyLimit,
    required List<String> platforms,
  }) async {
    await _storage?.setSelectedGoal(goal);
    await _storage?.setSelectedPlatforms(platforms);
    await _storage?.setLimits(total: dailyLimit);
    await _storage?.setOnboardingComplete(true);
    await syncLimitsWithNative();
    notifyListeners();
  }

  Future<void> updateLimits({
    int? total,
    int? instagram,
    int? youtube,
    int? facebook,
    int? snapchat,
  }) async {
    await _storage?.setLimits(
      total: total,
      instagram: instagram,
      youtube: youtube,
      facebook: facebook,
      snapchat: snapchat,
    );
    await syncLimitsWithNative();
    notifyListeners();
  }

  Future<void> toggleOverlay(bool enabled) async {
    await _storage?.setOverlayEnabled(enabled);
    if (enabled) {
      await ScrolaNativeBridge.startOverlayService();
    } else {
      await ScrolaNativeBridge.stopOverlayService();
    }
    await syncLimitsWithNative();
    notifyListeners();
  }

  Future<void> updateOverlayConfig({
    bool? stickToNotch,
    bool? expanded,
    String? size,
  }) async {
    if (stickToNotch != null) await _storage?.setOverlayStickToNotch(stickToNotch);
    if (expanded != null) await _storage?.setOverlayExpanded(expanded);
    if (size != null) await _storage?.setOverlaySize(size);
    notifyListeners();
  }

  Future<void> updateBlockingConfig({
    bool? nightBlock,
    bool? workBlock,
    bool? strict,
    bool? detox,
  }) async {
    if (nightBlock != null) await _storage?.setNightBlockEnabled(nightBlock);
    if (workBlock != null) await _storage?.setWorkBlockEnabled(workBlock);
    if (strict != null) await _storage?.setStrictBlocking(strict);
    if (detox != null) await _storage?.setDetoxActive(detox);
    notifyListeners();
  }

  Future<void> updateHapticsConfig({
    bool? enabled,
    HapticIntensity? intensity,
  }) async {
    if (enabled != null) await _storage?.setHapticsEnabled(enabled);
    if (intensity != null) await _storage?.setHapticIntensity(intensity);
    notifyListeners();
  }

  Future<void> equipSkin(BrainySkin skin) async {
    await _storage?.setEquippedSkin(skin);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? email,
  }) async {
    await _storage?.setProfile(
      displayName: displayName,
      username: username,
      email: email,
    );
    notifyListeners();
  }

  Future<void> addXP(int xp) async {
    await _storage?.addXP(xp);
    notifyListeners();
  }

  Future<void> syncLimitsWithNative() async {
    if (_storage == null) return;
    await ScrolaNativeBridge.syncLimits(
      totalLimit: _storage!.totalLimit,
      instagramLimit: _storage!.instagramLimit,
      youtubeLimit: _storage!.youtubeLimit,
      facebookLimit: _storage!.facebookLimit,
      snapchatLimit: _storage!.snapchatLimit,
      isFocusActive: FocusModeService().isActive || _storage!.isDetoxActive,
      isOverlayEnabled: _storage!.isOverlayEnabled,
    );
  }

  void _handleNativeReelEvent(ReelEvent event) async {
    debugPrint('Received reel event: ${event.eventType} on ${event.platform}');

    if (event.eventType == 'reel_watched') {
      await _storage?.recordReel(event.platform);

      // Design spec Section 6: "Never vibrate while counting reels."
      // Only fire warning/error haptics when hitting 80% or 100% thresholds
      if (totalReelsToday == totalLimit) {
        await HapticService.warning();
      } else if (totalReelsToday > totalLimit) {
        await HapticService.error();
      }

      notifyListeners();
    } else if (event.eventType == 'limit_block_enforced' || event.eventType == 'focus_block_enforced') {
      FocusModeService().incrementBlockedAttempt();
      await HapticService.error();
      notifyListeners();
    }
  }

  Future<void> resetSession() async {
    await _storage?.resetSession();
    await ScrolaNativeBridge.resetSession();
    notifyListeners();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

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
  Future<void>? _refreshPermissionsInFlight;

  bool _isAccessibilityGranted = false;
  bool _isOverlayGranted = false;
  bool _isNotificationGranted = true;
  bool _isInitialized = false;
  String _lastPlatform = 'instagram';

  bool get isAccessibilityGranted => _isAccessibilityGranted;
  bool get isOverlayGranted => _isOverlayGranted;
  bool get isNotificationGranted => _isNotificationGranted;
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

  int reelsForId(String id) => _storage?.reelsForPlatform(id) ?? 0;
  int limitForId(String id) =>
      _storage?.limitForPlatform(id) ??
      StorageService.defaultPlatformLimits[id] ??
      10;
  String get lastPlatform => _lastPlatform;

  int get instagramReels => _storage?.instagramReels ?? 0;
  int get instagramLimit => _storage?.instagramLimit ?? 20;

  int get youtubeReels => _storage?.youtubeReels ?? 0;
  int get youtubeLimit => _storage?.youtubeLimit ?? 15;

  int get tiktokReels => _storage?.tiktokReels ?? 0;
  int get tiktokLimit => _storage?.tiktokLimit ?? 15;

  int get facebookReels => _storage?.facebookReels ?? 0;
  int get facebookLimit => _storage?.facebookLimit ?? 10;

  int get snapchatReels => _storage?.snapchatReels ?? 0;
  int get snapchatLimit => _storage?.snapchatLimit ?? 5;

  int get xReels => _storage?.xReels ?? 0;
  int get xLimit => _storage?.xLimit ?? 10;

  int get redditReels => _storage?.redditReels ?? 0;
  int get redditLimit => _storage?.redditLimit ?? 10;

  int get mojReels => _storage?.mojReels ?? 0;
  int get mojLimit => _storage?.mojLimit ?? 10;

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
  bool get isTrackingEnabled => _storage?.isTrackingEnabled ?? false;
  bool get platformLimitsEnabled => _storage?.platformLimitsEnabled ?? false;
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

  Future<StorageService> _ensureStorage() async {
    return _storage ??= await StorageService.getInstance();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _ensureStorage();
    await checkPermissions();
    await syncFromNative();
    await syncLimitsWithNative();
    await startOverlayIfActive(animateEntrance: false);

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
        final nativeSession = (stats['sessionCount'] as num?)?.toInt() ?? 0;
        final platformCounts = <String, int>{
          for (final id in StorageService.supportedPlatformIds)
            id: (stats[id] as num?)?.toInt() ?? 0,
        };

        await _storage!.syncCounts(
          total: nativeTotal,
          platformCounts: platformCounts,
          session: nativeSession,
        );
        if (stats['isOverlayEnabled'] is bool) {
          await _storage!.setOverlayEnabled(stats['isOverlayEnabled'] as bool);
        }
        if (stats['overlayExpanded'] is bool) {
          await _storage!.setOverlayExpanded(stats['overlayExpanded'] as bool);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing from native: $e');
    }
  }

  Future<void> checkPermissions() async {
    _isAccessibilityGranted = await ScrolaNativeBridge.isAccessibilityServiceEnabled();
    _isOverlayGranted = await ScrolaNativeBridge.isOverlayPermissionGranted();
    _isNotificationGranted = await ScrolaNativeBridge.isNotificationPermissionGranted();
    notifyListeners();
  }

  /// Refreshes native permissions and, when needed on Android 11-16 where AppOps
  /// settles slightly after resuming from Settings, re-checks once after 250ms.
  Future<void> refreshPermissionsAndSyncOverlay({
    bool animateEntrance = false,
  }) async {
    if (_refreshPermissionsInFlight != null) {
      return _refreshPermissionsInFlight!;
    }
    final future = _doRefreshPermissionsAndSyncOverlay(
      animateEntrance: animateEntrance,
    );
    _refreshPermissionsInFlight = future;
    try {
      await future;
    } finally {
      if (identical(_refreshPermissionsInFlight, future)) {
        _refreshPermissionsInFlight = null;
      }
    }
  }

  Future<void> _doRefreshPermissionsAndSyncOverlay({
    required bool animateEntrance,
  }) async {
    final prevAccess = _isAccessibilityGranted;
    final prevOverlay = _isOverlayGranted;
    await checkPermissions();
    if (_isOverlayGranted) {
      await startOverlayIfActive(
        animateEntrance: animateEntrance || !prevOverlay,
      );
    }
    if (_isAccessibilityGranted != prevAccess && !_isAccessibilityGranted) {
      return;
    }
    if (!_isAccessibilityGranted || !_isOverlayGranted) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final laterOverlay = await ScrolaNativeBridge.isOverlayPermissionGranted();
      final laterAccess = await ScrolaNativeBridge.isAccessibilityServiceEnabled();
      if (laterOverlay != _isOverlayGranted || laterAccess != _isAccessibilityGranted) {
        final overlayJustGranted = !prevOverlay && laterOverlay;
        _isOverlayGranted = laterOverlay;
        _isAccessibilityGranted = laterAccess;
        notifyListeners();
        if (laterOverlay) {
          await startOverlayIfActive(animateEntrance: overlayJustGranted);
        }
      }
    }
  }

  Future<void> requestAccessibilityPermission() async {
    await ScrolaNativeBridge.openAccessibilitySettings();
  }

  Future<void> requestOverlayPermission() async {
    await ScrolaNativeBridge.requestOverlayPermission();
  }

  Future<bool> requestNotificationPermission() async {
    final granted = await ScrolaNativeBridge.requestNotificationPermission();
    _isNotificationGranted = granted;
    notifyListeners();
    return granted;
  }

  Future<void> completeOnboarding({
    required String goal,
    required int dailyLimit,
    required List<String> platforms,
  }) async {
    await _storage?.setSelectedGoal(goal);
    await _storage?.setSelectedPlatforms(platforms);
    await _storage?.setLimits(total: dailyLimit);
    await _storage?.setPlatformLimitsEnabled(false);
    // Do not auto-enable Scrola when onboarding finishes; user explicitly turns ON.
    await _storage?.setTrackingEnabled(false);
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
    Map<String, int>? platformLimits,
    bool? platformLimitsEnabled,
  }) async {
    await _storage?.setLimits(
      total: total,
      instagram: instagram,
      youtube: youtube,
      facebook: facebook,
      snapchat: snapchat,
      platformLimits: platformLimits,
    );
    if (platformLimitsEnabled != null) {
      await _storage?.setPlatformLimitsEnabled(platformLimitsEnabled);
    }
    await syncLimitsWithNative();
    notifyListeners();
  }

  Future<void> setPlatformLimitsEnabled(bool enabled) async {
    final storage = await _ensureStorage();
    await storage.setPlatformLimitsEnabled(enabled);
    await syncLimitsWithNative();
    notifyListeners();
  }

  Future<void> toggleTracking(
    bool enabled, {
    bool startOverlayNow = true,
    bool animateOverlayEntrance = true,
  }) async {
    final storage = await _ensureStorage();
    await storage.setTrackingEnabled(enabled);
    await syncLimitsWithNative();
    if (enabled) {
      if (startOverlayNow && storage.isOverlayEnabled) {
        if (!_isOverlayGranted) {
          _isOverlayGranted =
              await ScrolaNativeBridge.isOverlayPermissionGranted();
        }
        if (_isOverlayGranted) {
          await ScrolaNativeBridge.startOverlayService(
            animateEntrance: animateOverlayEntrance,
          );
        }
      }
    } else {
      await ScrolaNativeBridge.stopOverlayService();
    }
    notifyListeners();
  }

  Future<bool> startOverlayIfActive({bool animateEntrance = true}) async {
    final storage = await _ensureStorage();
    if (!storage.isTrackingEnabled || !storage.isOverlayEnabled) {
      return false;
    }
    if (!_isOverlayGranted) {
      _isOverlayGranted = await ScrolaNativeBridge.isOverlayPermissionGranted();
      notifyListeners();
    }
    if (!_isOverlayGranted) return false;
    return ScrolaNativeBridge.startOverlayService(
      animateEntrance: animateEntrance,
    );
  }

  Future<bool> toggleOverlay(
    bool enabled, {
    bool animateEntrance = true,
  }) async {
    final storage = await _ensureStorage();
    await storage.setOverlayEnabled(enabled);
    var overlayStarted = true;
    if (enabled) {
      if (!_isOverlayGranted) {
        _isOverlayGranted =
            await ScrolaNativeBridge.isOverlayPermissionGranted();
      }
      if (!_isOverlayGranted) {
        overlayStarted = false;
      } else if (storage.isTrackingEnabled || FocusModeService().isActive) {
        overlayStarted = await ScrolaNativeBridge.startOverlayService(
          animateEntrance: animateEntrance,
        );
      }
    } else {
      await ScrolaNativeBridge.stopOverlayService();
    }
    await syncLimitsWithNative();
    notifyListeners();
    return overlayStarted;
  }

  Future<void> updateOverlayConfig({
    bool? stickToNotch,
    bool? expanded,
    String? size,
  }) async {
    if (stickToNotch != null) await _storage?.setOverlayStickToNotch(stickToNotch);
    if (expanded != null) await _storage?.setOverlayExpanded(expanded);
    if (size != null) await _storage?.setOverlaySize(size);
    await syncLimitsWithNative();
    await ScrolaNativeBridge.refreshOverlayConfig();
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
    await syncLimitsWithNative();
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
      platformLimits: _storage!.allPlatformLimits,
      isFocusActive: FocusModeService().isActive || _storage!.isDetoxActive,
      isOverlayEnabled: _storage!.isOverlayEnabled,
      isTrackingEnabled: _storage!.isTrackingEnabled,
      platformLimitsEnabled: _storage!.platformLimitsEnabled,
      selectedPlatforms: _storage!.selectedPlatforms,
      stickToNotch: _storage!.overlayStickToNotch,
      overlayExpanded: _storage!.overlayExpanded,
      overlaySize: _storage!.overlaySize,
      skinIndex: _storage!.equippedSkin.index,
    );
  }

  void _handleNativeReelEvent(ReelEvent event) async {
    debugPrint('Received reel event: ${event.eventType} on ${event.platform}');

    if (event.eventType == 'reel_watched') {
      if (event.platform.trim().isNotEmpty) {
        _lastPlatform = event.platform.trim().toLowerCase();
      }
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
    } else if (event.eventType == 'overlay_dismissed') {
      await _storage?.setOverlayEnabled(false);
      await HapticService.light();
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

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'focus_mode_service.dart';
import 'gamification_engine.dart';
import 'haptic_service.dart';
import 'scrola_native_bridge.dart';
import '../../shared/widgets/platform_icon.dart';
import 'storage_service.dart';

class TrackingService extends ChangeNotifier {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  StorageService? _storage;
  StreamSubscription<ReelEvent>? _eventSubscription;
  Future<void>? _refreshPermissionsInFlight;
  bool _focusListenerAttached = false;
  bool _lastFocusEnforcing = false;
  final StreamController<void> _limitReachedController =
      StreamController<void>.broadcast();

  Stream<void> get onLimitReached => _limitReachedController.stream;

  bool _isAccessibilityGranted = false;
  bool _isOverlayGranted = false;
  bool _isNotificationGranted = true;
  bool _isInitialized = false;
  String _lastPlatform = 'instagram';

  bool get isAccessibilityGranted => _isAccessibilityGranted;
  bool get isOverlayGranted => _isOverlayGranted;
  bool get isNotificationGranted => _isNotificationGranted;
  bool get isInitialized => _isInitialized;

  // Profile & Subscription
  String get displayName => _storage?.displayName ?? 'Alex';
  String get username => _storage?.username ?? 'alex';
  String get email => _storage?.email ?? 'alex@scrola.app';
  String get joinedMonthYear => _storage?.joinedMonthYear ?? 'Nov 2026';
  bool get isProSubscribed => _storage?.isProSubscribed ?? false;
  String get proPlan => _storage?.proPlan ?? 'yearly';

  // Onboarding & Goal
  bool get isOnboardingComplete => _storage?.isOnboardingComplete ?? false;
  String get selectedGoal => _storage?.selectedGoal ?? 'Stay under a daily limit';
  List<String> get selectedPlatforms =>
      StorageService.normalizeSelectedPlatformIds(
          _storage?.selectedPlatforms ?? const ['instagram', 'youtube']);

  List<SocialPlatform> get activePlatforms => [
        for (final id in selectedPlatforms)
          if (SocialPlatformMeta.tryParse(id) != null)
            SocialPlatformMeta.tryParse(id)!,
      ];

  List<SocialPlatform> get visiblePlatforms {
    final activeSet = activePlatforms.toSet();
    return [
      for (final platform in SocialPlatform.values)
        if (activeSet.contains(platform) || reelsForId(platform.id) > 0)
          platform,
    ];
  }

  // Real-time metrics
  int get totalReelsToday => _storage?.totalReelsToday ?? 0;
  int get totalLimit => _storage?.totalLimit ?? 40;
  int get remainingReels => (totalLimit - totalReelsToday).clamp(0, totalLimit);
  bool get isLimitReached => totalReelsToday >= totalLimit;

  int reelsForId(String id) => _storage?.reelsForPlatform(id) ?? 0;
  int limitForId(String id) {
    final normalized = id.trim().toLowerCase();
    if (_storage != null) {
      return _storage!.limitForPlatform(normalized);
    }
    final allocated = StorageService.allocateLimitsForPlatforms(
      totalLimit: totalLimit,
      selectedIds: selectedPlatforms,
    );
    return allocated[normalized] ?? 0;
  }

  int savedLimitForId(String id) {
    final normalized = id.trim().toLowerCase();
    if (_storage != null) {
      return _storage!.savedLimitForPlatform(normalized);
    }
    final allocated = StorageService.allocateLimitsForPlatforms(
      totalLimit: totalLimit,
      selectedIds: selectedPlatforms,
    );
    return allocated[normalized] ?? 0;
  }

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
  int get focusMinutesToday => _storage?.focusMinutesToday ?? 0;
  int get focusSessionsToday => _storage?.focusSessionsToday ?? 0;

  // Gamification
  int get streakDays => _storage?.streakDays ?? 0;
  int get xpTotal => _storage?.xpTotal ?? 320;
  int get currentLevel =>
      _storage?.currentLevel ?? GamificationEngine.getLevelForXP(xpTotal).level;
  BrainySkin get equippedSkin => _storage?.equippedSkin ?? BrainySkin.classic;
  bool get isDailyXpCollectedToday => _storage?.isDailyXpCollectedToday ?? false;
  bool isRewardClaimed(String rewardId) =>
      _storage?.isRewardClaimed(rewardId) ?? false;

  List<AchievementBadge> get badges => GamificationEngine.evaluateBadges(
        streakDays: streakDays,
        totalReelsToday: totalReelsToday,
        totalLimit: totalLimit,
        isTrackingEnabled: isTrackingEnabled,
        focusMinutesToday: focusMinutesToday,
        focusSessionsToday: focusSessionsToday,
        nightBlockEnabled: nightBlockEnabled,
        isDetoxActive: isDetoxActive,
        isDetoxCompleted: isRewardClaimed('detox_complete'),
        currentLevel: currentLevel,
      );

  int get unlockedBadgeCount => badges.where((b) => b.unlocked).length;

  Map<String, Map<String, int>> get dailyHistory =>
      _storage?.dailyHistory ?? const {};

  // Settings
  bool get isTrackingEnabled => _storage?.isTrackingEnabled ?? false;
  bool get platformLimitsEnabled => _storage?.platformLimitsEnabled ?? false;
  bool get isOverlayEnabled => _storage?.isOverlayEnabled ?? true;
  bool get overlayStickToNotch => _storage?.overlayStickToNotch ?? true;
  bool get overlayExpanded => _storage?.overlayExpanded ?? false;
  String get overlaySize => _storage?.overlaySize ?? 'Medium';
  bool get overlayReactToPace => _storage?.overlayReactToPace ?? true;
  bool get blockAtLimitEnabled => _storage?.blockAtLimitEnabled ?? true;
  bool get nightBlockEnabled => _storage?.nightBlockEnabled ?? true;
  bool get workBlockEnabled => _storage?.workBlockEnabled ?? false;
  List<String> get nightBlockDays =>
      _storage?.nightBlockDays ??
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<String> get workBlockDays =>
      _storage?.workBlockDays ?? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  bool get strictBlocking => _storage?.strictBlocking ?? false;
  bool get waitBeforeUnlock => _storage?.waitBeforeUnlock ?? true;
  bool get showBrainyOnBlock => _storage?.showBrainyOnBlock ?? true;
  int get dailyBlocksCount => _storage?.dailyBlocksCount ?? 0;
  int get emergencyUnlocksUsedToday => _storage?.emergencyUnlocksUsedToday ?? 0;
  int get emergencyUnlocksLeft => (3 - emergencyUnlocksUsedToday).clamp(0, 3);
  int get detoxDays => _storage?.detoxDays ?? 1;
  bool get isDetoxActive => _storage?.isDetoxActive ?? false;
  bool get hapticsEnabled => _storage?.hapticsEnabled ?? true;
  HapticIntensity get hapticIntensity => _storage?.hapticIntensity ?? HapticIntensity.medium;

  // Notifications
  bool get notifWarnNearLimit => _storage?.notifWarnNearLimit ?? true;
  List<String> get notifThresholds =>
      _storage?.notifThresholds ?? const ['80%', '100%'];
  bool get notifStreakReminder => _storage?.notifStreakReminder ?? true;
  bool get notifFocusEnd => _storage?.notifFocusEnd ?? true;
  bool get notifLevelUps => _storage?.notifLevelUps ?? true;
  bool get notifWeeklyReport => _storage?.notifWeeklyReport ?? false;
  bool get notifQuietHours => _storage?.notifQuietHours ?? true;
  bool get anyNotificationsEnabled =>
      _storage?.anyNotificationsEnabled ?? true;

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

  @visibleForTesting
  Future<void> resetForTest() async {
    final sub = _eventSubscription;
    _eventSubscription = null;
    if (sub != null) {
      unawaited(sub.cancel().catchError((_) {}));
    }
    _storage = null;
    _isInitialized = false;
    _lastPlatform = 'instagram';
    await _ensureStorage();
  }

  void _onFocusModeChanged() {
    final enforcing = FocusModeService().isEnforcing;
    if (enforcing != _lastFocusEnforcing) {
      _lastFocusEnforcing = enforcing;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _ensureStorage();
    if (!_focusListenerAttached) {
      _lastFocusEnforcing = FocusModeService().isEnforcing;
      FocusModeService().addListener(_onFocusModeChanged);
      _focusListenerAttached = true;
    }
    await checkPermissions();
    await syncFromNative();
    await syncLimitsWithNative();
    await startOverlayIfActive(animateEntrance: false);

    _eventSubscription?.cancel();
    try {
      _eventSubscription = ScrolaNativeBridge.reelEventsStream.listen(
        _handleNativeReelEvent,
        onError: (err) {
          debugPrint('Reel stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('Reel stream attach error: $e');
    }

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
        final nativeLastPlatform =
            (stats['lastPlatform'] as String?)?.trim().toLowerCase();
        if (nativeLastPlatform != null && nativeLastPlatform.isNotEmpty) {
          _lastPlatform = nativeLastPlatform;
        }
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
    bool preserveExistingSettings = false,
  }) async {
    final storage = await _ensureStorage();
    final normalizedPlatforms =
        StorageService.normalizeSelectedPlatformIds(platforms);
    await storage.setSelectedGoal(goal);
    await storage.setSelectedPlatforms(normalizedPlatforms);
    await storage.setLimits(total: dailyLimit);
    if (!preserveExistingSettings) {
      await storage.clearCustomPlatformLimits();
      await storage.setPlatformLimitsEnabled(false);
      await storage.setBlockAtLimitEnabled(goal != 'Just track for now');
      // Do not auto-enable Scrola when onboarding finishes; user explicitly turns ON.
      await storage.setTrackingEnabled(false);
    }
    await storage.setOnboardingComplete(true);
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
    final storage = await _ensureStorage();
    await storage.setLimits(
      total: total,
      instagram: instagram,
      youtube: youtube,
      facebook: facebook,
      snapchat: snapchat,
      platformLimits: platformLimits,
    );
    if (platformLimitsEnabled != null) {
      await storage.setPlatformLimitsEnabled(platformLimitsEnabled);
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
    } else if (!FocusModeService().isActive && !storage.isDetoxActive) {
      await ScrolaNativeBridge.stopOverlayService();
    }
    notifyListeners();
  }

  Future<bool> startOverlayIfActive({bool animateEntrance = true}) async {
    final storage = await _ensureStorage();
    final shouldShowOverlay = storage.isTrackingEnabled ||
        FocusModeService().isActive ||
        storage.isDetoxActive;
    if (!shouldShowOverlay || !storage.isOverlayEnabled) {
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
      } else if (storage.isTrackingEnabled ||
          FocusModeService().isActive ||
          storage.isDetoxActive) {
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

  Future<void> updateSelectedPlatforms(List<String> platforms) async {
    final storage = await _ensureStorage();
    await storage.setSelectedPlatforms(platforms);
    notifyListeners();
    await syncLimitsWithNative();
  }

  Future<void> updateOverlayConfig({
    bool? stickToNotch,
    bool? expanded,
    String? size,
    bool? reactToPace,
  }) async {
    final storage = await _ensureStorage();
    if (stickToNotch != null) await storage.setOverlayStickToNotch(stickToNotch);
    if (expanded != null) await storage.setOverlayExpanded(expanded);
    if (size != null) await storage.setOverlaySize(size);
    if (reactToPace != null) await storage.setOverlayReactToPace(reactToPace);
    notifyListeners();
    await syncLimitsWithNative();
    await ScrolaNativeBridge.refreshOverlayConfig();
  }

  Future<void> updateBlockingConfig({
    bool? blockAtLimit,
    bool? nightBlock,
    bool? workBlock,
    List<String>? nightBlockDays,
    List<String>? workBlockDays,
    bool? strict,
    bool? waitBeforeUnlock,
    bool? showBrainyOnBlock,
    bool? detox,
    int? detoxDays,
  }) async {
    final storage = await _ensureStorage();
    if (blockAtLimit != null) await storage.setBlockAtLimitEnabled(blockAtLimit);
    if (nightBlock != null) await storage.setNightBlockEnabled(nightBlock);
    if (workBlock != null) await storage.setWorkBlockEnabled(workBlock);
    if (nightBlockDays != null) {
      await storage.setNightBlockDays(nightBlockDays);
    }
    if (workBlockDays != null) await storage.setWorkBlockDays(workBlockDays);
    if (strict != null) await storage.setStrictBlocking(strict);
    if (waitBeforeUnlock != null) {
      await storage.setWaitBeforeUnlock(waitBeforeUnlock);
    }
    if (showBrainyOnBlock != null) {
      await storage.setShowBrainyOnBlock(showBrainyOnBlock);
    }
    if (detox != null) {
      await storage.setDetoxActive(detox, days: detoxDays);
    } else if (detoxDays != null) {
      await storage.setDetoxActive(storage.isDetoxActive, days: detoxDays);
    }
    notifyListeners();
    await syncLimitsWithNative();
    if (detox != null) {
      if (detox) {
        await startOverlayIfActive(animateEntrance: true);
      } else if (!storage.isTrackingEnabled && !FocusModeService().isActive) {
        await ScrolaNativeBridge.stopOverlayService();
      }
    }
  }

  Future<bool> useEmergencyUnlock([int minutes = 5]) async {
    final storage = await _ensureStorage();
    if (storage.emergencyUnlocksUsedToday >= 3) return false;
    await storage.incrementEmergencyUnlocksUsed();
    await ScrolaNativeBridge.grantEmergencyUnlock(minutes);
    notifyListeners();
    return true;
  }

  Future<void> updateNotificationConfig({
    bool? warnNearLimit,
    List<String>? thresholds,
    bool? streakReminder,
    bool? focusEnd,
    bool? levelUps,
    bool? weeklyReport,
    bool? quietHours,
  }) async {
    final storage = await _ensureStorage();
    await storage.setNotificationConfig(
      warnNearLimit: warnNearLimit,
      thresholds: thresholds,
      streakReminder: streakReminder,
      focusEnd: focusEnd,
      levelUps: levelUps,
      weeklyReport: weeklyReport,
      quietHours: quietHours,
    );
    notifyListeners();
  }

  Future<void> updateProSubscription({
    bool? subscribed,
    String? plan,
  }) async {
    final storage = await _ensureStorage();
    await storage.setProSubscription(subscribed: subscribed, plan: plan);
    notifyListeners();
  }

  String buildCsvExport() {
    final buffer = StringBuffer()
      ..writeln('date,reels,limit,focus_minutes,blocks');
    final entries = dailyHistory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in entries) {
      final d = entry.value;
      buffer.writeln(
        '${entry.key},${d['reels'] ?? 0},${d['limit'] ?? totalLimit},${d['focusMinutes'] ?? 0},${d['blocks'] ?? 0}',
      );
    }
    return buffer.toString();
  }

  Future<void> updateHapticsConfig({
    bool? enabled,
    HapticIntensity? intensity,
  }) async {
    final storage = await _ensureStorage();
    if (enabled != null) await storage.setHapticsEnabled(enabled);
    if (intensity != null) await storage.setHapticIntensity(intensity);
    notifyListeners();
  }

  Future<void> equipSkin(BrainySkin skin) async {
    final storage = await _ensureStorage();
    await storage.setEquippedSkin(skin);
    notifyListeners();
    await syncLimitsWithNative();
  }

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? email,
  }) async {
    final storage = await _ensureStorage();
    await storage.setProfile(
      displayName: displayName,
      username: username,
      email: email,
    );
    notifyListeners();
  }

  Future<void> addXP(int xp) async {
    final storage = await _ensureStorage();
    await storage.addXP(xp);
    notifyListeners();
  }

  Future<bool> collectDailyXP(int xp) async {
    final storage = await _ensureStorage();
    final marked = await storage.markDailyXpCollectedToday();
    if (!marked) return false;
    if (xp > 0) {
      await storage.addXP(xp);
    }
    notifyListeners();
    return true;
  }

  Future<bool> claimReward(
    String rewardId, {
    int xp = 0,
    BrainySkin? equipSkinOnClaim,
  }) async {
    final storage = await _ensureStorage();
    final claimed = await storage.markRewardClaimed(rewardId);
    if (!claimed) return false;
    if (xp > 0) {
      await storage.addXP(xp);
    }
    if (equipSkinOnClaim != null) {
      await storage.setEquippedSkin(equipSkinOnClaim);
    }
    notifyListeners();
    if (equipSkinOnClaim != null) {
      await syncLimitsWithNative();
    }
    return true;
  }

  Future<void> recordFocusCompleted(int minutes, {int bonusXP = 30}) async {
    final storage = await _ensureStorage();
    await storage.recordFocusCompleted(minutes);
    if (bonusXP > 0) {
      await storage.addXP(bonusXP);
    }
    notifyListeners();
  }

  Future<void> syncLimitsWithNative() async {
    final storage = await _ensureStorage();
    await ScrolaNativeBridge.syncLimits(
      totalLimit: storage.totalLimit,
      instagramLimit: storage.instagramLimit,
      youtubeLimit: storage.youtubeLimit,
      facebookLimit: storage.facebookLimit,
      snapchatLimit: storage.snapchatLimit,
      platformLimits: storage.allPlatformLimits,
      isFocusActive: FocusModeService().isEnforcing,
      isOverlayEnabled: storage.isOverlayEnabled,
      isTrackingEnabled: storage.isTrackingEnabled,
      platformLimitsEnabled: storage.platformLimitsEnabled,
      selectedPlatforms: storage.selectedPlatforms,
      stickToNotch: storage.overlayStickToNotch,
      overlayExpanded: storage.overlayExpanded,
      overlaySize: storage.overlaySize,
      skinIndex: storage.equippedSkin.index,
      nightBlockEnabled: storage.nightBlockEnabled,
      workBlockEnabled: storage.workBlockEnabled,
      strictBlocking: storage.strictBlocking,
      detoxActive: storage.isDetoxActive,
      emergencyUnlocksUsed: storage.emergencyUnlocksUsedToday,
    );
  }

  void _handleNativeReelEvent(ReelEvent event) async {
    debugPrint('Received reel event: ${event.eventType} on ${event.platform}');

    if (event.eventType == 'reel_watched') {
      final storage = await _ensureStorage();
      if (event.platform.trim().isNotEmpty) {
        _lastPlatform = event.platform.trim().toLowerCase();
      }
      await storage.recordReel(event.platform);

      // Design spec Section 6: "Never vibrate while counting reels."
      // Only fire warning/error haptics when hitting 80% or 100% thresholds
      if (totalReelsToday == totalLimit) {
        await HapticService.warning();
        _limitReachedController.add(null);
      } else if (totalReelsToday > totalLimit) {
        await HapticService.error();
      }

      notifyListeners();
    } else if (event.eventType == 'limit_block_enforced' ||
        event.eventType == 'focus_block_enforced') {
      final storage = await _ensureStorage();
      await storage.incrementDailyBlocksCount();
      FocusModeService().incrementBlockedAttempt();
      await HapticService.error();
      if (event.eventType == 'limit_block_enforced') {
        _limitReachedController.add(null);
      }
      notifyListeners();
    } else if (event.eventType == 'emergency_unlock_used') {
      final storage = await _ensureStorage();
      await storage.incrementEmergencyUnlocksUsed();
      await HapticService.medium();
      notifyListeners();
    } else if (event.eventType == 'overlay_dismissed') {
      final storage = await _ensureStorage();
      await storage.setOverlayEnabled(false);
      await HapticService.light();
      notifyListeners();
    }
  }

  Future<void> resetSession() async {
    final storage = await _ensureStorage();
    await storage.resetSession();
    await ScrolaNativeBridge.resetSession();
    notifyListeners();
  }

  Future<void> resetDailyStats() async {
    final storage = await _ensureStorage();
    await storage.resetDailyStats();
    _lastPlatform = '';
    await ScrolaNativeBridge.resetDailyStats();
    notifyListeners();
  }

  @override
  void dispose() {
    final sub = _eventSubscription;
    _eventSubscription = null;
    if (sub != null) {
      unawaited(sub.cancel().catchError((_) {}));
    }
    if (_focusListenerAttached) {
      FocusModeService().removeListener(_onFocusModeChanged);
      _focusListenerAttached = false;
    }
    super.dispose();
  }
}

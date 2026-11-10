import 'dart:async';
import 'package:flutter/foundation.dart';
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

  int get streakDays => _storage?.streakDays ?? 7;
  int get xpTotal => _storage?.xpTotal ?? 320;
  int get currentLevel => _storage?.currentLevel ?? 4;

  BrainyMascotState get mascotState {
    return GamificationEngine.evaluateMascotState(
      reelsWatched: totalReelsToday,
      dailyLimit: totalLimit,
      isFocusModeActive: false,
      isDailyGoalCompleted: false,
    );
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _storage = await StorageService.getInstance();
    await checkPermissions();
    await syncLimitsWithNative();
    await syncFromNative();

    // Subscribe to native reel & blocking events
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

  /// Sync counts that occurred natively while Flutter was backgrounded
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

  Future<void> syncLimitsWithNative() async {
    if (_storage == null) return;
    await ScrolaNativeBridge.syncLimits(
      totalLimit: _storage!.totalLimit,
      instagramLimit: _storage!.instagramLimit,
      youtubeLimit: _storage!.youtubeLimit,
      facebookLimit: _storage!.facebookLimit,
      snapchatLimit: _storage!.snapchatLimit,
      isFocusActive: false,
      isOverlayEnabled: _storage!.isOverlayEnabled,
    );
  }

  void _handleNativeReelEvent(ReelEvent event) async {
    debugPrint('Received reel event: ${event.eventType} on ${event.platform}');

    if (event.eventType == 'reel_watched') {
      await _storage?.recordReel(event.platform);

      // Check for limit thresholds to give haptic feedback
      if (totalReelsToday >= totalLimit) {
        await HapticService.error();
      } else if (totalReelsToday >= (totalLimit * 0.8)) {
        await HapticService.warning();
      } else {
        await HapticService.subtle();
      }

      notifyListeners();
    } else if (event.eventType == 'limit_block_enforced' || event.eventType == 'focus_block_enforced') {
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

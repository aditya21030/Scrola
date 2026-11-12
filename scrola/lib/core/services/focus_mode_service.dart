import 'dart:async';
import 'package:flutter/foundation.dart';
import 'haptic_service.dart';
import 'scrola_native_bridge.dart';
import 'storage_service.dart';
import 'tracking_service.dart';

class FocusModeService extends ChangeNotifier {
  static final FocusModeService _instance = FocusModeService._internal();
  factory FocusModeService() => _instance;
  FocusModeService._internal();

  Timer? _ticker;
  int _totalDurationSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  int _endEpochMs = 0;
  bool _isActive = false;
  bool _isPaused = false;
  bool _justCompleted = false;
  bool _completing = false;
  int _blockedAttempts = 0;

  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  bool get isEnforcing => _isActive && !_isPaused;
  bool get isJustCompleted => _justCompleted;
  int get remainingSeconds => _remainingSeconds;
  int get totalDurationSeconds => _totalDurationSeconds;
  int get blockedAttempts => _blockedAttempts;

  double get progress => _totalDurationSeconds > 0
      ? (1.0 - (_remainingSeconds / _totalDurationSeconds)).clamp(0.0, 1.0)
      : 0.0;

  String get formattedRemainingTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> initialize() async {
    final storage = await StorageService.getInstance();
    if (!storage.focusIsActive) return;

    _totalDurationSeconds = (storage.focusDurationMinutes * 60).clamp(60, 24 * 3600);
    _isPaused = storage.focusIsPaused;
    _blockedAttempts = storage.focusBlockedAttempts;
    _endEpochMs = storage.focusEndEpochMs;
    _justCompleted = false;

    if (_isPaused) {
      _remainingSeconds = storage.focusRemainingSeconds.clamp(0, _totalDurationSeconds);
      if (_remainingSeconds <= 0) {
        await storage.clearFocusSessionState();
        return;
      }
      _isActive = true;
      notifyListeners();
      return;
    }

    _isActive = true;
    _recomputeRemainingFromClock();
    if (_remainingSeconds <= 0) {
      await _onSessionCompleted(triggerHaptics: false);
      return;
    }
    _startTicker();
    notifyListeners();
  }

  Future<void> startSession({int minutes = 25}) async {
    _totalDurationSeconds = (minutes * 60).clamp(60, 24 * 3600);
    _remainingSeconds = _totalDurationSeconds;
    _endEpochMs =
        DateTime.now().millisecondsSinceEpoch + (_totalDurationSeconds * 1000);
    _isActive = true;
    _isPaused = false;
    _justCompleted = false;
    _completing = false;
    _blockedAttempts = 0;

    unawaited(HapticService.medium());

    final storage = await StorageService.getInstance();
    await _persistState(storage);
    await TrackingService().syncLimitsWithNative();
    await TrackingService().startOverlayIfActive(animateEntrance: true);

    _startTicker();
    notifyListeners();
  }

  Future<void> _persistState(StorageService storage) async {
    await storage.saveFocusSessionState(
      isActive: _isActive,
      isPaused: _isPaused,
      durationMinutes: (_totalDurationSeconds ~/ 60).clamp(1, 24 * 60),
      endEpochMs: _endEpochMs,
      remainingSeconds: _remainingSeconds,
      blockedAttempts: _blockedAttempts,
    );
  }

  void _recomputeRemainingFromClock() {
    if (!_isActive || _isPaused || _endEpochMs <= 0) return;
    final diffMs = _endEpochMs - DateTime.now().millisecondsSinceEpoch;
    _remainingSeconds = diffMs <= 0 ? 0 : (diffMs / 1000).ceil();
  }

  void syncTimerOnResume() {
    if (!_isActive || _isPaused) return;
    _recomputeRemainingFromClock();
    if (_remainingSeconds <= 0) {
      _onSessionCompleted();
    } else {
      notifyListeners();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused || !_isActive) return;
      final prev = _remainingSeconds;
      _recomputeRemainingFromClock();
      if (_remainingSeconds <= 0) {
        _onSessionCompleted();
      } else if (_remainingSeconds != prev) {
        notifyListeners();
      }
    });
  }

  Future<void> togglePause() async {
    if (!_isActive) return;
    if (_isPaused) {
      _isPaused = false;
      _endEpochMs =
          DateTime.now().millisecondsSinceEpoch + (_remainingSeconds * 1000);
    } else {
      _recomputeRemainingFromClock();
      _isPaused = true;
      _endEpochMs = 0;
    }

    final storage = await StorageService.getInstance();
    await _persistState(storage);
    await TrackingService().syncLimitsWithNative();
    await HapticService.light();
    notifyListeners();
  }

  Future<void> addFiveMinutes() async {
    if (!_isActive) return;
    _totalDurationSeconds += 5 * 60;
    if (_isPaused) {
      _remainingSeconds += 5 * 60;
    } else {
      _endEpochMs += 5 * 60 * 1000;
      _recomputeRemainingFromClock();
    }

    final storage = await StorageService.getInstance();
    await _persistState(storage);
    await HapticService.light();
    notifyListeners();
  }

  void incrementBlockedAttempt() {
    if (_isActive) {
      _blockedAttempts++;
      StorageService.getInstance().then((storage) {
        if (_isActive) _persistState(storage);
      });
      notifyListeners();
    }
  }

  void dismissCompletion() {
    if (!_justCompleted) return;
    _justCompleted = false;
    _remainingSeconds = _totalDurationSeconds;
    notifyListeners();
  }

  Future<void> cancelSession() async {
    _ticker?.cancel();
    _isActive = false;
    _isPaused = false;
    _justCompleted = false;
    _completing = false;
    _endEpochMs = 0;
    _remainingSeconds = _totalDurationSeconds;

    final storage = await StorageService.getInstance();
    await storage.clearFocusSessionState();
    await TrackingService().syncLimitsWithNative();
    if (!storage.isTrackingEnabled && !storage.isDetoxActive) {
      await ScrolaNativeBridge.stopOverlayService();
    }

    await HapticService.medium();
    notifyListeners();
  }

  Future<void> _onSessionCompleted({bool triggerHaptics = true}) async {
    if (_completing) return;
    _completing = true;
    try {
      _ticker?.cancel();
      _isActive = false;
      _isPaused = false;
      _endEpochMs = 0;
      _remainingSeconds = 0;
      _justCompleted = true;

      final completedMinutes = (_totalDurationSeconds ~/ 60).clamp(1, 24 * 60);
      final storage = await StorageService.getInstance();
      await storage.clearFocusSessionState();
      await TrackingService().recordFocusCompleted(
        completedMinutes,
        bonusXP: 30,
      );
      await TrackingService().syncLimitsWithNative();
      if (!storage.isTrackingEnabled && !storage.isDetoxActive) {
        await ScrolaNativeBridge.stopOverlayService();
      }

      if (triggerHaptics) {
        await HapticService.celebratory();
      }
      notifyListeners();
    } finally {
      _completing = false;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

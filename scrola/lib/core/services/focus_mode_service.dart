import 'dart:async';
import 'package:flutter/foundation.dart';
import 'haptic_service.dart';
import 'scrola_native_bridge.dart';
import 'storage_service.dart';

class FocusModeService extends ChangeNotifier {
  static final FocusModeService _instance = FocusModeService._internal();
  factory FocusModeService() => _instance;
  FocusModeService._internal();

  Timer? _ticker;
  int _totalDurationSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isActive = false;
  bool _isPaused = false;
  int _blockedAttempts = 0;

  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
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

  Future<void> startSession({int minutes = 25}) async {
    _totalDurationSeconds = minutes * 60;
    _remainingSeconds = _totalDurationSeconds;
    _isActive = true;
    _isPaused = false;
    _blockedAttempts = 0;

    await HapticService.medium();

    final storage = await StorageService.getInstance();
    await ScrolaNativeBridge.syncLimits(
      totalLimit: storage.totalLimit,
      instagramLimit: storage.instagramLimit,
      youtubeLimit: storage.youtubeLimit,
      facebookLimit: storage.facebookLimit,
      snapchatLimit: storage.snapchatLimit,
      isFocusActive: true,
      isOverlayEnabled: storage.isOverlayEnabled,
    );

    _startTicker();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          _onSessionCompleted();
        }
      }
    });
  }

  Future<void> togglePause() async {
    if (!_isActive) return;
    _isPaused = !_isPaused;
    await HapticService.light();
    notifyListeners();
  }

  Future<void> addFiveMinutes() async {
    if (!_isActive) return;
    _totalDurationSeconds += 5 * 60;
    _remainingSeconds += 5 * 60;
    await HapticService.light();
    notifyListeners();
  }

  void incrementBlockedAttempt() {
    if (_isActive) {
      _blockedAttempts++;
      notifyListeners();
    }
  }

  Future<void> cancelSession() async {
    _ticker?.cancel();
    _isActive = false;
    _isPaused = false;
    _remainingSeconds = _totalDurationSeconds;

    final storage = await StorageService.getInstance();
    await ScrolaNativeBridge.syncLimits(
      totalLimit: storage.totalLimit,
      instagramLimit: storage.instagramLimit,
      youtubeLimit: storage.youtubeLimit,
      facebookLimit: storage.facebookLimit,
      snapchatLimit: storage.snapchatLimit,
      isFocusActive: false,
      isOverlayEnabled: storage.isOverlayEnabled,
    );

    await HapticService.medium();
    notifyListeners();
  }

  Future<void> _onSessionCompleted() async {
    _ticker?.cancel();
    _isActive = false;
    _isPaused = false;

    final storage = await StorageService.getInstance();
    await storage.addXP(30);
    await storage.recordFocusCompleted(_totalDurationSeconds ~/ 60);

    await ScrolaNativeBridge.syncLimits(
      totalLimit: storage.totalLimit,
      instagramLimit: storage.instagramLimit,
      youtubeLimit: storage.youtubeLimit,
      facebookLimit: storage.facebookLimit,
      snapchatLimit: storage.snapchatLimit,
      isFocusActive: false,
      isOverlayEnabled: storage.isOverlayEnabled,
    );

    await HapticService.celebratory();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

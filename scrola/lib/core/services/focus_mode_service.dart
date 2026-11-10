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

  bool get isActive => _isActive;
  int get remainingSeconds => _remainingSeconds;
  int get totalDurationSeconds => _totalDurationSeconds;
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

    await HapticService.heavy();

    // Inform native layer to lock feeds immediately
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

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onSessionCompleted();
      }
    });

    notifyListeners();
  }

  Future<void> cancelSession() async {
    _ticker?.cancel();
    _isActive = false;
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

    // Grant 30 XP for completing focus session
    final storage = await StorageService.getInstance();
    await storage.addXP(30);

    await ScrolaNativeBridge.syncLimits(
      totalLimit: storage.totalLimit,
      instagramLimit: storage.instagramLimit,
      youtubeLimit: storage.youtubeLimit,
      facebookLimit: storage.facebookLimit,
      snapchatLimit: storage.snapchatLimit,
      isFocusActive: false,
      isOverlayEnabled: storage.isOverlayEnabled,
    );

    await HapticService.success();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

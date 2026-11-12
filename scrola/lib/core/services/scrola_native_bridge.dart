import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ReelEvent {
  final String eventType;
  final String platform;
  final int count;
  final int total;
  final int timestamp;

  ReelEvent({
    required this.eventType,
    required this.platform,
    required this.count,
    required this.total,
    required this.timestamp,
  });

  factory ReelEvent.fromMap(Map<dynamic, dynamic> map) {
    return ReelEvent(
      eventType: map['eventType'] as String? ?? '',
      platform: map['platform'] as String? ?? '',
      count: (map['count'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toInt() ?? 0,
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
    );
  }
}

class ScrolaNativeBridge {
  static const MethodChannel _methodChannel = MethodChannel('com.scrola.app/native');
  static const EventChannel _eventChannel = EventChannel('com.scrola.app/reel_events');

  static Stream<ReelEvent>? _eventStream;

  static Future<T?> _invoke<T>(String method, [dynamic arguments]) async {
    try {
      return await _methodChannel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      debugPrint('Error invoking $method: $e');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Check if the Android Accessibility Service is enabled by the user
  static Future<bool> isAccessibilityServiceEnabled() async {
    return (await _invoke<bool>('isAccessibilityServiceEnabled')) ?? false;
  }

  /// Open Android Accessibility Settings so the user can enable Scrola
  static Future<void> openAccessibilitySettings() async {
    await _invoke<void>('openAccessibilitySettings');
  }

  /// Check if System Alert Window (Overlay) permission is granted
  static Future<bool> isOverlayPermissionGranted() async {
    return (await _invoke<bool>('isOverlayPermissionGranted')) ?? false;
  }

  /// Launch Android Settings to grant draw over other apps permission
  static Future<void> requestOverlayPermission() async {
    await _invoke<void>('requestOverlayPermission');
  }

  /// Start the floating tracker overlay. Returns true if the native service
  /// started or updated cleanly.
  static Future<bool> startOverlayService({bool animateEntrance = true}) async {
    return (await _invoke<bool>(
          'startOverlayService',
          {'animateEntrance': animateEntrance},
        )) ??
        false;
  }

  /// Stop the floating tracker overlay
  static Future<void> stopOverlayService() async {
    await _invoke<void>('stopOverlayService');
  }

  /// Refresh live overlay layout/position/style config without restarting
  static Future<void> refreshOverlayConfig() async {
    await _invoke<void>('refreshOverlayConfig');
  }

  /// Check if Android 13+ notification permission is granted
  static Future<bool> isNotificationPermissionGranted() async {
    return (await _invoke<bool>('isNotificationPermissionGranted')) ?? true;
  }

  /// Prompt Android 13+ runtime notification permission dialog
  static Future<bool> requestNotificationPermission() async {
    return (await _invoke<bool>('requestNotificationPermission')) ?? false;
  }

  /// Synchronize configured limits and focus status to Native Android services
  static Future<void> syncLimits({
    required int totalLimit,
    required int instagramLimit,
    required int youtubeLimit,
    required int facebookLimit,
    required int snapchatLimit,
    Map<String, int>? platformLimits,
    required bool isFocusActive,
    required bool isOverlayEnabled,
    bool? isTrackingEnabled,
    bool? platformLimitsEnabled,
    List<String>? selectedPlatforms,
    bool? stickToNotch,
    bool? overlayExpanded,
    String? overlaySize,
    int? skinIndex,
    bool? nightBlockEnabled,
    bool? workBlockEnabled,
    bool? strictBlocking,
    bool? detoxActive,
  }) async {
    await _invoke<void>('syncLimits', {
      'totalLimit': totalLimit,
      'instagramLimit': instagramLimit,
      'youtubeLimit': youtubeLimit,
      'facebookLimit': facebookLimit,
      'snapchatLimit': snapchatLimit,
      'platformLimits': ?platformLimits,
      'isFocusActive': isFocusActive,
      'isOverlayEnabled': isOverlayEnabled,
      'isTrackingEnabled': ?isTrackingEnabled,
      'platformLimitsEnabled': ?platformLimitsEnabled,
      'selectedPlatforms': ?selectedPlatforms,
      'stickToNotch': ?stickToNotch,
      'overlayExpanded': ?overlayExpanded,
      'overlaySize': ?overlaySize,
      'skinIndex': ?skinIndex,
      'nightBlockEnabled': ?nightBlockEnabled,
      'workBlockEnabled': ?workBlockEnabled,
      'strictBlocking': ?strictBlocking,
      'detoxActive': ?detoxActive,
    });
  }

  /// Update the floating overlay display metrics
  static Future<void> updateOverlayStats({
    required int today,
    required int limit,
    required int session,
    String platform = '',
    bool isFocus = false,
  }) async {
    await _invoke<void>('updateOverlayStats', {
      'today': today,
      'limit': limit,
      'session': session,
      'platform': platform,
      'isFocus': isFocus,
    });
  }

  /// Read current stats recorded by Native services
  static Future<Map<String, dynamic>> getNativeStats() async {
    try {
      final result =
          await _methodChannel.invokeMapMethod<String, dynamic>('getNativeStats');
      return result ?? {};
    } on PlatformException catch (e) {
      debugPrint('Error getting native stats: $e');
      return {};
    } on MissingPluginException {
      return {};
    }
  }

  /// Reset session reel counter
  static Future<void> resetSession() async {
    await _invoke<void>('resetSession');
  }

  /// Reset today's reel and focus statistics in native prefs
  static Future<void> resetDailyStats() async {
    await _invoke<void>('resetDailyStats');
  }

  /// Stream of real-time reel tracking and blocking events from native Android
  static Stream<ReelEvent> get reelEventsStream {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => ReelEvent.fromMap(Map<dynamic, dynamic>.from(event as Map)));
    return _eventStream!;
  }
}

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

  /// Check if the Android Accessibility Service is enabled by the user
  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool? enabled = await _methodChannel.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return enabled ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking accessibility service: $e');
      return false;
    }
  }

  /// Open Android Accessibility Settings so the user can enable Scrola
  static Future<void> openAccessibilitySettings() async {
    try {
      await _methodChannel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      debugPrint('Error opening accessibility settings: $e');
    }
  }

  /// Check if System Alert Window (Overlay) permission is granted
  static Future<bool> isOverlayPermissionGranted() async {
    try {
      final bool? granted = await _methodChannel.invokeMethod<bool>('isOverlayPermissionGranted');
      return granted ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking overlay permission: $e');
      return false;
    }
  }

  /// Launch Android Settings to grant draw over other apps permission
  static Future<void> requestOverlayPermission() async {
    try {
      await _methodChannel.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (e) {
      debugPrint('Error requesting overlay permission: $e');
    }
  }

  /// Start the floating tracker overlay
  static Future<void> startOverlayService() async {
    try {
      await _methodChannel.invokeMethod('startOverlayService');
    } on PlatformException catch (e) {
      debugPrint('Error starting overlay: $e');
    }
  }

  /// Stop the floating tracker overlay
  static Future<void> stopOverlayService() async {
    try {
      await _methodChannel.invokeMethod('stopOverlayService');
    } on PlatformException catch (e) {
      debugPrint('Error stopping overlay: $e');
    }
  }

  /// Synchronize configured limits and focus status to Native Android services
  static Future<void> syncLimits({
    required int totalLimit,
    required int instagramLimit,
    required int youtubeLimit,
    required int facebookLimit,
    required int snapchatLimit,
    required bool isFocusActive,
    required bool isOverlayEnabled,
  }) async {
    try {
      await _methodChannel.invokeMethod('syncLimits', {
        'totalLimit': totalLimit,
        'instagramLimit': instagramLimit,
        'youtubeLimit': youtubeLimit,
        'facebookLimit': facebookLimit,
        'snapchatLimit': snapchatLimit,
        'isFocusActive': isFocusActive,
        'isOverlayEnabled': isOverlayEnabled,
      });
    } on PlatformException catch (e) {
      debugPrint('Error syncing limits: $e');
    }
  }

  /// Update the floating overlay display metrics
  static Future<void> updateOverlayStats({
    required int today,
    required int limit,
    required int session,
    String platform = '',
    bool isFocus = false,
  }) async {
    try {
      await _methodChannel.invokeMethod('updateOverlayStats', {
        'today': today,
        'limit': limit,
        'session': session,
        'platform': platform,
        'isFocus': isFocus,
      });
    } on PlatformException catch (e) {
      debugPrint('Error updating overlay stats: $e');
    }
  }

  /// Read current stats recorded by Native services
  static Future<Map<String, dynamic>> getNativeStats() async {
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>('getNativeStats');
      return result ?? {};
    } on PlatformException catch (e) {
      debugPrint('Error getting native stats: $e');
      return {};
    }
  }

  /// Reset session reel counter
  static Future<void> resetSession() async {
    try {
      await _methodChannel.invokeMethod('resetSession');
    } on PlatformException catch (e) {
      debugPrint('Error resetting session: $e');
    }
  }

  /// Stream of real-time reel tracking and blocking events from native Android
  static Stream<ReelEvent> get reelEventsStream {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => ReelEvent.fromMap(Map<dynamic, dynamic>.from(event as Map)));
    return _eventStream!;
  }
}

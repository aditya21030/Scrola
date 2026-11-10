import 'package:flutter/services.dart';

/// Scrola Haptic Language
/// Centralized HapticService providing tactile feedback across interactions.
class HapticService {
  HapticService._();

  /// 1 · Subtle: Selection click
  /// Used for nav bar items, tabs, segmented controls, slider ticks
  static Future<void> subtle() async {
    await HapticFeedback.selectionClick();
  }

  /// Light impact for card taps, chip interactions, secondary actions
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact for primary buttons, switches, toggles
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact for limit triggers, countdown events, focus lock
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Success haptic pulse sequence for rewards, streaks, level-ups
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 70));
    await HapticFeedback.lightImpact();
  }

  /// Warning haptic for approaching daily limit ("Nearly there")
  static Future<void> warning() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.lightImpact();
  }

  /// Error / blocked haptic for limit reached
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }
}

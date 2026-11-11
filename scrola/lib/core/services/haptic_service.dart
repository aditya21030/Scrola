import 'package:flutter/services.dart';

enum HapticIntensity {
  light,
  medium,
  strong,
}

/// Scrola Haptic Language (Section 9 of design.md)
/// One centralized HapticService controlling all physical feedback.
/// Rule: Never vibrate while counting reels.
class HapticService {
  HapticService._();

  static bool isEnabled = true;
  static HapticIntensity intensity = HapticIntensity.medium;

  /// 1 · Subtle: Selection click
  /// Used for: Bottom nav, tabs, segmented controls, slider ticks, pull to refresh
  static Future<void> subtle() async {
    if (!isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// 2 · Light: Light impact
  /// Used for: Buttons, toggles, selectable cards
  static Future<void> light() async {
    if (!isEnabled) return;
    switch (intensity) {
      case HapticIntensity.light:
        await HapticFeedback.selectionClick();
        break;
      case HapticIntensity.medium:
        await HapticFeedback.lightImpact();
        break;
      case HapticIntensity.strong:
        await HapticFeedback.mediumImpact();
        break;
    }
  }

  /// 3 · Medium: Medium impact / success
  /// Used for: Form submit, blocking on, battle start, focus complete
  static Future<void> medium() async {
    if (!isEnabled) return;
    switch (intensity) {
      case HapticIntensity.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticIntensity.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticIntensity.strong:
        await HapticFeedback.heavyImpact();
        break;
    }
  }

  /// 4 · Celebratory: Custom multi-step celebratory pattern
  /// Used for: Achievement unlocked, level up, evolution, setup complete, chest open
  static Future<void> celebratory() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 110));
    if (intensity == HapticIntensity.light) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Warning notification at daily limit or approaching threshold
  static Future<void> warning() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 70));
    await HapticFeedback.lightImpact();
  }

  /// Error / failure / strict block notification
  static Future<void> error() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.heavyImpact();
  }
}

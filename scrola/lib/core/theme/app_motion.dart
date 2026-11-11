import 'package:flutter/material.dart';

/// Scrola Design System v0.2 Motion Specification
/// Matches tokens.json & design.md Section 8
class AppMotion {
  AppMotion._();

  static const Duration pressFeedback = Duration(milliseconds: 120);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration entrance = Duration(milliseconds: 480);
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration data = Duration(milliseconds: 1000);
  static const Duration ringDraw = Duration(milliseconds: 1200);
  static const Duration breathing = Duration(milliseconds: 3600);
  static const Duration floatCycle = Duration(milliseconds: 4000);

  /// Entrance easing: cubic-bezier(0.2, 0.8, 0.2, 1)
  static const Cubic easeOut = Cubic(0.2, 0.8, 0.2, 1.0);

  /// Exit easing: cubic-bezier(0.4, 0, 1, 1)
  static const Cubic easeIn = Cubic(0.4, 0.0, 1.0, 1.0);

  /// Check if Android "remove animations" / reduced motion is active
  static bool isReducedMotion(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }
}

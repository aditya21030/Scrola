import 'package:flutter/material.dart';

/// Scrola Design System Motion Specification
class AppMotion {
  AppMotion._();

  static const Duration pressFeedback = Duration(milliseconds: 120);
  static const Duration quick = Duration(milliseconds: 240);
  static const Duration entrance = Duration(milliseconds: 480);
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration gauge = Duration(milliseconds: 1000);
  static const Duration counter = Duration(milliseconds: 1200);

  /// Ease-out cubic-bezier(.2, .8, .2, 1)
  static const Cubic easeOut = Cubic(0.2, 0.8, 0.2, 1.0);
}

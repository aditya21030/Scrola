import 'package:flutter/material.dart';

/// Scrola Design System v0.1 Colors
/// "Black dominates, orange guides. No purple."
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color primaryBackground = Color(0xFF101010);
  static const Color secondaryBackground = Color(0xFF191919);

  // Surfaces & Borders
  static const Color cardSurface = Color(0xFF242424);
  static const Color elevatedSurface = Color(0xFF2B2B2B);
  static const Color border = Color(0xFF353535);

  // Accents
  static const Color primaryAccent = Color(0xFFFF6B24); // Orange marks actions, progress & selection
  static const Color accentHighlight = Color(0xFFFF8A4C);

  // Typography
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFA3A3A3);
  static const Color mutedText = Color(0xFF707070); // For decoration & inactive only
  static const Color textOnAccent = Color(0xFF101010); // Text on orange is always #101010

  // Status Colors
  static const Color success = Color(0xFF36C98F);
  static const Color successBackground = Color(0xFF142B20);
  static const Color warning = Color(0xFFFFC15A);
  static const Color warningBackground = Color(0xFF2C2414);
  static const Color error = Color(0xFFFF5252);
  static const Color errorBackground = Color(0xFF2E1515);

  // Platform Brand Colors
  static const Color instagram = Color(0xFFE1306C);
  static const Color youtube = Color(0xFFFF0000);
  static const Color facebook = Color(0xFF1877F2);
  static const Color snapchat = Color(0xFFFFFC00);

  // Platform Glow Tints
  static const Color instagramGlow = Color(0x38E1306C);
  static const Color youtubeGlow = Color(0x38FF0000);
  static const Color facebookGlow = Color(0x381877F2);
  static const Color snapchatGlow = Color(0x38FFFC00);
  static const Color orangeGlow = Color(0x40FF6B24);
}

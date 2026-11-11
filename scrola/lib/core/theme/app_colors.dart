import 'package:flutter/material.dart';

/// Scrola Design System v0.2 Colors
/// Matches tokens.json & design.md:
/// "Black dominates. Orange guides. No purple."
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color primaryBackground = Color(0xFF101010); // bg.primary
  static const Color secondaryBackground = Color(0xFF191919); // bg.secondary

  // Surfaces & Borders
  static const Color surfaceSolid = Color(0xFF1A1A1A); // surface.solid (Default card)
  static const Color cardSurface = Color(0xFF242424); // surface.card (Raised card)
  static const Color elevatedSurface = Color(0xFF2B2B2B); // surface.elevated (Icon wells, pressed)
  static const Color border = Color(0xFF353535); // border (Inputs, dividers on cards)
  static const Color borderSubtle = Color(0xFF2A2A2A); // border.subtle (Card outline)

  // Accents
  static const Color primaryAccent = Color(0xFFFF6B24); // accent
  static const Color accentHighlight = Color(0xFFFF8A4C); // accent.highlight

  // Typography
  static const Color primaryText = Color(0xFFFFFFFF); // text.primary
  static const Color secondaryText = Color(0xFFA3A3A3); // text.secondary
  static const Color mutedText = Color(0xFF707070); // text.muted (Decoration only)
  static const Color textOnAccent = Color(0xFF101010); // text.onAccent
  static const Color warmText = Color(0xFFE2C3AE); // Warm accent text on hero orange gradients

  // Semantic Colors
  static const Color success = Color(0xFF36C98F);
  static const Color successBackground = Color(0xFF142B20);
  static const Color warning = Color(0xFFFFC15A);
  static const Color warningBackground = Color(0xFF2C2414);
  static const Color error = Color(0xFFFF5252);
  static const Color errorBackground = Color(0xFF2E1515);

  // Platform Brand Colors
  static const Color instagram = Color(0xFFE1306C);
  static const Color youtube = Color(0xFFFF0000);
  static const Color tiktok = Color(0xFFFE2C55);
  static const Color facebook = Color(0xFF1877F2);
  static const Color snapchat = Color(0xFFFFFC00);
  static const Color xPlatform = Color(0xFFE5E5EA);
  static const Color reddit = Color(0xFFFF4500);
  static const Color moj = Color(0xFFFF8800);

  // Platform Glow Tints
  static const Color instagramGlow = Color(0x47E1306C);
  static const Color youtubeGlow = Color(0x47FF0000);
  static const Color tiktokGlow = Color(0x47FE2C55);
  static const Color facebookGlow = Color(0x471877F2);
  static const Color snapchatGlow = Color(0x47FFFC00);
  static const Color xGlow = Color(0x33FFFFFF);
  static const Color redditGlow = Color(0x47FF4500);
  static const Color mojGlow = Color(0x47FF8800);
  static const Color orangeGlow = Color(0x40FF6B24);
}

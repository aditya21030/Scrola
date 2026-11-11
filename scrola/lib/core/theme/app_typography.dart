import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Scrola Design System v0.2 Typography
/// Plus Jakarta Sans for headings/numbers, Inter for body/data.
/// Enforces tabular numerals across numeric styles.
class AppTypography {
  AppTypography._();

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  /// Hero Display · Plus Jakarta Sans 800 · 84/84 (Home hero number)
  static TextStyle heroDisplay({Color color = AppColors.primaryText}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 84,
      height: 84 / 84,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -2.0,
      fontFeatures: tabular,
    );
  }

  /// Display · Plus Jakarta Sans 800 · 56/56 · key numbers
  static TextStyle display({Color color = AppColors.primaryText}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 56,
      height: 56 / 56,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -1.5,
      fontFeatures: tabular,
    );
  }

  /// Title · Plus Jakarta Sans 700-800 · 28-32 / 34-38
  static TextStyle title({
    Color color = AppColors.primaryText,
    double size = 28,
    FontWeight weight = FontWeight.w800,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: (size + 6) / size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.5,
      fontFeatures: tabular,
    );
  }

  /// Heading · Plus Jakarta Sans 700 · 18/24
  static TextStyle heading({
    Color color = AppColors.primaryText,
    double size = 18,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: 24 / 18,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.3,
      fontFeatures: tabular,
    );
  }

  /// Subheading · Plus Jakarta Sans 600-700 · 16/22
  static TextStyle subheading({Color color = AppColors.primaryText}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 16,
      height: 22 / 16,
      fontWeight: FontWeight.w700,
      color: color,
      fontFeatures: tabular,
    );
  }

  /// Body · Inter 500 · 15/22
  static TextStyle body({
    Color color = AppColors.secondaryText,
    FontWeight weight = FontWeight.w500,
    double size = 15,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: 22 / 15,
      fontWeight: weight,
      color: color,
      fontFeatures: tabular,
    );
  }

  /// Label · Inter 600 · 11-13 / 16 · caps
  static TextStyle label({
    Color color = AppColors.secondaryText,
    double letterSpacing = 0.8,
    double size = 12,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: 16 / size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: tabular,
    );
  }

  /// Small Caption · Inter 500 · 11-12
  static TextStyle caption({
    Color color = AppColors.mutedText,
    double size = 12,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: 16 / size,
      fontWeight: weight,
      color: color,
      fontFeatures: tabular,
    );
  }

  /// Tabular numeric style · Plus Jakarta Sans with tabular figures
  static TextStyle numeric({
    Color color = AppColors.primaryText,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w800,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      height: height ?? 1.15,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: tabular,
    );
  }
}

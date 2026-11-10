import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Scrola Design System v0.1 Typography
/// 5 strict levels using Plus Jakarta Sans and Inter
class AppTypography {
  AppTypography._();

  /// Display · Plus Jakarta Sans 800 · 56/56 · key numbers
  static TextStyle display({Color color = AppColors.primaryText}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 56,
      height: 56 / 56,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -1.0,
    );
  }

  /// Title · Plus Jakarta Sans 700 · 28/34
  static TextStyle title({Color color = AppColors.primaryText}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 28,
      height: 34 / 28,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.5,
    );
  }

  /// Heading · Plus Jakarta Sans 700 · 18/24
  static TextStyle heading({Color color = AppColors.primaryText}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.3,
    );
  }

  /// Subheading · Plus Jakarta Sans 600 · 16/22
  static TextStyle subheading({Color color = AppColors.primaryText}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 16,
      height: 22 / 16,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Body · Inter 500 · 15/22
  static TextStyle body({Color color = AppColors.secondaryText}) {
    return GoogleFonts.inter(
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  /// Label · Inter 600 · 12/16 · caps
  static TextStyle label({
    Color color = AppColors.secondaryText,
    double letterSpacing = 1.0,
  }) {
    return GoogleFonts.inter(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Small Caption · Inter 500 · 11/14
  static TextStyle caption({Color color = AppColors.mutedText}) {
    return GoogleFonts.inter(
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }
}

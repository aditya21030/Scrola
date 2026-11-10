import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/haptic_service.dart';

class FocusBannerCard extends StatelessWidget {
  final int minutes;
  final VoidCallback? onStartFocus;

  const FocusBannerCard({
    super.key,
    this.minutes = 25,
    this.onStartFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF8542),
              Color(0xFFFF6B24),
              Color(0xFFF05710),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Subtle organic background shapes for depth
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Brainy Mascot peeking from bottom right corner
              Positioned(
                right: -10,
                bottom: -22,
                child: Image.asset(
                  'assets/brainy_mascot.png',
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ),

              // Content Layout
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "FOCUS" Eyebrow
                        Text(
                          'FOCUS',
                          style: AppTypography.label(
                            color: AppColors.textOnAccent.withValues(alpha: 0.8),
                            letterSpacing: 1.5,
                          ).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // "Reset for 25 minutes"
                        Text(
                          'Reset for $minutes\nminutes',
                          style: AppTypography.heading(
                            color: AppColors.textOnAccent,
                          ).copyWith(
                            fontSize: 21,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // "Reels stay blocked until the timer ends."
                        Text(
                          'Reels stay blocked until the\ntimer ends.',
                          style: AppTypography.caption(
                            color: AppColors.textOnAccent.withValues(alpha: 0.75),
                          ).copyWith(
                            fontSize: 12,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // "Start focus" Pill Button
                    GestureDetector(
                      onTap: () {
                        HapticService.medium();
                        onStartFocus?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.textOnAccent,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'Start focus',
                          style: AppTypography.body(
                            color: AppColors.primaryText,
                          ).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

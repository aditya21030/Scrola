import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/haptic_service.dart';

class HomeHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final bool isTracking;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onTrackingTap;

  const HomeHeader({
    super.key,
    this.greeting = 'Good evening',
    this.userName = 'Alex',
    this.isTracking = true,
    this.onNotificationTap,
    this.onTrackingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting & User Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: AppTypography.caption(
                    color: AppColors.secondaryText,
                  ).copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: AppTypography.title(
                    color: AppColors.primaryText,
                  ).copyWith(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          // "Tracking on" Status Pill
          GestureDetector(
            onTap: () {
              HapticService.subtle();
              onTrackingTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.successBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    isTracking ? 'Tracking on' : 'Paused',
                    style: AppTypography.label(
                      color: AppColors.success,
                      letterSpacing: 0.2,
                    ).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Notification Bell Button
          GestureDetector(
            onTap: () {
              HapticService.light();
              onNotificationTap?.call();
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primaryText,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/haptic_service.dart';

class HomeHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final bool isTracking;
  final bool permissionsReady;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onTrackingTap;

  const HomeHeader({
    super.key,
    this.greeting = 'Good evening',
    this.userName = 'Alex',
    this.isTracking = false,
    this.permissionsReady = true,
    this.onNotificationTap,
    this.onTrackingTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String statusLabel;
    if (!permissionsReady) {
      statusColor = AppColors.warning;
      statusLabel = 'Setup needed';
    } else if (!isTracking) {
      statusColor = AppColors.secondaryText;
      statusLabel = 'Scrola off';
    } else {
      statusColor = AppColors.success;
      statusLabel = 'Scrola on';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: AppTypography.caption(
                    color: AppColors.warmText,
                  ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    color: AppColors.primaryText,
                  ).copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 28 / 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticService.subtle();
              onTrackingTap?.call();
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusLabel,
                    style: AppTypography.caption(color: statusColor).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              HapticService.light();
              onNotificationTap?.call();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
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

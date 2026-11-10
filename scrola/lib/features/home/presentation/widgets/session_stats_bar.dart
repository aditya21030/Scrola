import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/haptic_service.dart';

class SessionStatsBar extends StatelessWidget {
  final int sessionReels;
  final String screenTime;
  final String resetTime;

  const SessionStatsBar({
    super.key,
    this.sessionReels = 6,
    this.screenTime = '38m',
    this.resetTime = '5h 20m',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStatItem(
              value: '$sessionReels',
              label: 'This session',
            ),
            _buildDivider(),
            _buildStatItem(
              value: screenTime,
              label: 'Screen time',
            ),
            _buildDivider(),
            _buildStatItem(
              value: resetTime,
              label: 'Resets in',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => HapticService.subtle(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.heading(
                color: AppColors.primaryText,
              ).copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.caption(
                color: AppColors.secondaryText,
              ).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 34,
      color: AppColors.border.withValues(alpha: 0.6),
    );
  }
}

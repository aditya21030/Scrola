import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_card.dart';

class SessionStatsBar extends StatelessWidget {
  final int sessionReels;
  final String screenTime;
  final String resetTime;
  final VoidCallback? onTap;

  const SessionStatsBar({
    super.key,
    required this.sessionReels,
    required this.screenTime,
    required this.resetTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScrolaCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      onTap: onTap != null
          ? () {
              HapticService.subtle();
              onTap!();
            }
          : null,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCol(
                value: '$sessionReels',
                label: 'This session',
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.borderSubtle,
            ),
            Expanded(
              child: _StatCol(
                value: screenTime,
                label: 'Screen time',
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.borderSubtle,
            ),
            Expanded(
              child: _StatCol(
                value: resetTime,
                label: 'Resets in',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String value;
  final String label;

  const _StatCol({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTypography.numeric(
              color: AppColors.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption(color: AppColors.secondaryText)
              .copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

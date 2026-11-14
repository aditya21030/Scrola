import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';

class BattleInvitationModal extends StatelessWidget {
  final String challengerName;
  final String rule;
  final String length;
  final String prize;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const BattleInvitationModal({
    super.key,
    this.challengerName = 'Leo',
    this.rule = 'Fewest reels',
    this.length = '1 day',
    this.prize = '+100 XP',
    this.onAccept,
    this.onDecline,
  });

  static Future<void> show(
    BuildContext context, {
    String challengerName = 'Leo',
    VoidCallback? onAccept,
    VoidCallback? onDecline,
  }) {
    HapticService.medium();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BattleInvitationModal(
        challengerName: challengerName,
        onAccept: onAccept,
        onDecline: onDecline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF171717),
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A2A), width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grabber
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 20),
          // Challenger mascot avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1E1E),
              border: Border.all(color: AppColors.primaryAccent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withValues(alpha: 0.35),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: BrainyMascot(
                mood: BrainyMood.happy,
                skin: BrainySkin.classic,
                size: 76,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'BATTLE INVITE',
            style: AppTypography.label(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            '$challengerName challenged you',
            style: AppTypography.title().copyWith(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(
            'See who scrolls less in the next 24 hours.',
            textAlign: TextAlign.center,
            style: AppTypography.body(color: AppColors.secondaryText)
                .copyWith(fontSize: 14.5),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Text(
                          rule,
                          style: AppTypography.subheading()
                              .copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rule',
                          style: AppTypography.caption(
                              color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 36, color: const Color(0xFF2A2A2A)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Text(
                          length,
                          style: AppTypography.subheading()
                              .copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Length',
                          style: AppTypography.caption(
                              color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 36, color: const Color(0xFF2A2A2A)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Text(
                          prize,
                          style: AppTypography.subheading(
                            color: AppColors.primaryAccent,
                          ).copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Prize',
                          style: AppTypography.caption(
                              color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ScrolaPrimaryButton(
            label: 'Accept battle',
            onTap: () {
              HapticService.medium();
              Navigator.of(context).pop();
              onAccept?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Battle with $challengerName started! ⚔️'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  HapticService.subtle();
                  Navigator.of(context).pop();
                  onDecline?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Decline',
                    style: AppTypography.caption(color: AppColors.secondaryText)
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  HapticService.subtle();
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Decide later',
                    style: AppTypography.caption(color: AppColors.secondaryText)
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

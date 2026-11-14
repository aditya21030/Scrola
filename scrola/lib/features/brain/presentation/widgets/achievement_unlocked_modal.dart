import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';

class AchievementUnlockedModal extends StatelessWidget {
  final String title;
  final String description;
  final int xpReward;
  final VoidCallback? onDismiss;

  const AchievementUnlockedModal({
    super.key,
    this.title = '7 Day Streak',
    this.description = 'You stayed under your limit for a full week.',
    this.xpReward = 50,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    String title = '7 Day Streak',
    String description = 'You stayed under your limit for a full week.',
    int xpReward = 50,
  }) {
    HapticService.medium();
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => AchievementUnlockedModal(
        title: title,
        description: description,
        xpReward: xpReward,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACHIEVEMENT UNLOCKED',
                  style: AppTypography.label(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.title().copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(color: AppColors.secondaryText)
                      .copyWith(fontSize: 14.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.primaryAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+$xpReward XP',
                        style: AppTypography.numeric(
                          color: AppColors.primaryAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ScrolaPrimaryButton(
                  label: 'Awesome',
                  onTap: () {
                    HapticService.medium();
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  },
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    HapticService.light();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Achievement "$title" copied!')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Share',
                      style: AppTypography.caption(
                        color: AppColors.primaryAccent,
                      ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Badge floating on top
          Positioned(
            top: -64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFFD76A), AppColors.primaryAccent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAccent.withValues(alpha: 0.5),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 60,
                      color: Color(0xFF101010),
                    ),
                  ),
                ),
                const Positioned(
                  left: -20,
                  top: -10,
                  child: BrainyMascot(
                    mood: BrainyMood.celebrating,
                    skin: BrainySkin.classic,
                    size: 60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

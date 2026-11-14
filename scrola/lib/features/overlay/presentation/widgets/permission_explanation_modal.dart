import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';

class PermissionExplanationModal extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const PermissionExplanationModal({super.key, required this.onOpenSettings});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onOpenSettings,
  }) {
    HapticService.medium();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          PermissionExplanationModal(onOpenSettings: onOpenSettings),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const BrainyMascot(
                    mood: BrainyMood.sleepy,
                    skin: BrainySkin.classic,
                    size: 72,
                  ),
                  Positioned(
                    right: -2,
                    bottom: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF171717),
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.priority_high_rounded,
                        size: 14,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turn on Accessibility',
                      style: AppTypography.title().copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Without it, Scrola cannot detect swipes or count your reels.",
                      style: AppTypography.caption(color: AppColors.secondaryText)
                          .copyWith(fontSize: 13.5, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scrola sees',
                          style: AppTypography.subheading(
                            color: AppColors.success,
                          ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _Bullet(
                          color: AppColors.success,
                          icon: Icons.check,
                          text: 'Which reel app is active',
                        ),
                        const SizedBox(height: 8),
                        _Bullet(
                          color: AppColors.success,
                          icon: Icons.check,
                          text: 'A swipe to the next reel',
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 100,
                  color: const Color(0xFF2A2A2A),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Never reads',
                          style: AppTypography.subheading(
                            color: AppColors.secondaryText,
                          ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _Bullet(
                          color: const Color(0xFF505050),
                          icon: Icons.close,
                          text: 'Direct messages',
                        ),
                        const SizedBox(height: 8),
                        _Bullet(
                          color: const Color(0xFF505050),
                          icon: Icons.close,
                          text: 'Passwords or media',
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
            label: 'Open Settings',
            onTap: () {
              HapticService.medium();
              Navigator.of(context).pop();
              onOpenSettings();
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: () {
                HapticService.subtle();
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Not now',
                  style: AppTypography.caption(color: AppColors.secondaryText)
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _Bullet({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 10, color: const Color(0xFF101010)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body().copyWith(fontSize: 12.5, height: 1.3),
          ),
        ),
      ],
    );
  }
}

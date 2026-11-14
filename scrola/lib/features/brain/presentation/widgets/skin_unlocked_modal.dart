import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';

class SkinUnlockedModal extends StatelessWidget {
  final BrainySkin skin;
  final int level;
  final VoidCallback onEquip;

  const SkinUnlockedModal({
    super.key,
    required this.skin,
    this.level = 5,
    required this.onEquip,
  });

  static Future<void> show(
    BuildContext context, {
    required BrainySkin skin,
    int level = 5,
    required VoidCallback onEquip,
  }) {
    HapticService.medium();
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => SkinUnlockedModal(
        skin: skin,
        level: level,
        onEquip: onEquip,
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
            padding: const EdgeInsets.fromLTRB(22, 90, 22, 24),
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
                  'NEW SKIN UNLOCKED',
                  style: AppTypography.label(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  skin.name[0].toUpperCase() + skin.name.substring(1),
                  textAlign: TextAlign.center,
                  style: AppTypography.title().copyWith(fontSize: 32),
                ),
                const SizedBox(height: 6),
                Text(
                  'Level $level reward. Added to your wardrobe.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(color: AppColors.secondaryText)
                      .copyWith(fontSize: 14),
                ),
                const SizedBox(height: 18),
                // Recent skins row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SkinPill(skin: BrainySkin.classic, isSelected: false),
                    const SizedBox(width: 10),
                    _SkinPill(skin: BrainySkin.sunset, isSelected: true),
                    const SizedBox(width: 10),
                    _SkinPill(skin: BrainySkin.golden, isSelected: false),
                  ],
                ),
                const SizedBox(height: 24),
                ScrolaPrimaryButton(
                  label: 'Equip now',
                  onTap: () {
                    HapticService.medium();
                    Navigator.of(context).pop();
                    onEquip();
                  },
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    HapticService.subtle();
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Maybe later',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Large skin mascot on top
          Positioned(
            top: -70,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.35),
                    blurRadius: 35,
                  ),
                ],
              ),
              child: BrainyMascot(
                mood: BrainyMood.celebrating,
                skin: skin,
                size: 140,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkinPill extends StatelessWidget {
  final BrainySkin skin;
  final bool isSelected;

  const _SkinPill({required this.skin, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryAccent
              : const Color(0xFF2A2A2A),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Center(
        child: BrainyMascot(
          mood: BrainyMood.happy,
          skin: skin,
          size: 36,
        ),
      ),
    );
  }
}

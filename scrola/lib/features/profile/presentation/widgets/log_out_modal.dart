import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';

class LogOutModal extends StatelessWidget {
  final VoidCallback onConfirmLogout;

  const LogOutModal({super.key, required this.onConfirmLogout});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirmLogout,
  }) {
    HapticService.light();
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => LogOutModal(onConfirmLogout: onConfirmLogout),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 60, 22, 22),
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF2A2A2A)),
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
                  'Log out of Scrola?',
                  textAlign: TextAlign.center,
                  style: AppTypography.title().copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reel counting and the counter pause until you log in again. Your streak and XP stay saved.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(color: AppColors.secondaryText)
                      .copyWith(fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 24),
                ScrolaPrimaryButton(
                  label: 'Stay logged in',
                  onTap: () {
                    HapticService.subtle();
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    HapticService.medium();
                    Navigator.of(context).pop();
                    onConfirmLogout();
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Log out',
                      style: AppTypography.caption(color: AppColors.error)
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: -46,
            child: BrainyMascot(
              mood: BrainyMood.neutral,
              skin: BrainySkin.classic,
              size: 92,
            ),
          ),
        ],
      ),
    );
  }
}

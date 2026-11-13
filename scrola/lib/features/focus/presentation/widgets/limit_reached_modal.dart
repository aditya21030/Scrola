import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import 'emergency_unlock_modal.dart';

class LimitReachedModal extends StatefulWidget {
  const LimitReachedModal({super.key});

  static Future<void> show(BuildContext context) {
    HapticService.error();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LimitReachedModal(),
    );
  }

  @override
  State<LimitReachedModal> createState() => _LimitReachedModalState();
}

class _LimitReachedModalState extends State<LimitReachedModal>
    with SingleTickerProviderStateMixin {
  final TrackingService _tracking = TrackingService();
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = _tracking.totalReelsToday;
    final limit = _tracking.totalLimit;
    final resetsIn = _tracking.resetTimeFormatted;
    final streak = _tracking.streakDays;
    final unlocksLeft = _tracking.emergencyUnlocksLeft;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        border: Border(
          top: BorderSide(
            color: AppColors.error.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top capsule pill matching design
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final glow = _pulseController.value;
                  return Container(
                    width: 250,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color:
                            AppColors.error.withValues(alpha: 0.5 + 0.4 * glow),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.25 * glow),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$today',
                              style: AppTypography.title().copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'watched',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ).copyWith(fontSize: 9),
                            ),
                          ],
                        ),
                        BrainyMascot(
                          mood: BrainyMood.sad,
                          skin: _tracking.equippedSkin,
                          size: 34,
                          animate: false,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '0',
                              style: AppTypography.title().copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.error,
                              ),
                            ),
                            Text(
                              'left',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ).copyWith(fontSize: 9),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Big Sad Brainy Mascot with tears
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.error.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  BrainyMascot(
                    mood: BrainyMood.sad,
                    skin: _tracking.equippedSkin,
                    size: 100,
                    animate: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // "Limit reached" badge chip
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Limit reached',
                  style: AppTypography.caption(
                    color: const Color(0xFFFF7A8A),
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Headline & Subtitle
            Text(
              "That's your limit for today",
              textAlign: TextAlign.center,
              style: AppTypography.title().copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You watched $today of $limit reels. Reels stay locked until midnight.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                color: AppColors.secondaryText,
              ).copyWith(height: 1.35),
            ),
            const SizedBox(height: 14),

            // Badges: Resets in & Streak in Wrap
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.elevatedSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Resets in $resetsIn',
                      style: AppTypography.caption(
                        color: AppColors.primaryText,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primaryAccent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '$streak day streak',
                      style: AppTypography.caption(
                        color: AppColors.primaryAccent,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Primary Button: Back to Scrola
            ScrolaPrimaryButton(
              label: 'Back to Scrola',
              useMediumHaptic: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 10),

            // Secondary row: Go home & Unlock for 5 minutes in Wrap
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 14,
                runSpacing: 4,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ).copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final unlocked =
                          await EmergencyUnlockModal.show(context);
                      if (unlocked == true && context.mounted) {
                        HapticService.celebratory();
                      }
                    },
                    child: Text(
                      'Unlock for 5 min · $unlocksLeft left',
                      style: AppTypography.caption(
                        color: AppColors.primaryAccent,
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

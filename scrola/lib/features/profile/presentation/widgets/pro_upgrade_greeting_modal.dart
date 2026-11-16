import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';

class ProUpgradeGreetingModal extends StatelessWidget {
  final String planTitle;
  final VoidCallback? onDismiss;

  const ProUpgradeGreetingModal({
    super.key,
    required this.planTitle,
    this.onDismiss,
  });

  static bool _isShowing = false;

  static Future<void> show(
    BuildContext context, {
    required String planTitle,
    VoidCallback? onDismiss,
  }) async {
    if (_isShowing || !context.mounted) return;
    _isShowing = true;
    await HapticService.celebratory();
    if (!context.mounted) {
      _isShowing = false;
      return;
    }
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.82),
        builder: (_) => ProUpgradeGreetingModal(
          planTitle: planTitle,
          onDismiss: onDismiss,
        ),
      );
    } catch (e) {
      debugPrint('ProUpgradeGreetingModal.show error: $e');
    } finally {
      _isShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 78, 22, 22),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withValues(alpha: 0.22),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pro Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primaryAccent.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: AppColors.primaryAccent,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PRO ACTIVE',
                          style: AppTypography.caption(color: AppColors.primaryAccent).copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Greeting Title
                Text(
                  'Welcome to Scrola Pro!',
                  textAlign: TextAlign.center,
                  style: AppTypography.title().copyWith(
                    fontSize: 24,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$planTitle active. Brainy has unlocked its full capabilities for your screen time journey.',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(color: AppColors.secondaryText)
                      .copyWith(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 18),

                // Unlocked Features Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                    ),
                  ),
                  child: Column(
                    children: const [
                      _ProFeatureRow(
                        icon: Icons.all_inclusive_rounded,
                        title: 'Unlimited Floating Notch Counter',
                        subtitle: 'No session cuts or daily limits',
                      ),
                      Divider(color: AppColors.borderSubtle, height: 16),
                      _ProFeatureRow(
                        icon: Icons.palette_rounded,
                        title: 'Golden & Premium Brainy Skins',
                        subtitle: 'All 40+ mascot styles unlocked',
                      ),
                      Divider(color: AppColors.borderSubtle, height: 16),
                      _ProFeatureRow(
                        icon: Icons.shield_rounded,
                        title: 'Streak Shield & Deep Insights',
                        subtitle: 'Protect streaks & export full data',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Action Button
                ScrolaPrimaryButton(
                  label: 'Start Exploring Pro',
                  useMediumHaptic: true,
                  onPressed: () {
                    // Automatically equip golden skin as a welcome gift if desired
                    if (tracking.equippedSkin != BrainySkin.golden) {
                      tracking.equipSkin(BrainySkin.golden);
                    }
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  },
                ),
              ],
            ),
          ),

          // Floating Golden Celebrating Mascot on Top
          Positioned(
            top: -65,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.35),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const BrainyMascot(
                mood: BrainyMood.celebrating,
                skin: BrainySkin.golden,
                size: 130,
                animate: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProFeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProFeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryAccent,
            size: 17,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.subheading().copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: AppTypography.caption(color: AppColors.secondaryText)
                    .copyWith(fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

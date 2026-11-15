import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../screens/subscription_pro_screen.dart';

class NotchProModal extends StatelessWidget {
  const NotchProModal({super.key});

  static Future<void> show(BuildContext context) {
    HapticService.subtle();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotchProModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.secondaryText.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Glowing Brainy Mascot with PRO Crown
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const BrainyMascot(
                  mood: BrainyMood.focused,
                  skin: BrainySkin.golden,
                  size: 78,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Pro Feature Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryAccent.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'PRO FEATURE',
                style: AppTypography.caption(color: AppColors.primaryAccent)
                    .copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Titles
          Text(
            'Floating Notch Counter',
            textAlign: TextAlign.center,
            style: AppTypography.title().copyWith(
              fontSize: 22,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You have used your 1 free trial session. Upgrade to Scrola Pro to enjoy unlimited floating counter across Instagram, YouTube, and all apps.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              color: AppColors.secondaryText,
            ).copyWith(height: 1.35, fontSize: 13.5),
          ),
          const SizedBox(height: 18),

          // Quick plan chips preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSolid,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PlanPreviewItem(
                    label: 'Monthly',
                    price: '₹49',
                    unit: '/ mo',
                    isHighlight: false,
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: AppColors.borderSubtle,
                ),
                Expanded(
                  child: _PlanPreviewItem(
                    label: 'Yearly',
                    price: '₹499',
                    unit: '/ yr',
                    badge: 'POPULAR',
                    isHighlight: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: AppColors.borderSubtle,
                ),
                Expanded(
                  child: _PlanPreviewItem(
                    label: 'Lifetime',
                    price: '₹999',
                    unit: 'once',
                    badge: 'BEST VALUE',
                    isHighlight: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Primary CTA -> Pushes SubscriptionProScreen
          ScrolaPrimaryButton(
            label: 'View Scrola Pro Plans',
            useMediumHaptic: true,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SubscriptionProScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 6),

          // Close button
          ScrolaLinkButton(
            label: 'Continue with standard tracking',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _PlanPreviewItem extends StatelessWidget {
  final String label;
  final String price;
  final String unit;
  final String? badge;
  final bool isHighlight;

  const _PlanPreviewItem({
    required this.label,
    required this.price,
    required this.unit,
    this.badge,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge != null)
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: isHighlight
                  ? AppColors.primaryAccent
                  : AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge!,
              style: AppTypography.caption(
                color: isHighlight ? AppColors.textOnAccent : AppColors.warning,
              ).copyWith(fontSize: 8, fontWeight: FontWeight.w800),
            ),
          )
        else
          const SizedBox(height: 16),
        Text(
          label,
          style: AppTypography.caption(color: AppColors.secondaryText)
              .copyWith(fontSize: 11),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              price,
              style: AppTypography.numeric(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isHighlight ? AppColors.primaryAccent : AppColors.primaryText,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: AppTypography.caption(color: AppColors.mutedText)
                  .copyWith(fontSize: 9.5),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

enum ProPlanTier {
  monthly(
    id: 'monthly',
    title: 'Monthly',
    price: '₹49',
    period: '/ mo',
    subtitle: 'Billed monthly · Cancel anytime',
    badge: null,
  ),
  yearly(
    id: 'yearly',
    title: 'Yearly',
    price: '₹499',
    period: '/ yr',
    subtitle: '₹41.5 / mo · Billed annually',
    badge: 'POPULAR · SAVE 15%',
  ),
  lifetime(
    id: 'lifetime',
    title: 'Lifetime',
    price: '₹999',
    period: 'once',
    subtitle: 'Pay once · Keep forever',
    badge: 'BEST VALUE',
  );

  final String id;
  final String title;
  final String price;
  final String period;
  final String subtitle;
  final String? badge;

  const ProPlanTier({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    required this.subtitle,
    this.badge,
  });
}

class SubscriptionProScreen extends StatefulWidget {
  const SubscriptionProScreen({super.key});

  @override
  State<SubscriptionProScreen> createState() => _SubscriptionProScreenState();
}

class _SubscriptionProScreenState extends State<SubscriptionProScreen> {
  ProPlanTier _selectedTier = ProPlanTier.yearly;
  bool _isProcessing = false;

  Future<void> _handleContinue(TrackingService tracking) async {
    setState(() => _isProcessing = true);
    HapticService.medium();

    try {
      await tracking.updateProSubscription(
        subscribed: true,
        plan: _selectedTier.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceSolid,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Welcome to Scrola Pro! (${_selectedTier.title} plan active)',
                  style: AppTypography.caption(color: AppColors.primaryText)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Return back to previous screen
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();

    return ListenableBuilder(
      listenable: tracking,
      builder: (context, _) {
        final bool isAlreadyPro = tracking.isProSubscribed;
        final String currentPlan = tracking.proPlan;

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Scrola Pro',
                    trailing: GestureDetector(
                      onTap: () {
                        HapticService.light();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Purchases restored. You are on the active plan.',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Restore',
                        style: AppTypography.caption(
                                color: AppColors.secondaryText)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primaryAccent
                                          .withValues(alpha: 0.28),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: const BrainyMascot(
                                  mood: BrainyMood.celebrating,
                                  skin: BrainySkin.golden,
                                  size: 76,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAlreadyPro
                                          ? 'You are a Pro Member'
                                          : 'Unlock the full power',
                                      style: AppTypography.title()
                                          .copyWith(fontSize: 21),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAlreadyPro
                                          ? 'Unlimited floating notch counter, advanced analytics, and custom schedules are active.'
                                          : 'Unlimited floating notch counter, deep analytics, streak protection, and 40+ mascot skins.',
                                      style: AppTypography.caption(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Plan Selection Cards (3 Tiers)
                          ...ProPlanTier.values.map((tier) {
                            final isSelected = _selectedTier == tier;
                            final isCurrentActive =
                                isAlreadyPro && currentPlan == tier.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ScrolaSelectableCard(
                                isSelected: isSelected,
                                checkPosition: ScrolaCheckPosition.topRight,
                                onTap: () {
                                  HapticService.subtle();
                                  setState(() => _selectedTier = tier);
                                },
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              Text(
                                                tier.title,
                                                style: AppTypography.subheading()
                                                    .copyWith(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              if (tier.badge != null) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 7,
                                                    vertical: 2.5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.primaryAccent,
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    tier.badge!,
                                                    style: AppTypography.caption(
                                                      color: AppColors
                                                          .textOnAccent,
                                                    ).copyWith(
                                                      fontSize: 9.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (isCurrentActive) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 7,
                                                    vertical: 2.5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.success
                                                        .withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: AppColors.success,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'ACTIVE',
                                                    style: AppTypography.caption(
                                                      color: AppColors.success,
                                                    ).copyWith(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            tier.subtitle,
                                            style: AppTypography.caption(
                                              color: AppColors.secondaryText,
                                            ).copyWith(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          tier.price,
                                          style: AppTypography.numeric(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected
                                                ? AppColors.primaryAccent
                                                : AppColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          tier.period,
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                          ).copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 28),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),

                          // Comparison Table Card
                          ScrolaCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                        flex: 5, child: SizedBox()),
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Text(
                                          'Free',
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                          ).copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Text(
                                          'Pro',
                                          style: AppTypography.caption(
                                            color: AppColors.primaryAccent,
                                          ).copyWith(fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: AppColors.borderSubtle,
                                  height: 20,
                                ),
                                const _CompareRow(
                                  feature: 'Reel tracking & limits',
                                  freeVal: '✓',
                                  proVal: '✓',
                                ),
                                const _CompareRow(
                                  feature: 'Smart blocking modal',
                                  freeVal: '✓',
                                  proVal: '✓',
                                ),
                                const _CompareRow(
                                  feature: 'Floating notch counter',
                                  freeVal: '1 free session',
                                  proVal: 'Unlimited',
                                  highlightPro: true,
                                ),
                                const _CompareRow(
                                  feature: 'Night & Work schedules',
                                  freeVal: '1 schedule',
                                  proVal: 'Unlimited',
                                ),
                                const _CompareRow(
                                  feature: 'Monthly trends & CSV',
                                  freeVal: '–',
                                  proVal: '✓',
                                ),
                                const _CompareRow(
                                  feature: 'Cloud backup & sync',
                                  freeVal: '–',
                                  proVal: '✓',
                                ),
                                const _CompareRow(
                                  feature: 'Streak freeze protection',
                                  freeVal: '–',
                                  proVal: '1 / month',
                                ),
                                const _CompareRow(
                                  feature: 'Brainy skins & moods',
                                  freeVal: '6 skins',
                                  proVal: '40+ skins',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ScrolaPrimaryButton(
                    label: _isProcessing
                        ? 'Activating...'
                        : isAlreadyPro
                            ? 'Switch to ${_selectedTier.title} (${_selectedTier.price})'
                            : 'Continue with ${_selectedTier.title} (${_selectedTier.price})',
                    onPressed: _isProcessing
                        ? null
                        : () => _handleContinue(tracking),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Cancel any time in Google Play. Your data is always private and never sold.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption(color: AppColors.mutedText)
                          .copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String feature;
  final String freeVal;
  final String proVal;
  final bool highlightPro;

  const _CompareRow({
    required this.feature,
    required this.freeVal,
    required this.proVal,
    this.highlightPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.5),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              feature,
              style: AppTypography.caption(color: AppColors.primaryText)
                  .copyWith(fontSize: 12.5),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                freeVal,
                style: AppTypography.caption(color: AppColors.secondaryText)
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 11.5),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                proVal,
                style: AppTypography.caption(
                  color: highlightPro
                      ? AppColors.primaryAccent
                      : AppColors.primaryAccent.withValues(alpha: 0.9),
                ).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

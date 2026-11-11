import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class SubscriptionProScreen extends StatefulWidget {
  const SubscriptionProScreen({super.key});

  @override
  State<SubscriptionProScreen> createState() => _SubscriptionProScreenState();
}

class _SubscriptionProScreenState extends State<SubscriptionProScreen> {
  bool _yearly = true;

  @override
  Widget build(BuildContext context) {
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
                        content: Text('Checked Google Play for previous purchases.'),
                      ),
                    );
                  },
                  child: Text(
                    'Restore',
                    style: AppTypography.caption(color: AppColors.secondaryText)
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
                                  AppColors.warning.withValues(alpha: 0.25),
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
                                  'The full picture',
                                  style: AppTypography.title()
                                      .copyWith(fontSize: 22),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Everything in Free, plus deeper reports and more ways to customise.',
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
                      ScrolaCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(flex: 5, child: SizedBox()),
                                Expanded(
                                  flex: 2,
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
                                  flex: 2,
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
                                color: AppColors.borderSubtle, height: 20),
                            const _CompareRow(
                              feature: 'Reel tracking & limits',
                              freeVal: '✓',
                              proVal: '✓',
                            ),
                            const _CompareRow(
                              feature: 'Floating counter',
                              freeVal: '✓',
                              proVal: '✓',
                            ),
                            const _CompareRow(
                              feature: 'Weekly report',
                              freeVal: '✓',
                              proVal: '✓',
                            ),
                            const _CompareRow(
                              feature: 'Monthly trends',
                              freeVal: '–',
                              proVal: '✓',
                            ),
                            const _CompareRow(
                              feature: 'Block schedules',
                              freeVal: '1',
                              proVal: 'Unlimited',
                            ),
                            const _CompareRow(
                              feature: 'Extra Brainy skins',
                              freeVal: '–',
                              proVal: '✓',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ScrolaSelectableCard(
                                isSelected: !_yearly,
                                checkPosition: ScrolaCheckPosition.topRight,
                                onTap: () {
                                  HapticService.subtle();
                                  setState(() => _yearly = false);
                                },
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Monthly',
                                      style: AppTypography.subheading()
                                          .copyWith(fontSize: 15),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$3.99',
                                      style: AppTypography.numeric(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '/ mo',
                                      style: AppTypography.caption(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ScrolaSelectableCard(
                                isSelected: _yearly,
                                checkPosition: ScrolaCheckPosition.topRight,
                                onTap: () {
                                  HapticService.subtle();
                                  setState(() => _yearly = true);
                                },
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Yearly',
                                          style: AppTypography.subheading()
                                              .copyWith(fontSize: 15),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryAccent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Save 48%',
                                            style: AppTypography.caption(
                                              color: AppColors.textOnAccent,
                                            ).copyWith(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$24.99',
                                      style: AppTypography.numeric(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                  ),
                                  Text(
                                    '/ yr',
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ScrolaPrimaryButton(
                label: _yearly
                    ? 'Continue with Yearly'
                    : 'Continue with Monthly',
                onPressed: () {
                  HapticService.celebratory();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Play Billing is ready when published to Google Play.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Cancel any time in Google Play. Your data is never sold.',
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
  }
}

class _CompareRow extends StatelessWidget {
  final String feature;
  final String freeVal;
  final String proVal;

  const _CompareRow({
    required this.feature,
    required this.freeVal,
    required this.proVal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              feature,
              style: AppTypography.caption(color: AppColors.primaryText)
                  .copyWith(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                freeVal,
                style: AppTypography.caption(color: AppColors.secondaryText)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                proVal,
                style: AppTypography.caption(color: AppColors.primaryAccent)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

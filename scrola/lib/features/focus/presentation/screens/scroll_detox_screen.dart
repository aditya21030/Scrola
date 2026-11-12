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

class ScrollDetoxScreen extends StatefulWidget {
  const ScrollDetoxScreen({super.key});

  @override
  State<ScrollDetoxScreen> createState() => _ScrollDetoxScreenState();
}

class _ScrollDetoxScreenState extends State<ScrollDetoxScreen> {
  final TrackingService _tracking = TrackingService();
  late int _days;

  @override
  void initState() {
    super.initState();
    _days = _tracking.detoxDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final isActive = _tracking.isDetoxActive;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScrolaAppBar(title: 'Scroll Detox'),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          BrainyMascot(
                            mood: BrainyMood.sleepy,
                            skin: _tracking.equippedSkin,
                            size: 132,
                          ),
                          Text(
                            'Detox',
                            style: AppTypography.title().copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'Reels are blocked completely for the days you pick. Your streak is protected.',
                              textAlign: TextAlign.center,
                              style: AppTypography.body(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              for (int i = 0; i < 3; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      const durations = [1, 3, 7];
                                      final d = durations[i];
                                      final selected = _days == d;
                                      return ScrolaSelectableCard(
                                        isSelected: selected,
                                        checkPosition:
                                            ScrolaCheckPosition.topRight,
                                        checkBadgeSize: 16,
                                        onTap: () {
                                          HapticService.subtle();
                                          setState(() => _days = d);
                                        },
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 8,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$d',
                                              style: AppTypography.numeric(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w800,
                                                color: selected
                                                    ? AppColors.primaryAccent
                                                    : AppColors.primaryText,
                                              ),
                                            ),
                                            Text(
                                              d == 1 ? 'day' : 'days',
                                              style: AppTypography.caption(
                                                color:
                                                    AppColors.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 18),
                          ScrolaCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: const [
                                _DetoxPoint(
                                  icon: Icons.shield_outlined,
                                  text: 'Reels blocked in your chosen apps',
                                ),
                                Divider(color: AppColors.borderSubtle, height: 22),
                                _DetoxPoint(
                                  icon: Icons.local_fire_department_rounded,
                                  text: 'Counter pauses, streak is protected',
                                ),
                                Divider(color: AppColors.borderSubtle, height: 22),
                                _DetoxPoint(
                                  icon: Icons.nights_stay_outlined,
                                  text: 'Brainy rests with you',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          ScrolaCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            borderColor:
                                AppColors.primaryAccent.withValues(alpha: 0.35),
                            child: Center(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Complete $_days ${_days == 1 ? 'day' : 'days'} for ',
                                      style: AppTypography.caption(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '+200 XP ',
                                      style: AppTypography.caption(
                                        color: AppColors.primaryAccent,
                                      ).copyWith(fontWeight: FontWeight.w800),
                                    ),
                                    TextSpan(
                                      text: 'and Detox Day badge',
                                      style: AppTypography.caption(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ScrolaPrimaryButton(
                    label: isActive
                        ? 'End detox early'
                        : 'Start $_days day detox',
                    onPressed: () async {
                      if (isActive) {
                        HapticService.warning();
                        await _tracking.updateBlockingConfig(detox: false);
                      } else {
                        HapticService.celebratory();
                        await _tracking.updateBlockingConfig(
                          detox: true,
                          detoxDays: _days,
                        );
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetoxPoint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetoxPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryAccent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body(color: AppColors.primaryText)
                .copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

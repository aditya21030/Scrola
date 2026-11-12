import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class ReelLimitSetupScreen extends StatefulWidget {
  const ReelLimitSetupScreen({super.key});

  @override
  State<ReelLimitSetupScreen> createState() => _ReelLimitSetupScreenState();
}

class _ReelLimitSetupScreenState extends State<ReelLimitSetupScreen> {
  final TrackingService _tracking = TrackingService();
  late int _limit;

  @override
  void initState() {
    super.initState();
    _limit = _tracking.totalLimit;
  }

  void _step(int delta) {
    final next = (_limit + delta).clamp(5, 200);
    if (next != _limit) {
      HapticService.subtle();
      setState(() => _limit = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_limit * 1.35).round();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: 'Daily limit'),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Text(
                      'REELS PER DAY',
                      style: AppTypography.label(color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CircleStepBtn(
                          icon: Icons.remove_rounded,
                          onTap: () => _step(-5),
                        ),
                        SizedBox(
                          width: 140,
                          child: Center(
                            child: Text(
                              '$_limit',
                              style: AppTypography.heroDisplay(),
                            ),
                          ),
                        ),
                        _CircleStepBtn(
                          icon: Icons.add_rounded,
                          onTap: () => _step(5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'about $minutes min a day',
                      style: AppTypography.body(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [20, 30, 40, 60].map((preset) {
                  final selected = _limit == preset;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          HapticService.subtle();
                          setState(() => _limit = preset);
                        },
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryAccent
                                : AppColors.surfaceSolid,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryAccent
                                  : AppColors.borderSubtle,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$preset',
                              style: AppTypography.numeric(
                                color: selected
                                    ? AppColors.textOnAccent
                                    : AppColors.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ScrolaCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.trending_down_rounded,
                        color: AppColors.primaryAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lower it gradually',
                            style: AppTypography.subheading()
                                .copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Drop the limit by 5 reels each week.',
                            style: AppTypography.caption(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ScrolaPrimaryButton(
                label: 'Save limit',
                useMediumHaptic: true,
                onPressed: () async {
                  await _tracking.updateLimits(total: _limit);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleStepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleStepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceSolid,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, color: AppColors.primaryText, size: 24),
      ),
    );
  }
}

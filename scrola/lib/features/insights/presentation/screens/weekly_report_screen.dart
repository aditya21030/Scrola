import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScrolaAppBar(
                title: 'Weekly report',
                trailing: GestureDetector(
                  onTap: () {
                    HapticService.light();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Weekly summary image copied to clipboard!'),
                      ),
                    );
                  },
                  child: Text(
                    'Share',
                    style: AppTypography.subheading(color: AppColors.primaryAccent)
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const BrainyMascot(
                    mood: BrainyMood.happy,
                    skin: BrainySkin.classic,
                    size: 84,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THIS WEEK',
                          style: AppTypography.label(
                              color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '233 reels. 12% fewer.',
                          style: AppTypography.title().copyWith(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ScrolaCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Daily breakdown',
                      style: AppTypography.subheading(color: AppColors.secondaryText)
                          .copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          _BarCol(label: 'M', heightRatio: 0.85, isOver: true),
                          _BarCol(label: 'T', heightRatio: 0.62, isOver: false),
                          _BarCol(label: 'W', heightRatio: 0.50, isOver: false),
                          _BarCol(label: 'T', heightRatio: 0.72, isOver: true),
                          _BarCol(label: 'F', heightRatio: 0.48, isOver: false),
                          _BarCol(label: 'S', heightRatio: 0.38, isOver: false),
                          _BarCol(label: 'S', heightRatio: 0.05, isOver: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ScrolaCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _StatRow(
                      label: 'Best day',
                      value: 'Saturday · 24',
                      valueColor: AppColors.success,
                    ),
                    const Divider(color: AppColors.borderSubtle, height: 1),
                    _StatRow(
                      label: 'Over the limit',
                      value: '2 days',
                      valueColor: AppColors.warning,
                    ),
                    const Divider(color: AppColors.borderSubtle, height: 1),
                    _StatRow(
                      label: 'Longest streak',
                      value: '7 days',
                      valueColor: AppColors.primaryAccent,
                    ),
                    const Divider(color: AppColors.borderSubtle, height: 1),
                    _StatRow(
                      label: 'XP earned',
                      value: '+340',
                      valueColor: AppColors.primaryAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ScrolaCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.primaryAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Brainy says',
                          style: AppTypography.subheading().copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mondays and Thursdays are your heavy days. Try a focus session on those two to stay in the green.',
                      style: AppTypography.body(color: AppColors.secondaryText)
                          .copyWith(fontSize: 14, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ScrolaPrimaryButton(
                label: 'Share report',
                onTap: () {
                  HapticService.medium();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Weekly card shared successfully!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarCol extends StatelessWidget {
  final String label;
  final double heightRatio;
  final bool isOver;

  const _BarCol({
    required this.label,
    required this.heightRatio,
    required this.isOver,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 24,
            height: 90 * heightRatio,
            decoration: BoxDecoration(
              color: isOver ? AppColors.warning : AppColors.primaryAccent,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.caption(color: AppColors.secondaryText)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body().copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: AppTypography.body(color: valueColor)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

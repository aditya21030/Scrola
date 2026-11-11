import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';

class StreakCalendarScreen extends StatelessWidget {
  const StreakCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: tracking,
        builder: (context, _) {
          final streak = tracking.streakDays;
          final best = math.max(14, streak);
          final now = DateTime.now();
          final todayDay = now.day;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScrolaAppBar(title: 'Streak'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryAccent.withValues(alpha: 0.25),
                              AppColors.surfaceSolid,
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primaryAccent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: AppColors.primaryAccent,
                              size: 28,
                            ),
                            Text(
                              '$streak',
                              style: AppTypography.numeric(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$streak day streak',
                            style: AppTypography.title().copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Best: $best days',
                            style: AppTypography.caption(
                              color: AppColors.secondaryText,
                            ).copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ScrolaCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'November 2026',
                          style: AppTypography.heading().copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: weekdays
                              .map(
                                (d) => Expanded(
                                  child: Center(
                                    child: Text(
                                      d,
                                      style: AppTypography.caption(
                                        color: AppColors.secondaryText,
                                      ).copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 30,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 6,
                          ),
                          itemBuilder: (context, index) {
                            final day = index + 1;
                            final isStreakDay =
                                day <= todayDay && day > todayDay - streak;
                            final isOverDay = day == 2;
                            final isUnderDay = day < todayDay &&
                                !isStreakDay &&
                                !isOverDay;
                            final isToday = day == todayDay;

                            Color bg = Colors.transparent;
                            Color fg = AppColors.mutedText;
                            BoxBorder? border;

                            if (isStreakDay) {
                              bg = AppColors.primaryAccent;
                              fg = AppColors.textOnAccent;
                            } else if (isUnderDay) {
                              bg = AppColors.successBackground;
                              fg = AppColors.success;
                            } else if (isOverDay) {
                              bg = AppColors.errorBackground;
                              fg = AppColors.error;
                            }
                            if (isToday && !isStreakDay) {
                              border = Border.all(
                                color: AppColors.primaryAccent,
                                width: 1.5,
                              );
                              fg = AppColors.primaryText;
                            }

                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bg,
                                border: border,
                              ),
                              child: Center(
                                child: Text(
                                  '$day',
                                  style: AppTypography.numeric(
                                    color: fg,
                                    fontSize: 13,
                                    fontWeight: isStreakDay || isToday
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            _LegendDot(
                                color: AppColors.primaryAccent, label: 'Streak'),
                            _LegendDot(
                                color: AppColors.success, label: 'Under limit'),
                            _LegendDot(
                                color: AppColors.error, label: 'Over limit'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ScrolaCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryAccent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            color: AppColors.primaryAccent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next milestone: 14 days',
                                style: AppTypography.subheading()
                                    .copyWith(fontSize: 15),
                              ),
                              Text(
                                '${math.max(0, 14 - streak)} days to go',
                                style: AppTypography.caption(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+100 XP',
                            style: AppTypography.caption(
                              color: AppColors.primaryAccent,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption(color: AppColors.secondaryText),
        ),
      ],
    );
  }
}

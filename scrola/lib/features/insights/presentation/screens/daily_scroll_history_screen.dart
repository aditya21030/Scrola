import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import 'live_tracking_screen.dart';
import 'platform_breakdown_screen.dart';
import 'platform_limits_screen.dart';
import 'reel_limit_setup_screen.dart';
import 'tracking_status_screen.dart';

class DailyScrollHistoryScreen extends StatelessWidget {
  final bool showBack;

  const DailyScrollHistoryScreen({
    super.key,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: tracking,
        builder: (context, _) {
          final today = tracking.totalReelsToday;
          final limit = math.max(1, tracking.totalLimit);
          final bars = [
            _DayBar('M', (limit * 0.72).round()),
            _DayBar('T', (limit * 0.65).round()),
            _DayBar('W', (limit * 0.85).round()),
            _DayBar('T', limit + 4),
            _DayBar('F', (limit * 0.78).round()),
            _DayBar('S', (limit * 0.70).round()),
            _DayBar('S', today),
          ];
          final avg = (bars.fold<int>(0, (s, b) => s + b.count) / 7).round();
          final maxBar = math.max(
            limit + 8,
            bars.map((b) => b.count).reduce(math.max),
          );

          final logEntries = [
            _LogEntry('Today', 'Instagram, YouTube', today, limit),
            _LogEntry('Yesterday', 'Instagram, Facebook', (limit * 0.72).round(),
                limit),
            _LogEntry('Thursday', 'Instagram, YouTube', limit + 4, limit),
            _LogEntry('Wednesday', 'YouTube, Snapchat', (limit * 0.65).round(),
                limit),
          ];

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                showBack ? 28 : 112,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBack)
                    const ScrolaAppBar(title: 'History')
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Insights',
                            style: AppTypography.title(
                              color: AppColors.primaryText,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticService.subtle();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PlatformBreakdownScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSolid,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                ),
                              ),
                              child: Text(
                                'Platforms',
                                style: AppTypography.caption(
                                  color: AppColors.primaryAccent,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAILY AVERAGE',
                            style: AppTypography.label(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$avg',
                                style: AppTypography.numeric(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'reels',
                                style: AppTypography.subheading(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '12% less than last week',
                          style: AppTypography.caption(
                            color: AppColors.success,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ScrolaCard(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'This week',
                              style: AppTypography.subheading(),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticService.subtle();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ReelLimitSetupScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Limit $limit',
                                style: AppTypography.caption(
                                  color: AppColors.primaryAccent,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 148,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(bars.length, (i) {
                              final bar = bars[i];
                              final hFrac =
                                  (bar.count / maxBar).clamp(0.08, 1.0);
                              final over = bar.count > limit;
                              final isToday = i == bars.length - 1;
                              return Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${bar.count}',
                                      style: AppTypography.numeric(
                                        color: isToday
                                            ? AppColors.primaryAccent
                                            : AppColors.secondaryText,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: FractionallySizedBox(
                                          heightFactor: hFrac,
                                          child: Container(
                                            width: 18,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              color: over
                                                  ? AppColors.error
                                                  : isToday
                                                      ? AppColors.primaryAccent
                                                      : AppColors.primaryAccent
                                                          .withValues(
                                                              alpha: 0.45),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      bar.label,
                                      style: AppTypography.caption(
                                        color: isToday
                                            ? AppColors.primaryText
                                            : AppColors.secondaryText,
                                      ).copyWith(
                                        fontWeight: isToday
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickActionChip(
                        label: 'Platforms',
                        icon: Icons.pie_chart_outline_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PlatformBreakdownScreen(),
                          ),
                        ),
                      ),
                      _QuickActionChip(
                        label: 'Live tracking',
                        icon: Icons.bolt_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LiveTrackingScreen(),
                          ),
                        ),
                      ),
                      _QuickActionChip(
                        label: 'Daily limit',
                        icon: Icons.tune_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ReelLimitSetupScreen(),
                          ),
                        ),
                      ),
                      _QuickActionChip(
                        label: 'Platform limits',
                        icon: Icons.layers_outlined,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PlatformLimitsScreen(),
                          ),
                        ),
                      ),
                      _QuickActionChip(
                        label: 'Tracking status',
                        icon: Icons.verified_user_outlined,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TrackingStatusScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daily log', style: AppTypography.heading()),
                      GestureDetector(
                        onTap: () {
                          HapticService.light();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Weekly CSV report copied to clipboard.'),
                            ),
                          );
                        },
                        child: Text(
                          'Export',
                          style: AppTypography.caption(
                            color: AppColors.primaryAccent,
                          ).copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...logEntries.map((entry) {
                    final over = entry.count > entry.limit;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ScrolaCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.day,
                                    style: AppTypography.subheading()
                                        .copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.platforms,
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${entry.count}',
                                  style: AppTypography.numeric(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  over
                                      ? 'Over by ${entry.count - entry.limit}'
                                      : 'Under limit',
                                  style: AppTypography.caption(
                                    color: over
                                        ? AppColors.error
                                        : AppColors.success,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DayBar {
  final String label;
  final int count;
  const _DayBar(this.label, this.count);
}

class _LogEntry {
  final String day;
  final String platforms;
  final int count;
  final int limit;
  const _LogEntry(this.day, this.platforms, this.count, this.limit);
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.subtle();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSolid,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primaryAccent),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.caption(color: AppColors.primaryText)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../../../shared/widgets/platform_selection_modal.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_segmented_control.dart';
import 'platform_limits_screen.dart';

enum _BreakdownPeriod { today, week, month }

class PlatformBreakdownScreen extends StatefulWidget {
  const PlatformBreakdownScreen({super.key});

  @override
  State<PlatformBreakdownScreen> createState() =>
      _PlatformBreakdownScreenState();
}

class _PlatformBreakdownScreenState extends State<PlatformBreakdownScreen> {
  final TrackingService _tracking = TrackingService();
  _BreakdownPeriod _period = _BreakdownPeriod.today;

  int _periodHistoryTotal(_BreakdownPeriod period) {
    final todayTotal = _tracking.totalReelsToday;
    if (period == _BreakdownPeriod.today) return todayTotal;
    final days = period == _BreakdownPeriod.week ? 7 : 30;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final history = _tracking.dailyHistory;
    int sum = 0;
    for (int i = 0; i < days; i++) {
      final d = todayDate.subtract(Duration(days: i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      sum += i == 0 ? todayTotal : (history[key]?['reels'] ?? 0);
    }
    return sum;
  }

  String _periodSuffix(_BreakdownPeriod period) {
    switch (period) {
      case _BreakdownPeriod.today:
        return 'reels today';
      case _BreakdownPeriod.week:
        return 'reels past 7d';
      case _BreakdownPeriod.month:
        return 'reels past 30d';
    }
  }

  Future<void> _showManageAppsSheet() async {
    await showPlatformSelectionModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final visiblePlatforms = _tracking.visiblePlatforms;
          final items = visiblePlatforms.map((platform) {
            return _PlatformItem(
              platform: platform,
              name: platform.reelsName,
              count: _tracking.reelsForId(platform.id),
              limit: _tracking.limitForId(platform.id),
              color: platform.brandColor,
            );
          }).toList();
          final todayTotal =
              items.fold<int>(0, (sum, item) => sum + item.count);
          final periodTotal = _periodHistoryTotal(_period);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Platforms',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticService.subtle();
                            _showManageAppsSheet();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              'Apps',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            HapticService.subtle();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PlatformLimitsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Limits',
                            style: AppTypography.caption(
                              color: AppColors.primaryAccent,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ScrolaSegmentedControl<_BreakdownPeriod>(
                    items: _BreakdownPeriod.values,
                    selectedItem: _period,
                    labelBuilder: (p) => switch (p) {
                      _BreakdownPeriod.today => 'Today',
                      _BreakdownPeriod.week => 'Week',
                      _BreakdownPeriod.month => 'Month',
                    },
                    onChanged: (p) => setState(() => _period = p),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 210,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 185,
                          height: 185,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primaryAccent.withValues(alpha: 0.20),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 190,
                          height: 190,
                          child: CustomPaint(
                            painter: _DonutBreakdownPainter(
                              slices: items
                                  .map((e) => _Slice(e.count.toDouble(), e.color))
                                  .toList(),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$periodTotal',
                                        style: AppTypography.numeric(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w800,
                                          height: 1.05,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _periodSuffix(_period),
                                        style: AppTypography.caption(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_period != _BreakdownPeriod.today) ...[
                    const SizedBox(height: 4),
                    Text(
                      'App shares below reflect today\'s per-app tracking.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  ...items.map((item) {
                    final share = todayTotal == 0
                        ? 0
                        : ((item.count / todayTotal) * 100).round();
                    final limitProgress = item.limit == 0
                        ? 0.0
                        : (item.count / item.limit).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ScrolaCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () {
                          HapticService.subtle();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PlatformLimitsScreen(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                PlatformIcon(platform: item.platform, size: 42),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: AppTypography.subheading(
                                          color: AppColors.primaryText,
                                        ).copyWith(fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.count} / ${item.limit} limit',
                                        style: AppTypography.numeric(
                                          color: AppColors.secondaryText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
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
                                    color: item.color.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$share%',
                                    style: AppTypography.numeric(
                                      color: item.color,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: limitProgress,
                                minHeight: 6,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.08),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(item.color),
                              ),
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

class _PlatformItem {
  final SocialPlatform platform;
  final String name;
  final int count;
  final int limit;
  final Color color;

  const _PlatformItem({
    required this.platform,
    required this.name,
    required this.count,
    required this.limit,
    required this.color,
  });
}

class _Slice {
  final double value;
  final Color color;
  const _Slice(this.value, this.color);
}

class _DonutBreakdownPainter extends CustomPainter {
  final List<_Slice> slices;

  _DonutBreakdownPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 10;
    const stroke = 14.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke,
    );

    final activeSlices = slices.where((s) => s.value > 0).toList();
    final total = activeSlices.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;

    if (activeSlices.length == 1) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = activeSlices.first.color
          ..strokeWidth = stroke
          ..style = PaintingStyle.stroke,
      );
      return;
    }

    double startAngle = -math.pi / 2;
    const gap = 0.22;
    for (final slice in activeSlices) {
      final fullSweep = (slice.value / total) * 2 * math.pi;
      final sweep = math.max(0.02, fullSweep - gap);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gap / 2,
        sweep,
        false,
        Paint()
          ..color = slice.color
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      startAngle += fullSweep;
    }
  }

  @override
  bool shouldRepaint(_DonutBreakdownPainter old) => true;
}

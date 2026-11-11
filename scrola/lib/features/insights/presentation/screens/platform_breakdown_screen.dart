import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/platform_icon.dart';
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

  int _multiplier(_BreakdownPeriod period) {
    switch (period) {
      case _BreakdownPeriod.today:
        return 1;
      case _BreakdownPeriod.week:
        return 7;
      case _BreakdownPeriod.month:
        return 30;
    }
  }

  String _periodSuffix(_BreakdownPeriod period) {
    switch (period) {
      case _BreakdownPeriod.today:
        return 'reels today';
      case _BreakdownPeriod.week:
        return 'reels this week';
      case _BreakdownPeriod.month:
        return 'reels this month';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final m = _multiplier(_period);
          final ig = _tracking.instagramReels * m;
          final yt = _tracking.youtubeReels * m;
          final fb = _tracking.facebookReels * m;
          final sc = _tracking.snapchatReels * m;
          final total = math.max(0, ig + yt + fb + sc);

          final items = [
            _PlatformItem(
              platform: SocialPlatform.instagram,
              name: 'Instagram Reels',
              count: ig,
              limit: _tracking.instagramLimit * m,
              color: AppColors.instagram,
            ),
            _PlatformItem(
              platform: SocialPlatform.youtube,
              name: 'YouTube Shorts',
              count: yt,
              limit: _tracking.youtubeLimit * m,
              color: AppColors.youtube,
            ),
            _PlatformItem(
              platform: SocialPlatform.facebook,
              name: 'Facebook Reels',
              count: fb,
              limit: _tracking.facebookLimit * m,
              color: AppColors.facebook,
            ),
            _PlatformItem(
              platform: SocialPlatform.snapchat,
              name: 'Snapchat Spotlight',
              count: sc,
              limit: _tracking.snapchatLimit * m,
              color: AppColors.snapchat,
            ),
          ];

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Platforms',
                    trailing: GestureDetector(
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
                        ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$total',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...items.map((item) {
                    final share = total == 0
                        ? 0
                        : ((item.count / total) * 100).round();
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

    final total = slices.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;

    double startAngle = -math.pi / 2;
    const gap = 0.06;
    for (final slice in slices) {
      if (slice.value <= 0) continue;
      final fullSweep = (slice.value / total) * 2 * math.pi;
      final sweep = math.max(0.04, fullSweep - gap);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
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

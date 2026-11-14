import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import 'daily_scroll_history_screen.dart';
import 'monthly_report_screen.dart';
import 'weekly_report_screen.dart';

class InsightsDashboardScreen extends StatefulWidget {
  final bool showBack;

  const InsightsDashboardScreen({
    super.key,
    this.showBack = false,
  });

  @override
  State<InsightsDashboardScreen> createState() =>
      _InsightsDashboardScreenState();
}

class _InsightsDashboardScreenState extends State<InsightsDashboardScreen> {
  final TrackingService _tracking = TrackingService();
  int _selectedPeriod = 0; // 0: Week, 1: Month

  @override
  void initState() {
    super.initState();
    _tracking.addListener(_onTrackingUpdate);
  }

  @override
  void dispose() {
    _tracking.removeListener(_onTrackingUpdate);
    super.dispose();
  }

  void _onTrackingUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dailyAvg = _selectedPeriod == 0 ? 36 : 34;
    final pctDiff = _selectedPeriod == 0 ? '12% less' : '18% less';
    final limit = _tracking.totalLimit;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildDailyAverage(dailyAvg, pctDiff),
              const SizedBox(height: 16),
              _buildTrendChart(limit),
              const SizedBox(height: 20),
              _buildWhenYouScroll(),
              const SizedBox(height: 16),
              _buildPlatformBreakdown(),
              const SizedBox(height: 20),
              _buildReportsSection(),
              const SizedBox(height: 16),
              ScrolaSecondaryButton(
                label: 'View full daily scroll log',
                leadingIcon: const Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                onTap: () {
                  HapticService.light();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DailyScrollHistoryScreen(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.showBack)
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                'Insights',
                style: AppTypography.title().copyWith(fontSize: 26),
              ),
            ],
          )
        else
          Text(
            'Insights',
            style: AppTypography.title().copyWith(fontSize: 28),
          ),
        Container(
          width: 160,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticService.subtle();
                    setState(() => _selectedPeriod = 0);
                  },
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: _selectedPeriod == 0
                          ? AppColors.primaryAccent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Week',
                      style: AppTypography.caption(
                        color: _selectedPeriod == 0
                            ? AppColors.primaryBackground
                            : AppColors.secondaryText,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticService.subtle();
                    setState(() => _selectedPeriod = 1);
                  },
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: _selectedPeriod == 1
                          ? AppColors.primaryAccent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Month',
                      style: AppTypography.caption(
                        color: _selectedPeriod == 1
                            ? AppColors.primaryBackground
                            : AppColors.secondaryText,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyAverage(int dailyAvg, String pctDiff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAILY AVERAGE',
          style: AppTypography.label(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$dailyAvg',
              style: AppTypography.numeric(
                fontSize: 54,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'reels',
              style: AppTypography.body(color: AppColors.secondaryText),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pctDiff,
                style: AppTypography.caption(color: AppColors.success)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendChart(int limit) {
    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-Day Scroll Trend',
                style: AppTypography.subheading(color: AppColors.secondaryText),
              ),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Limit ($limit)',
                    style: AppTypography.caption(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: CustomPaint(
              painter: _SparklineChartPainter(
                data: const [48, 38, 32, 42, 28, 24, 18],
                limit: limit.toDouble(),
                maxVal: 60,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DayLabel('M'),
              _DayLabel('T'),
              _DayLabel('W'),
              _DayLabel('T'),
              _DayLabel('F'),
              _DayLabel('S'),
              _DayLabel('S'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhenYouScroll() {
    final hourHeights = [
      6.0, 4.0, 4.0, 4.0, 4.0, 4.0, 9.0, 18.0, 15.0, 12.0, 15.0, 18.0,
      21.0, 18.0, 15.0, 18.0, 24.0, 27.0, 30.0, 36.0, 48.0, 54.0, 42.0, 18.0,
    ];

    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'When you scroll',
                style: AppTypography.subheading().copyWith(fontSize: 18),
              ),
              Text(
                '24h Heatmap',
                style: AppTypography.caption(color: AppColors.primaryAccent)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(hourHeights.length, (i) {
                final isPeak = i >= 20 && i <= 22;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    height: hourHeights[i],
                    decoration: BoxDecoration(
                      color: isPeak
                          ? AppColors.primaryAccent
                          : AppColors.primaryAccent.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('12 am',
                  style: AppTypography.caption(color: AppColors.secondaryText)),
              Text('6 am',
                  style: AppTypography.caption(color: AppColors.secondaryText)),
              Text('12 pm',
                  style: AppTypography.caption(color: AppColors.secondaryText)),
              Text('6 pm',
                  style: AppTypography.caption(color: AppColors.secondaryText)),
              Text('11 pm',
                  style: AppTypography.caption(color: AppColors.secondaryText)),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: AppTypography.body().copyWith(fontSize: 13.5),
              children: [
                const TextSpan(text: 'Most reels between '),
                TextSpan(
                  text: '9 and 10 pm',
                  style: AppTypography.body(color: AppColors.primaryAccent)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBreakdown() {
    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Platform share',
                style: AppTypography.subheading().copyWith(fontSize: 16),
              ),
              Text(
                'This week',
                style: AppTypography.caption(color: AppColors.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: 50,
                    child: Container(color: AppColors.primaryAccent),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    flex: 32,
                    child: Container(color: const Color(0xFFFF8A4C)),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    flex: 18,
                    child: Container(color: const Color(0xFFFFB27F)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PlatformBadge(
                dotColor: AppColors.primaryAccent,
                label: 'Instagram 50%',
              ),
              _PlatformBadge(
                dotColor: const Color(0xFFFF8A4C),
                label: 'YouTube 32%',
              ),
              _PlatformBadge(
                dotColor: const Color(0xFFFFB27F),
                label: 'Other 18%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticService.light();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
            );
          },
          child: ScrolaCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.calendar_view_week_rounded,
                    color: AppColors.primaryAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Report',
                        style: AppTypography.subheading(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'See your 7-day dopamine summary & best day',
                        style: AppTypography.caption(
                            color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.secondaryText,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            HapticService.light();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
            );
          },
          child: ScrolaCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    color: AppColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Monthly Report',
                            style: AppTypography.subheading(),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PRO',
                              style: AppTypography.caption(
                                color: AppColors.primaryBackground,
                              ).copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '30-day dopamine intake and platform shifts',
                        style: AppTypography.caption(
                            color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.secondaryText,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Center(
        child: Text(
          label,
          style: AppTypography.caption(color: AppColors.secondaryText)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  final Color dotColor;
  final String label;

  const _PlatformBadge({required this.dotColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption(color: AppColors.secondaryText)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SparklineChartPainter extends CustomPainter {
  final List<double> data;
  final double limit;
  final double maxVal;

  _SparklineChartPainter({
    required this.data,
    required this.limit,
    required this.maxVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final stepX = size.width / (data.length - 1);
    final limitY = size.height - (limit / maxVal * size.height).clamp(0, size.height);

    // Draw dashed limit line
    final limitPaint = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double curX = 0;
    while (curX < size.width) {
      canvas.drawLine(
        Offset(curX, limitY),
        Offset((curX + 6).clamp(0, size.width), limitY),
        limitPaint,
      );
      curX += 10;
    }

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxVal * size.height).clamp(0, size.height);
      points.add(Offset(x, y));
    }

    // Path fill
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryAccent.withValues(alpha: 0.25),
          AppColors.primaryAccent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line stroke
    final strokePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      strokePath.lineTo(points[i].dx, points[i].dy);
    }

    final strokePaint = Paint()
      ..color = AppColors.primaryAccent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(strokePath, strokePaint);

    // Points
    final dotBg = Paint()..color = const Color(0xFF101010);
    final dotBorder = Paint()
      ..color = AppColors.primaryAccent
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    for (final p in points) {
      canvas.drawCircle(p, 4.5, dotBg);
      canvas.drawCircle(p, 4.5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklineChartPainter oldDelegate) => true;
}

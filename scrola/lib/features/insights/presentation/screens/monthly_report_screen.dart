import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../profile/presentation/screens/subscription_pro_screen.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

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
                title: 'Monthly report',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'PRO',
                    style: AppTypography.caption(
                      color: AppColors.primaryBackground,
                    ).copyWith(fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MONTH IN REVIEW',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '1,046',
                        style: AppTypography.numeric(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'reels',
                        style: AppTypography.body(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '18% fewer than October',
                    style: AppTypography.body(color: AppColors.success)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ScrolaCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Weekly trajectory',
                      style: AppTypography.subheading(color: AppColors.secondaryText)
                          .copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 100,
                      child: CustomPaint(
                        painter: _MonthlyLinePainter(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Week 1',
                            style: AppTypography.caption(
                                color: AppColors.secondaryText)),
                        Text('Week 2',
                            style: AppTypography.caption(
                                color: AppColors.secondaryText)),
                        Text('Week 3',
                            style: AppTypography.caption(
                                color: AppColors.secondaryText)),
                        Text('Week 4',
                            style: AppTypography.caption(
                                color: AppColors.secondaryText)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ScrolaCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Days under your limit',
                          style: AppTypography.subheading().copyWith(fontSize: 15),
                        ),
                        Text(
                          '24 of 30',
                          style: AppTypography.numeric(
                            color: AppColors.primaryAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 30,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 10,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        // Days 2, 6, 11, 17, 25 are over limit
                        final isOver = [2, 6, 11, 17, 25].contains(index);
                        return Container(
                          decoration: BoxDecoration(
                            color: isOver
                                ? AppColors.warning
                                : AppColors.primaryAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Under limit (24)',
                          style: AppTypography.caption(
                              color: AppColors.secondaryText),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Over limit (6)',
                          style: AppTypography.caption(
                              color: AppColors.secondaryText),
                        ),
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
                    const BrainyMascot(
                      mood: BrainyMood.celebrating,
                      skin: BrainySkin.classic,
                      size: 64,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brainy evolved to Bright Mind',
                            style: AppTypography.subheading()
                                .copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'on Nov 9, Level 6 milestone',
                            style: AppTypography.caption(
                                color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ScrolaPrimaryButton(
                label: 'Export CSV & full data',
                leadingIcon: const Icon(
                  Icons.download_rounded,
                  color: AppColors.primaryBackground,
                  size: 20,
                ),
                onTap: () {
                  HapticService.medium();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Scrola Pro report exported to Downloads!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () {
                    HapticService.light();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionProScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Manage Scrola Pro membership',
                    style: AppTypography.caption(color: AppColors.primaryAccent)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.35),
      Offset(size.width * 0.33, size.height * 0.45),
      Offset(size.width * 0.66, size.height * 0.65),
      Offset(size.width, size.height * 0.75),
    ];

    // Dashed threshold
    final limitPaint = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double curX = 0;
    while (curX < size.width) {
      canvas.drawLine(
        Offset(curX, size.height * 0.5),
        Offset((curX + 6).clamp(0, size.width), size.height * 0.5),
        limitPaint,
      );
      curX += 10;
    }

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
          AppColors.primaryAccent.withValues(alpha: 0.20),
          AppColors.primaryAccent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

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
  bool shouldRepaint(covariant _MonthlyLinePainter oldDelegate) => false;
}

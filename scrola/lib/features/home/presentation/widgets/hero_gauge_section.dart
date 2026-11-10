import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/haptic_service.dart';

class HeroGaugeSection extends StatefulWidget {
  final int reelsToday;
  final int totalLimit;
  final int streakDays;
  final int xpToday;
  final int currentLevel;
  final String levelTitle;

  const HeroGaugeSection({
    super.key,
    this.reelsToday = 24,
    this.totalLimit = 40,
    this.streakDays = 7,
    this.xpToday = 20,
    this.currentLevel = 4,
    this.levelTitle = 'Curious',
  });

  @override
  State<HeroGaugeSection> createState() => _HeroGaugeSectionState();
}

class _HeroGaugeSectionState extends State<HeroGaugeSection>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    // Gentle floating breathing animation for Brainy
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Smooth entrance for the gauge progress
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    final double targetFraction = (widget.reelsToday / widget.totalLimit).clamp(0.0, 1.0);
    _progressAnimation = Tween<double>(begin: 0.0, end: targetFraction).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Cubic(0.2, 0.8, 0.2, 1.0),
      ),
    );

    _progressController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int reelsRemaining = math.max(0, widget.totalLimit - widget.reelsToday);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Orbit Gauge and Mascot Arena
        SizedBox(
          width: 340,
          height: 310,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient Orange Glow behind Mascot
              Positioned(
                top: 40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.28),
                        AppColors.primaryAccent.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // Animated Circular Orbit Gauge & Ticks
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(290, 290),
                    painter: _OrbitGaugePainter(
                      progress: _progressAnimation.value,
                    ),
                  );
                },
              ),

              // Orbit Chip 1: Streak (Left)
              Positioned(
                left: 14,
                top: 88,
                child: _buildOrbitBadge(
                  icon: const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.primaryAccent,
                    size: 16,
                  ),
                  primaryText: '${widget.streakDays}',
                  secondaryText: 'streak',
                  onTap: () {
                    HapticService.light();
                  },
                ),
              ),

              // Orbit Chip 2: XP (Top-Right)
              Positioned(
                right: 22,
                top: 72,
                child: _buildOrbitBadge(
                  icon: const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  primaryText: '+${widget.xpToday}',
                  secondaryText: 'XP',
                  onTap: () {
                    HapticService.light();
                  },
                ),
              ),

              // Orbit Chip 3: Level (Bottom-Right)
              Positioned(
                right: 18,
                bottom: 50,
                child: _buildOrbitBadge(
                  icon: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFD49C57),
                    size: 15,
                  ),
                  primaryText: 'Lv ${widget.currentLevel}',
                  secondaryText: widget.levelTitle,
                  onTap: () {
                    HapticService.light();
                  },
                ),
              ),

              // Floating Speech Bubble ("Great pace, Alex!")
              Positioned(
                top: 18,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Great pace, Alex!',
                    style: AppTypography.label(
                      color: AppColors.primaryText,
                      letterSpacing: 0.2,
                    ).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Mascot: Brainy (Center with Floating Animation)
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/brainy_mascot.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // "REELS TODAY" label
        Text(
          'REELS TODAY',
          style: AppTypography.label(
            color: AppColors.secondaryText,
            letterSpacing: 1.5,
          ).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        // Key Numbers: 24 / 40
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${widget.reelsToday}',
              style: AppTypography.display(
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '/ ${widget.totalLimit}',
              style: AppTypography.title(
                color: AppColors.secondaryText,
              ).copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Status Badges Row: [16 reels left] [On pace]
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Orange Solid Pill
            GestureDetector(
              onTap: () => HapticService.subtle(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '$reelsRemaining reels left',
                  style: AppTypography.body(
                    color: AppColors.textOnAccent,
                  ).copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Green "On pace" Pill
            GestureDetector(
              onTap: () => HapticService.subtle(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'On pace',
                  style: AppTypography.body(
                    color: AppColors.success,
                  ).copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrbitBadge({
    required Widget icon,
    required String primaryText,
    required String secondaryText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.elevatedSurface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 1),
            Text(
              primaryText,
              style: AppTypography.subheading(
                color: AppColors.primaryText,
              ).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            Text(
              secondaryText,
              style: AppTypography.caption(
                color: AppColors.secondaryText,
              ).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitGaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  _OrbitGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 6);
    final radius = size.width * 0.44;

    // Draw background tick marks on the inactive portion (from ~130 deg to ~230 deg)
    final tickPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const totalTicks = 28;
    const startTickAngle = 135 * (math.pi / 180);
    const tickSweepAngle = 110 * (math.pi / 180);

    for (int i = 0; i <= totalTicks; i++) {
      final angle = startTickAngle + (i / totalTicks) * tickSweepAngle;
      final inner = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + (radius + 5) * math.cos(angle),
        center.dy + (radius + 5) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Active Glowing Arc:
    // Sweeps from top-left (~ -40 degrees) around clockwise down to ~ 115 degrees
    // Matching the reference image where the glowing orange arc wraps around the right side down to the bottom
    const startAngle = -45 * (math.pi / 180);
    const maxSweepAngle = 210 * (math.pi / 180);
    final sweepAngle = maxSweepAngle * progress;

    // Background track arc
    final trackPaint = Paint()
      ..color = AppColors.cardSurface.withValues(alpha: 0.6)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      maxSweepAngle,
      false,
      trackPaint,
    );

    if (progress > 0.01) {
      // Glow behind active arc
      final glowPaint = Paint()
        ..color = AppColors.primaryAccent.withValues(alpha: 0.4)
        ..strokeWidth = 10.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );

      // Active vibrant orange arc
      final activePaint = Paint()
        ..color = AppColors.primaryAccent
        ..strokeWidth = 5.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );

      // Thumb / Handle indicator at the end of progress
      final currentAngle = startAngle + sweepAngle;
      final thumbCenter = Offset(
        center.dx + radius * math.cos(currentAngle),
        center.dy + radius * math.sin(currentAngle),
      );

      // Thumb glow
      final thumbGlowPaint = Paint()
        ..color = AppColors.primaryAccent.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(thumbCenter, 9, thumbGlowPaint);

      // Thumb outer orange ring
      final thumbOuterPaint = Paint()
        ..color = AppColors.primaryAccent
        ..style = PaintingStyle.fill;
      canvas.drawCircle(thumbCenter, 7.5, thumbOuterPaint);

      // Thumb inner bright dot
      final thumbInnerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(thumbCenter, 4.0, thumbInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

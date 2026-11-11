import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';

class HeroGaugeSection extends StatefulWidget {
  final int reelsToday;
  final int totalLimit;
  final int streakDays;
  final int xpToday;
  final int currentLevel;
  final String levelTitle;
  final BrainyMood mood;
  final BrainySkin skin;
  final bool isTracking;
  final VoidCallback? onMascotTap;
  final VoidCallback? onStreakTap;
  final VoidCallback? onXpTap;
  final VoidCallback? onLevelTap;
  final VoidCallback? onCounterTap;

  const HeroGaugeSection({
    super.key,
    required this.reelsToday,
    required this.totalLimit,
    required this.streakDays,
    required this.xpToday,
    required this.currentLevel,
    required this.levelTitle,
    required this.mood,
    required this.skin,
    this.isTracking = true,
    this.onMascotTap,
    this.onStreakTap,
    this.onXpTap,
    this.onLevelTap,
    this.onCounterTap,
  });

  @override
  State<HeroGaugeSection> createState() => _HeroGaugeSectionState();
}

class _HeroGaugeSectionState extends State<HeroGaugeSection>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: AppMotion.floatCycle,
    )..repeat(reverse: true);

    _ringController = AnimationController(
      vsync: this,
      duration: AppMotion.ringDraw,
    )..forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  String _speechText(int remaining) {
    if (!widget.isTracking) return 'Enable tracking to count.';
    if (remaining <= 0) return 'Limit hit. Brainy needs rest.';
    if (remaining <= (widget.totalLimit * 0.25).round()) {
      return '$remaining left. Slow down!';
    }
    return '$remaining left. Easy day.';
  }

  @override
  Widget build(BuildContext context) {
    final safeLimit = math.max(1, widget.totalLimit);
    final remaining = math.max(0, safeLimit - widget.reelsToday);
    final progress = (widget.reelsToday / safeLimit).clamp(0.0, 1.0);
    final reduceMotion = AppMotion.isReducedMotion(context);

    final paceColor = !widget.isTracking
        ? AppColors.warning
        : remaining == 0
            ? AppColors.error
            : remaining <= (safeLimit * 0.25)
                ? AppColors.warning
                : AppColors.success;

    final paceLabel = !widget.isTracking
        ? 'Setup needed'
        : remaining == 0
            ? 'Limit reached'
            : remaining <= (safeLimit * 0.25)
                ? 'Nearly there'
                : 'On pace';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                HapticService.subtle();
                widget.onMascotTap?.call();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  _speechText(remaining),
                  style: AppTypography.caption(color: AppColors.primaryText)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final arenaWidth = math.min(constraints.maxWidth, 360.0);
            final ringSize = math.min(arenaWidth * 0.78, 290.0);

            return SizedBox(
              width: arenaWidth,
              height: ringSize + 12,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimatedBuilder(
                    animation: _ringController,
                    builder: (context, _) {
                      final t = reduceMotion
                          ? 1.0
                          : AppMotion.easeOut.transform(_ringController.value);
                      return CustomPaint(
                        size: Size(ringSize, ringSize),
                        painter: _HeroOrbitRingPainter(
                          progress: progress * t,
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticService.light();
                      widget.onMascotTap?.call();
                    },
                    child: BrainyMascot(
                      mood: widget.mood,
                      skin: widget.skin,
                      size: ringSize * 0.62,
                      animate: !reduceMotion,
                    ),
                  ),
                  // Left floating orb: streak
                  Positioned(
                    left: 8,
                    top: ringSize * 0.25,
                    child: _FloatingOrb(
                      controller: _floatController,
                      phaseOffset: 0.0,
                      reduceMotion: reduceMotion,
                      size: 62,
                      onTap: widget.onStreakTap,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.primaryAccent,
                            size: 16,
                          ),
                          Text(
                            '${widget.streakDays}',
                            style: AppTypography.numeric(
                              color: AppColors.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          Text(
                            'streak',
                            style: AppTypography.caption(
                              color: AppColors.secondaryText,
                            ).copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Top-right floating orb: XP today
                  Positioned(
                    right: 10,
                    top: ringSize * 0.16,
                    child: _FloatingOrb(
                      controller: _floatController,
                      phaseOffset: 0.4,
                      reduceMotion: reduceMotion,
                      size: 60,
                      onTap: widget.onXpTap,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: AppColors.primaryAccent,
                            size: 16,
                          ),
                          Text(
                            '+${widget.xpToday}',
                            style: AppTypography.numeric(
                              color: AppColors.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          Text(
                            'XP',
                            style: AppTypography.caption(
                              color: AppColors.secondaryText,
                            ).copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom-right floating orb: Level
                  Positioned(
                    right: 8,
                    bottom: ringSize * 0.10,
                    child: _FloatingOrb(
                      controller: _floatController,
                      phaseOffset: 0.8,
                      reduceMotion: reduceMotion,
                      size: 64,
                      onTap: widget.onLevelTap,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.emoji_events_outlined,
                            color: AppColors.primaryAccent,
                            size: 15,
                          ),
                          Text(
                            'Lv ${widget.currentLevel}',
                            style: AppTypography.numeric(
                              color: AppColors.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          Text(
                            widget.levelTitle.split(' ').first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption(
                              color: AppColors.secondaryText,
                            ).copyWith(fontSize: 9.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        GestureDetector(
          onTap: () {
            HapticService.subtle();
            widget.onCounterTap?.call();
          },
          child: Column(
            children: [
              Text(
                'REELS TODAY',
                style: AppTypography.label(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${widget.reelsToday}',
                    style: AppTypography.heroDisplay(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '/ $safeLimit',
                    style: AppTypography.numeric(
                      color: AppColors.secondaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      remaining > 0 ? '$remaining reels left' : 'Limit reached',
                      style: AppTypography.caption(
                        color: AppColors.textOnAccent,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: paceColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: paceColor.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      paceLabel,
                      style: AppTypography.caption(color: paceColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FloatingOrb extends StatelessWidget {
  final AnimationController controller;
  final double phaseOffset;
  final bool reduceMotion;
  final double size;
  final VoidCallback? onTap;
  final Widget child;

  const _FloatingOrb({
    required this.controller,
    required this.phaseOffset,
    required this.reduceMotion,
    required this.size,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final offset = reduceMotion
            ? 0.0
            : math.sin((controller.value + phaseOffset) * 2 * math.pi) * 4.5;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticService.subtle();
          onTap?.call();
        },
        child: Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _HeroOrbitRingPainter extends CustomPainter {
  final double progress;

  _HeroOrbitRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 14;

    // Dotted base ring
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const dashCount = 48;
    const fullAngle = 2 * math.pi;
    for (int i = 0; i < dashCount; i++) {
      final a = -math.pi / 2 + (i / dashCount) * fullAngle;
      final p = Offset(
        center.dx + radius * math.cos(a),
        center.dy + radius * math.sin(a),
      );
      canvas.drawCircle(p, 1.3, dotPaint..style = PaintingStyle.fill);
    }

    if (progress <= 0.005) return;

    final sweep = progress * 2 * math.pi;
    const startAngle = -math.pi / 2;

    // Subtle orange glow under arc
    final glowPaint = Paint()
      ..color = AppColors.primaryAccent.withValues(alpha: 0.28)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      glowPaint,
    );

    final arcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primaryAccent, AppColors.accentHighlight],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      arcPaint,
    );

    final endAngle = startAngle + sweep;
    final knobCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    canvas.drawCircle(
      knobCenter,
      9,
      Paint()..color = AppColors.primaryAccent.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      knobCenter,
      5,
      Paint()..color = AppColors.accentHighlight,
    );
  }

  @override
  bool shouldRepaint(_HeroOrbitRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

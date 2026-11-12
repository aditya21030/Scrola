import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../shared/widgets/brainy_mascot.dart';

/// Launches a curved bezier flight animation sending the Hero Brainy mascot
/// from its current render position into the top-center phone notch capsule.
///
/// Guarantees [onArrive] runs and is awaited once—even on frame hitches,
/// reduced-motion settings, or missing layout geometry.
Future<void> playNotchFlightAnimation({
  required BuildContext context,
  required GlobalKey mascotKey,
  required BrainyMood mood,
  required BrainySkin skin,
  required bool stickToNotch,
  required FutureOr<void> Function() onArrive,
}) async {
  var arrivalTriggered = false;
  Future<void>? arrivalFuture;

  void triggerArrivalOnce() {
    if (arrivalTriggered) return;
    arrivalTriggered = true;
    arrivalFuture = Future<void>.sync(onArrive);
  }

  if (AppMotion.isReducedMotion(context)) {
    HapticService.medium();
    triggerArrivalOnce();
    await arrivalFuture;
    return;
  }

  final overlay = Overlay.maybeOf(context);
  final renderBox =
      mascotKey.currentContext?.findRenderObject() as RenderBox?;
  if (overlay == null || renderBox == null || !renderBox.hasSize) {
    HapticService.medium();
    triggerArrivalOnce();
    await arrivalFuture;
    return;
  }

  final topLeft = renderBox.localToGlobal(Offset.zero);
  final sourceSize = renderBox.size.shortestSide;
  final sourceCenter = topLeft + Offset(renderBox.size.width / 2, renderBox.size.height / 2);

  final media = MediaQuery.of(context);
  final targetCenter = Offset(
    media.size.width / 2,
    math.max(20.0, media.padding.top + (stickToNotch ? 20.0 : 44.0)),
  );

  final stageCompleter = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _NotchFlightStage(
      sourceCenter: sourceCenter,
      sourceSize: sourceSize,
      targetCenter: targetCenter,
      mood: mood,
      skin: skin,
      stickToNotch: stickToNotch,
      onArrive: triggerArrivalOnce,
      onComplete: () {
        if (!stageCompleter.isCompleted) {
          stageCompleter.complete();
        }
      },
    ),
  );

  overlay.insert(entry);
  try {
    await stageCompleter.future.timeout(
      const Duration(milliseconds: 1150),
      onTimeout: () {},
    );
  } finally {
    triggerArrivalOnce();
    if (entry.mounted) {
      entry.remove();
    }
  }
  await (arrivalFuture ?? Future<void>.value());
}

class _NotchFlightStage extends StatefulWidget {
  final Offset sourceCenter;
  final double sourceSize;
  final Offset targetCenter;
  final BrainyMood mood;
  final BrainySkin skin;
  final bool stickToNotch;
  final VoidCallback onArrive;
  final VoidCallback onComplete;

  const _NotchFlightStage({
    required this.sourceCenter,
    required this.sourceSize,
    required this.targetCenter,
    required this.mood,
    required this.skin,
    required this.stickToNotch,
    required this.onArrive,
    required this.onComplete,
  });

  @override
  State<_NotchFlightStage> createState() => _NotchFlightStageState();
}

class _NotchFlightStageState extends State<_NotchFlightStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _arrivalFired = false;
  bool _completed = false;

  void _fireArrivalIfNeeded() {
    if (_arrivalFired) return;
    _arrivalFired = true;
    HapticService.medium();
    widget.onArrive();
  }

  void _notifyCompleteOnce() {
    if (_completed) return;
    _completed = true;
    widget.onComplete();
  }

  @override
  void initState() {
    super.initState();
    HapticService.light();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    )
      ..addListener(() {
        if (!_arrivalFired && _controller.value >= 0.78) {
          _fireArrivalIfNeeded();
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          _fireArrivalIfNeeded();
          _notifyCompleteOnce();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _notifyCompleteOnce();
    _controller.dispose();
    super.dispose();
  }

  Offset _bezierPoint(double t, Offset p0, Offset p1, Offset p2) {
    final u = 1.0 - t;
    return Offset(
      u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx,
      u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlPoint = Offset(
      widget.sourceCenter.dx - 38.0,
      (widget.sourceCenter.dy + widget.targetCenter.dy) * 0.42,
    );

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final v = _controller.value;

            // Phase 1 (0..0.16): energetic wind-up squash
            // Phase 2 (0.16..0.78): soaring curved flight to top notch
            // Phase 3 (0.78..1.0): dock settle & handoff fade
            final flightT = ((v - 0.16) / 0.62).clamp(0.0, 1.0);
            final curvedT = Curves.easeInOutCubic.transform(flightT);

            final center = _bezierPoint(
              curvedT,
              widget.sourceCenter,
              controlPoint,
              widget.targetCenter,
            );

            final squashScale = v < 0.16
                ? 1.0 - 0.14 * math.sin((v / 0.16) * math.pi)
                : 1.0;

            final mascotSize =
                uiLerp(widget.sourceSize, 30.0, curvedT) * squashScale;

            final tilt = v >= 0.16 && v <= 0.78
                ? math.sin(flightT * math.pi) * -0.18
                : 0.0;

            final capsuleT = ((v - 0.56) / 0.24).clamp(0.0, 1.0);
            final capsuleEase = Curves.easeOutBack.transform(capsuleT);

            final rippleT = ((v - 0.74) / 0.26).clamp(0.0, 1.0);
            final handoffOpacity =
                v > 0.78 ? (1.0 - ((v - 0.78) / 0.22)).clamp(0.0, 1.0) : 1.0;

            return Opacity(
              opacity: handoffOpacity,
              child: Stack(
                children: [
                  // Launching orb glow at origin
                  if (v < 0.35)
                    Positioned(
                      left: widget.sourceCenter.dx - 75,
                      top: widget.sourceCenter.dy - 75,
                      child: Opacity(
                        opacity: (1.0 - v / 0.35) * 0.45,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primaryAccent.withValues(alpha: 0.75),
                                AppColors.primaryAccent.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Glowing comet sparks along the arc
                  if (v >= 0.14 && v <= 0.86)
                    for (int i = 1; i <= 5; i++)
                      Builder(builder: (_) {
                        final trailT = (curvedT - i * 0.065).clamp(0.0, 1.0);
                        final pt = _bezierPoint(
                          trailT,
                          widget.sourceCenter,
                          controlPoint,
                          widget.targetCenter,
                        );
                        final sparkSize = (14.0 - i * 1.9).clamp(3.0, 14.0);
                        final sparkAlpha =
                            ((1.0 - i * 0.17) * (1.0 - flightT * 0.35))
                                .clamp(0.0, 1.0);
                        return Positioned(
                          left: pt.dx - sparkSize / 2,
                          top: pt.dy - sparkSize / 2,
                          child: Opacity(
                            opacity: sparkAlpha,
                            child: Container(
                              width: sparkSize,
                              height: sparkSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryAccent
                                        .withValues(alpha: 0.75),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                  // Notch capture capsule opening at top center until native overlay takes over
                  if (capsuleT > 0 && v < 0.78)
                    Positioned(
                      left: widget.targetCenter.dx - (68 * capsuleEase),
                      top: widget.targetCenter.dy - 19,
                      child: Container(
                        width: math.max(1.0, 136 * capsuleEase),
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.primaryAccent
                                .withValues(alpha: 0.65),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAccent
                                  .withValues(alpha: 0.35),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Arrival shockwave ripple around notch
                  if (rippleT > 0)
                    Positioned(
                      left: widget.targetCenter.dx - (26 + rippleT * 52),
                      top: widget.targetCenter.dy - (18 + rippleT * 18),
                      child: Opacity(
                        opacity: (1.0 - rippleT) * 0.75,
                        child: Container(
                          width: 52 + rippleT * 104,
                          height: 36 + rippleT * 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.primaryAccent,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Soaring Brainy Mascot (hands off seamlessly right as native pill docks)
                  if (v < 0.78)
                    Positioned(
                      left: center.dx - mascotSize / 2,
                      top: center.dy - mascotSize / 2,
                      child: Transform.rotate(
                        angle: tilt,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryAccent
                                    .withValues(alpha: 0.40),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: BrainyMascot(
                            mood: v >= 0.55
                                ? BrainyMood.excited
                                : widget.mood,
                            skin: widget.skin,
                            size: mascotSize,
                            animate: false,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double uiLerp(double a, double b, double t) => a + (b - a) * t;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/focus_mode_service.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';

class ActiveFocusSessionScreen extends StatelessWidget {
  const ActiveFocusSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focus = FocusModeService();
    final tracking = TrackingService();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: Listenable.merge([focus, tracking]),
        builder: (context, _) {
          final totalMin = math.max(1, (focus.totalDurationSeconds / 60).round());
          final doneMin = ((focus.totalDurationSeconds - focus.remainingSeconds) /
                  60)
              .floor();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Focus session',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        focus.isPaused ? 'Paused' : 'Blocking on',
                        style: AppTypography.caption(
                          color: focus.isPaused
                              ? AppColors.warning
                              : AppColors.success,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: SizedBox(
                      width: 248,
                      height: 248,
                      child: CustomPaint(
                        painter: _ActiveFocusRingPainter(
                          progress: focus.progress,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BrainyMascot(
                              mood: BrainyMood.focused,
                              skin: tracking.equippedSkin,
                              size: 88,
                            ),
                            Text(
                              focus.formattedRemainingTime,
                              style: AppTypography.display(),
                            ),
                            Text(
                              'remaining',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '$doneMin of $totalMin minutes done',
                      style: AppTypography.caption(
                        color: AppColors.primaryAccent,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Reels stay blocked until the timer ends',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ScrolaCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: AppColors.primaryAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reels are blocked',
                                style: AppTypography.subheading()
                                    .copyWith(fontSize: 15),
                              ),
                              Text(
                                'Instagram, YouTube',
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
                            color: AppColors.elevatedSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${focus.blockedAttempts} attempts',
                            style: AppTypography.numeric(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionTileBtn(
                          icon: Icons.add_rounded,
                          label: 'Add time',
                          subtitle: '+5 min',
                          onTap: () {
                            HapticService.light();
                            focus.addFiveMinutes();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionTileBtn(
                          icon: focus.isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          label: focus.isPaused ? 'Resume' : 'Pause',
                          isPrimary: true,
                          onTap: () {
                            HapticService.light();
                            focus.togglePause();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionTileBtn(
                          icon: Icons.stop_rounded,
                          label: 'End',
                          isDanger: true,
                          onTap: () {
                            HapticService.warning();
                            focus.cancelSession();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
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

class _ActionTileBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isPrimary;
  final bool isDanger;
  final VoidCallback onTap;

  const _ActionTileBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isPrimary = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary ? AppColors.primaryAccent : AppColors.surfaceSolid;
    final fg = isPrimary
        ? AppColors.textOnAccent
        : isDanger
            ? AppColors.error
            : AppColors.primaryText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDanger
                      ? AppColors.error.withValues(alpha: 0.4)
                      : AppColors.borderSubtle,
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(height: 2),
            Text(
              subtitle ?? label,
              style: AppTypography.caption(color: fg)
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveFocusRingPainter extends CustomPainter {
  final double progress;
  _ActiveFocusRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 8;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.max(0.02, progress) * 2 * math.pi,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.accentHighlight, AppColors.primaryAccent],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ActiveFocusRingPainter old) => old.progress != progress;
}

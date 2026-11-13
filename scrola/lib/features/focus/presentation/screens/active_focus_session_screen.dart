import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/focus_mode_service.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class ActiveFocusSessionScreen extends StatefulWidget {
  const ActiveFocusSessionScreen({super.key});

  @override
  State<ActiveFocusSessionScreen> createState() =>
      _ActiveFocusSessionScreenState();
}

class _ActiveFocusSessionScreenState extends State<ActiveFocusSessionScreen>
    with WidgetsBindingObserver {
  final FocusModeService _focus = FocusModeService();
  final TrackingService _tracking = TrackingService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focus.syncTimerOnResume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _focus.syncTimerOnResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: Listenable.merge([_focus, _tracking]),
        builder: (context, _) {
          final isCompleted = !_focus.isActive && _focus.isJustCompleted;
          final isEnded = !_focus.isActive && !_focus.isJustCompleted;
          final totalMin =
              math.max(1, (_focus.totalDurationSeconds / 60).round());
          final doneMin = isCompleted
              ? totalMin
              : ((_focus.totalDurationSeconds - _focus.remainingSeconds) / 60)
                  .floor()
                  .clamp(0, totalMin);
          final blockedAppsLabel = _tracking.activePlatforms.isEmpty
              ? 'Selected apps'
              : _tracking.activePlatforms.map((p) => p.shortName).join(', ');

          final String badgeLabel;
          final Color badgeColor;
          if (isCompleted) {
            badgeLabel = 'Completed';
            badgeColor = AppColors.success;
          } else if (isEnded) {
            badgeLabel = 'Ended';
            badgeColor = AppColors.secondaryText;
          } else if (_focus.isPaused) {
            badgeLabel = 'Paused';
            badgeColor = AppColors.warning;
          } else {
            badgeLabel = 'Blocking on';
            badgeColor = AppColors.success;
          }

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
                        badgeLabel,
                        style: AppTypography.caption(
                          color: badgeColor,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Spacer(),
                                Center(
                                  child: SizedBox(
                                    width: 248,
                                    height: 248,
                                    child: CustomPaint(
                                      painter: _ActiveFocusRingPainter(
                                        progress:
                                            isCompleted ? 1.0 : _focus.progress,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          BrainyMascot(
                                            mood: isCompleted
                                                ? BrainyMood.celebrating
                                                : BrainyMood.focused,
                                            skin: _tracking.equippedSkin,
                                            size: 88,
                                          ),
                                          Text(
                                            isCompleted
                                                ? '00:00'
                                                : _focus.formattedRemainingTime,
                                            style: AppTypography.display(),
                                          ),
                                          Text(
                                            isCompleted
                                                ? 'completed'
                                                : 'remaining',
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
                                    isCompleted
                                        ? 'Focus session complete!'
                                        : '$doneMin of $totalMin minutes done',
                                    style: AppTypography.caption(
                                      color: isCompleted
                                          ? AppColors.success
                                          : AppColors.primaryAccent,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Center(
                                  child: Text(
                                    isCompleted
                                        ? 'Earned +30 XP · ${_focus.blockedAttempts} distraction${_focus.blockedAttempts == 1 ? '' : 's'} blocked'
                                        : isEnded
                                            ? 'Start a focus session to block short-video feeds'
                                            : 'Reels stay blocked until the timer ends',
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
                                          color: AppColors.primaryAccent
                                              .withValues(alpha: 0.14),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.shield_rounded,
                                          color: AppColors.primaryAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isCompleted
                                                  ? 'Distractions stayed blocked'
                                                  : 'Reels are blocked',
                                              style: AppTypography.subheading()
                                                  .copyWith(fontSize: 15),
                                            ),
                                            Text(
                                              blockedAppsLabel,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.elevatedSurface,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${_focus.blockedAttempts} attempts',
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_focus.isActive)
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTileBtn(
                            icon: Icons.add_rounded,
                            label: 'Add time',
                            subtitle: '+5 min',
                            onTap: _focus.addFiveMinutes,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionTileBtn(
                            icon: _focus.isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            label: _focus.isPaused ? 'Resume' : 'Pause',
                            isPrimary: true,
                            onTap: _focus.togglePause,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionTileBtn(
                            icon: Icons.stop_rounded,
                            label: 'End',
                            isDanger: true,
                            onTap: () async {
                              await _focus.cancelSession();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    ScrolaPrimaryButton(
                      label: 'Done',
                      onPressed: () {
                        _focus.dismissCompletion();
                        Navigator.of(context).pop();
                      },
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

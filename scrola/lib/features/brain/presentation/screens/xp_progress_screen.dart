import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class XpProgressScreen extends StatefulWidget {
  const XpProgressScreen({super.key});

  @override
  State<XpProgressScreen> createState() => _XpProgressScreenState();
}

class _XpProgressScreenState extends State<XpProgressScreen> {
  final TrackingService _tracking = TrackingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final info = GamificationEngine.getLevelForXP(_tracking.xpTotal);
          final toNext = math.max(0, info.xpForNextLevel - info.xpInCurrentLevel);
          final collectedToday = _tracking.isDailyXpCollectedToday;

          final underLimitXP = _tracking.isLimitReached ? 0 : 20;
          final focusXP = _tracking.focusMinutesToday > 0 ? 30 : 0;
          final streakXP = _tracking.streakDays > 0 ? 10 : 0;
          final readyXP = underLimitXP + focusXP + streakXP;

          final startLevel = info.level <= 1 ? 1 : info.level - 1;
          final milestoneLevels = [
            startLevel,
            startLevel + 1,
            startLevel + 2,
            startLevel + 3,
          ];

          String milestoneStatus(int lvl) {
            if (lvl == info.level) return 'You';
            if (lvl < info.level) return 'Done';
            final curStage =
                GamificationEngine.getStageForLevel(lvl).stageNumber;
            final prevStage =
                GamificationEngine.getStageForLevel(lvl - 1).stageNumber;
            if (curStage != prevStage) return 'Evolve';
            return 'Reward';
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScrolaAppBar(title: 'Level progress'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: SizedBox(
                              width: 170,
                              height: 170,
                              child: CustomPaint(
                                painter: _XpRingPainter(progress: info.progress),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'LEVEL',
                                      style: AppTypography.label(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    Text(
                                      '${info.level}',
                                      style: AppTypography.numeric(
                                        fontSize: 52,
                                        fontWeight: FontWeight.w800,
                                        height: 1.05,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              '${info.xpInCurrentLevel} / ${info.xpForNextLevel} XP',
                              style: AppTypography.numeric(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              '$toNext XP to Level ${info.level + 1}',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TODAY',
                                style: AppTypography.label(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              Text(
                                collectedToday
                                    ? 'Collected'
                                    : readyXP > 0
                                        ? '+$readyXP XP ready'
                                        : '0 XP ready',
                                style: AppTypography.caption(
                                  color: collectedToday
                                      ? AppColors.success
                                      : AppColors.primaryAccent,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ScrolaCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _XpSourceRow(
                                  title: 'Stayed under limit',
                                  subtitle: _tracking.isLimitReached
                                      ? 'Exceeded daily limit'
                                      : '${_tracking.totalReelsToday} / ${_tracking.totalLimit} reels today',
                                  xp: '+$underLimitXP',
                                ),
                                const Divider(
                                    color: AppColors.borderSubtle, height: 22),
                                _XpSourceRow(
                                  title: 'Focus session',
                                  subtitle: _tracking.focusMinutesToday > 0
                                      ? '${_tracking.focusMinutesToday} minutes today'
                                      : 'Complete a focus session',
                                  xp: '+$focusXP',
                                ),
                                const Divider(
                                    color: AppColors.borderSubtle, height: 22),
                                _XpSourceRow(
                                  title: 'Streak bonus',
                                  subtitle: '${_tracking.streakDays} day streak',
                                  xp: '+$streakXP',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              for (final lvl in milestoneLevels)
                                Expanded(
                                  child: _MilestoneNode(
                                    level: lvl,
                                    status: milestoneStatus(lvl),
                                    done: lvl < info.level,
                                    current: lvl == info.level,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ScrolaPrimaryButton(
                    label: collectedToday
                        ? 'Collected today'
                        : readyXP > 0
                            ? 'Collect +$readyXP XP'
                            : 'Nothing to collect yet',
                    onPressed: collectedToday || readyXP <= 0
                        ? null
                        : () async {
                            final ok = await _tracking.collectDailyXP(readyXP);
                            if (ok) {
                              await HapticService.celebratory();
                            }
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

class _XpSourceRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String xp;

  const _XpSourceRow({
    required this.title,
    required this.subtitle,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.subheading().copyWith(fontSize: 15)),
              Text(
                subtitle,
                style: AppTypography.caption(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        Text(
          xp,
          style: AppTypography.numeric(
            color: AppColors.primaryAccent,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MilestoneNode extends StatelessWidget {
  final int level;
  final String status;
  final bool done;
  final bool current;

  const _MilestoneNode({
    required this.level,
    required this.status,
    required this.done,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: current
                ? AppColors.primaryAccent
                : done
                    ? AppColors.successBackground
                    : AppColors.surfaceSolid,
            border: Border.all(
              color: current
                  ? AppColors.primaryAccent
                  : done
                      ? AppColors.success
                      : AppColors.borderSubtle,
            ),
          ),
          child: Center(
            child: Text(
              '$level',
              style: AppTypography.numeric(
                color: current
                    ? AppColors.textOnAccent
                    : done
                        ? AppColors.success
                        : AppColors.secondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          status,
          style: AppTypography.caption(
            color:
                current ? AppColors.primaryAccent : AppColors.secondaryText,
          ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _XpRingPainter extends CustomPainter {
  final double progress;
  _XpRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 8;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.max(0.05, progress) * 2 * math.pi,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.accentHighlight, AppColors.primaryAccent],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_XpRingPainter old) => old.progress != progress;
}

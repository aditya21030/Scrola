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
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import 'active_focus_session_screen.dart';
import 'blocking_dashboard_screen.dart';
import 'focus_session_setup_screen.dart';
import 'scroll_detox_screen.dart';

class FocusDashboardScreen extends StatefulWidget {
  final bool showBack;

  const FocusDashboardScreen({super.key, this.showBack = true});

  @override
  State<FocusDashboardScreen> createState() => _FocusDashboardScreenState();
}

class _FocusDashboardScreenState extends State<FocusDashboardScreen> {
  final TrackingService _tracking = TrackingService();
  final FocusModeService _focus = FocusModeService();
  int _selectedMinutes = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: Listenable.merge([_tracking, _focus]),
        builder: (context, _) {
          final isActive = _focus.isActive;
          final displayTime = isActive
              ? _focus.formattedRemainingTime
              : '${_selectedMinutes.toString().padLeft(2, '0')}:00';

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                widget.showBack ? 28 : 112,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.showBack)
                    ScrolaAppBar(
                      title: 'Focus',
                      trailing: _SetupIconBtn(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FocusSessionSetupScreen(),
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Focus', style: AppTypography.title()),
                              Text(
                                '${_tracking.focusMinutesToday} min today',
                                style: AppTypography.caption(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          _SetupIconBtn(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FocusSessionSetupScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: 230,
                      height: 230,
                      child: CustomPaint(
                        painter: _FocusDottedRingPainter(
                          progress: isActive ? _focus.progress : 0.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BrainyMascot(
                              mood: BrainyMood.focused,
                              skin: _tracking.equippedSkin,
                              size: 92,
                            ),
                            Text(
                              displayTime,
                              style: AppTypography.numeric(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isActive
                                  ? 'Session in progress'
                                  : 'Ready when you are',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  IgnorePointer(
                    ignoring: isActive,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isActive ? 0.5 : 1.0,
                      child: Row(
                        children: [15, 25, 45, 60].map((m) {
                          final selected = _selectedMinutes == m;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () {
                                  HapticService.subtle();
                                  setState(() => _selectedMinutes = m);
                                },
                                child: Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 44),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primaryAccent
                                        : AppColors.surfaceSolid,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primaryAccent
                                          : AppColors.borderSubtle,
                                    ),
                                  ),
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '$m min',
                                        style: AppTypography.caption(
                                          color: selected
                                              ? AppColors.textOnAccent
                                              : AppColors.primaryText,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ScrolaPrimaryButton(
                    label: isActive
                        ? 'Open active session'
                        : 'Start focus session',
                    height: 58,
                    useMediumHaptic: false,
                    onPressed: () async {
                      HapticService.medium();
                      if (!isActive) {
                        await _focus.startSession(minutes: _selectedMinutes);
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ActiveFocusSessionScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ScrolaCard(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _FocusMetric(
                              value: '${_tracking.focusMinutesToday} min',
                              label: 'Focused today',
                            ),
                          ),
                          const VerticalDivider(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                          Expanded(
                            child: _FocusMetric(
                              value: '${_tracking.focusSessionsToday}',
                              label: 'Sessions',
                            ),
                          ),
                          const VerticalDivider(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                          Expanded(
                            child: _FocusMetric(
                              value: '${_tracking.dailyBlocksCount}',
                              label: 'Blocks today',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ScrolaCard(
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            HapticService.subtle();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BlockingDashboardScreen(),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: AppColors.primaryAccent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Blocking',
                                style: AppTypography.subheading()
                                    .copyWith(fontSize: 15),
                              ),
                              Text(
                                _tracking.isDetoxActive ||
                                        _tracking.nightBlockEnabled ||
                                        _tracking.workBlockEnabled ||
                                        _tracking.blockAtLimitEnabled
                                    ? '${_tracking.selectedPlatforms.length} apps covered'
                                    : 'Rules off',
                                style: AppTypography.caption(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ScrolaCard(
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            HapticService.subtle();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ScrollDetoxScreen(),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.spa_outlined,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Scroll Detox',
                                style: AppTypography.subheading()
                                    .copyWith(fontSize: 15),
                              ),
                              Text(
                                _tracking.isDetoxActive
                                    ? 'Detox active'
                                    : 'Plan a day',
                                style: AppTypography.caption(
                                  color: _tracking.isDetoxActive
                                      ? AppColors.success
                                      : AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
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

class _SetupIconBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _SetupIconBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.subtle();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceSolid,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Icon(
          Icons.tune_rounded,
          color: AppColors.primaryText,
          size: 20,
        ),
      ),
    );
  }
}

class _FocusMetric extends StatelessWidget {
  final String value;
  final String label;
  const _FocusMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTypography.numeric(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption(color: AppColors.secondaryText),
        ),
      ],
    );
  }
}

class _FocusDottedRingPainter extends CustomPainter {
  final double progress;
  _FocusDottedRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 8;

    const dashes = 42;
    for (int i = 0; i < dashes; i++) {
      final angle = -math.pi / 2 + (i / dashes) * 2 * math.pi;
      final active = (i / dashes) <= progress;
      canvas.drawCircle(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        active ? 2.4 : 1.6,
        Paint()
          ..color = active
              ? AppColors.primaryAccent
              : AppColors.primaryAccent.withValues(alpha: 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(_FocusDottedRingPainter old) => old.progress != progress;
}

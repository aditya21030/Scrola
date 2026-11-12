import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_toggle.dart';

class BlockingScheduleScreen extends StatefulWidget {
  const BlockingScheduleScreen({super.key});

  @override
  State<BlockingScheduleScreen> createState() => _BlockingScheduleScreenState();
}

class _BlockingScheduleScreenState extends State<BlockingScheduleScreen> {
  static const _dayKeys = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final TrackingService _tracking = TrackingService();
  late bool _nightOn;
  late bool _workOn;
  late List<bool> _nightDays;
  late List<bool> _workDays;

  @override
  void initState() {
    super.initState();
    _nightOn = _tracking.nightBlockEnabled;
    _workOn = _tracking.workBlockEnabled;
    final savedNight = _tracking.nightBlockDays.toSet();
    final savedWork = _tracking.workBlockDays.toSet();
    _nightDays = _dayKeys.map(savedNight.contains).toList();
    _workDays = _dayKeys.map(savedWork.contains).toList();
  }

  int get _blockedWeeklyHours {
    final nightDaysCount = _nightOn ? _nightDays.where((d) => d).length : 0;
    final workDaysCount = _workOn ? _workDays.where((d) => d).length : 0;
    return nightDaysCount * 9 + workDaysCount * 8;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: 'Schedule'),
              const SizedBox(height: 16),
              ScrolaCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'BLOCKED HOURS',
                            style: AppTypography.label(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_blockedWeeklyHours h this week',
                          style: AppTypography.numeric(
                            color: AppColors.primaryAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 16,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              if (_nightOn) ...[
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  width: totalWidth * (7 / 24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  width: totalWidth * (2 / 24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                              if (_workOn)
                                Positioned(
                                  left: totalWidth * (9 / 24),
                                  top: 0,
                                  bottom: 0,
                                  width: totalWidth * (8 / 24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.accentHighlight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['12 am', '6 am', '12 pm', '6 pm', '12 am']
                          .map(
                            (t) => Expanded(
                              child: Center(
                                child: Text(
                                  t,
                                  style: AppTypography.caption(
                                    color: AppColors.mutedText,
                                  ).copyWith(fontSize: 10),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _ScheduleRuleCard(
                      title: 'Night block',
                      hours: '10:00 pm – 7:00 am',
                      enabled: _nightOn,
                      days: _nightDays,
                      onToggle: (v) => setState(() => _nightOn = v),
                      onDayToggle: (i) =>
                          setState(() => _nightDays[i] = !_nightDays[i]),
                    ),
                    const SizedBox(height: 12),
                    _ScheduleRuleCard(
                      title: 'Work hours',
                      hours: '9:00 am – 5:00 pm',
                      enabled: _workOn,
                      days: _workDays,
                      onToggle: (v) => setState(() => _workOn = v),
                      onDayToggle: (i) =>
                          setState(() => _workDays[i] = !_workDays[i]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ScrolaPrimaryButton(
                label: 'Save schedule',
                useMediumHaptic: true,
                onPressed: () async {
                  await _tracking.updateBlockingConfig(
                    nightBlock: _nightOn,
                    workBlock: _workOn,
                    nightBlockDays: [
                      for (int i = 0; i < _dayKeys.length; i++)
                        if (_nightDays[i]) _dayKeys[i],
                    ],
                    workBlockDays: [
                      for (int i = 0; i < _dayKeys.length; i++)
                        if (_workDays[i]) _dayKeys[i],
                    ],
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleRuleCard extends StatelessWidget {
  final String title;
  final String hours;
  final bool enabled;
  final List<bool> days;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onDayToggle;

  const _ScheduleRuleCard({
    required this.title,
    required this.hours,
    required this.enabled,
    required this.days,
    required this.onToggle,
    required this.onDayToggle,
  });

  @override
  Widget build(BuildContext context) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTypography.subheading().copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      hours,
                      style: AppTypography.numeric(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ScrolaToggle(value: enabled, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(7, (i) {
              final active = days[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticService.subtle();
                    onDayToggle(i);
                  },
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? AppColors.primaryAccent
                          : AppColors.elevatedSurface,
                    ),
                    child: Center(
                      child: Text(
                        letters[i],
                        style: AppTypography.caption(
                          color: active
                              ? AppColors.textOnAccent
                              : AppColors.secondaryText,
                        ).copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

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
  final TrackingService _tracking = TrackingService();
  late bool _nightOn;
  late bool _workOn;
  final List<bool> _nightDays = [true, true, true, true, true, true, true];
  final List<bool> _workDays = [true, true, true, true, true, false, false];

  @override
  void initState() {
    super.initState();
    _nightOn = _tracking.nightBlockEnabled;
    _workOn = _tracking.workBlockEnabled;
  }

  int get _blockedHours {
    int h = 0;
    if (_nightOn) h += 9;
    if (_workOn) h += 8;
    return h;
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
              ScrolaAppBar(
                title: 'Schedule',
                trailing: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceSolid,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.add_rounded,
                      color: AppColors.accentHighlight,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticService.subtle();
                      setState(() => _workOn = true);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ScrolaCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BLOCKED HOURS',
                          style: AppTypography.label(
                            color: AppColors.secondaryText,
                          ),
                        ),
                        Text(
                          '$_blockedHours h on weekdays',
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
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          if (_nightOn) ...[
                            FractionallySizedBox(
                              widthFactor: 7 / 24,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FractionallySizedBox(
                                widthFactor: 2 / 24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (_workOn)
                            Align(
                              alignment: const Alignment(-0.2, 0),
                              child: FractionallySizedBox(
                                widthFactor: 8 / 24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.accentHighlight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['12 am', '6 am', '12 pm', '6 pm', '12 am']
                          .map(
                            (t) => Text(
                              t,
                              style: AppTypography.caption(
                                color: AppColors.mutedText,
                              ).copyWith(fontSize: 10),
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
                onPressed: () {
                  _tracking.updateBlockingConfig(
                    nightBlock: _nightOn,
                    workBlock: _workOn,
                  );
                  Navigator.of(context).pop();
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

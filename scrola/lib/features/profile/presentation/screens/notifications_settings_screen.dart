import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_toggle.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _warnNearLimit = true;
  final Set<String> _thresholds = {'80%', '100%'};
  bool _streakReminder = true;
  bool _focusEnd = true;
  bool _levelUps = true;
  bool _weeklyReport = false;
  bool _quietHours = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: ScrolaAppBar(title: 'Notifications'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScrolaCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: AppColors.success.withValues(alpha: 0.35),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_active_outlined,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Allowed by Android',
                              style: AppTypography.subheading()
                                  .copyWith(fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'System settings',
                            style: AppTypography.caption(
                              color: AppColors.primaryAccent,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('LIMIT ALERTS',
                        style: AppTypography.label(
                            color: AppColors.secondaryText)),
                    const SizedBox(height: 10),
                    ScrolaCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Warn me near my limit',
                                  style: AppTypography.subheading()
                                      .copyWith(fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ScrolaToggle(
                                value: _warnNearLimit,
                                onChanged: (v) =>
                                    setState(() => _warnNearLimit = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Alert when I reach',
                            style: AppTypography.caption(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (int i = 0; i < 3; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      const options = ['50%', '80%', '100%'];
                                      final pct = options[i];
                                      final selected =
                                          _thresholds.contains(pct);
                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          HapticService.subtle();
                                          setState(() {
                                            if (selected) {
                                              _thresholds.remove(pct);
                                            } else {
                                              _thresholds.add(pct);
                                            }
                                          });
                                        },
                                        child: Container(
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? AppColors.primaryAccent
                                                : AppColors.elevatedSurface,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Center(
                                            child: Text(
                                              pct,
                                              style: AppTypography.numeric(
                                                color: selected
                                                    ? AppColors.textOnAccent
                                                    : AppColors.secondaryText,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('REMINDERS',
                        style: AppTypography.label(
                            color: AppColors.secondaryText)),
                    const SizedBox(height: 10),
                    ScrolaCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _ReminderToggle(
                            title: 'Streak reminder',
                            subtitle: 'Daily at 8:00 pm',
                            value: _streakReminder,
                            onChanged: (v) =>
                                setState(() => _streakReminder = v),
                          ),
                          const Divider(
                              color: AppColors.borderSubtle, height: 22),
                          _ReminderToggle(
                            title: 'Focus session ends',
                            subtitle: 'When the timer finishes',
                            value: _focusEnd,
                            onChanged: (v) => setState(() => _focusEnd = v),
                          ),
                          const Divider(
                              color: AppColors.borderSubtle, height: 22),
                          _ReminderToggle(
                            title: 'Level-ups and badges',
                            subtitle: 'When you unlock something',
                            value: _levelUps,
                            onChanged: (v) => setState(() => _levelUps = v),
                          ),
                          const Divider(
                              color: AppColors.borderSubtle, height: 22),
                          _ReminderToggle(
                            title: 'Weekly report',
                            subtitle: 'Sundays',
                            value: _weeklyReport,
                            onChanged: (v) => setState(() => _weeklyReport = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('QUIET HOURS',
                        style: AppTypography.label(
                            color: AppColors.secondaryText)),
                    const SizedBox(height: 10),
                    ScrolaCard(
                      padding: const EdgeInsets.all(16),
                      child: _ReminderToggle(
                        title: 'Pause alerts',
                        subtitle: '10:00 pm – 7:00 am',
                        value: _quietHours,
                        onChanged: (v) => setState(() => _quietHours = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReminderToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
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
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ScrolaToggle(value: value, onChanged: onChanged),
      ],
    );
  }
}

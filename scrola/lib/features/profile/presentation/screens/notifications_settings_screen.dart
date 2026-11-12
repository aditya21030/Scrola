import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
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
  final TrackingService _tracking = TrackingService();

  @override
  void initState() {
    super.initState();
    _tracking.checkPermissions();
  }

  Future<void> _toggleThreshold(String pct, Set<String> current) async {
    HapticService.subtle();
    final updated = Set<String>.from(current);
    if (updated.contains(pct)) {
      updated.remove(pct);
    } else {
      updated.add(pct);
    }
    final ordered = [
      for (final option in const ['50%', '80%', '100%'])
        if (updated.contains(option)) option,
    ];
    await _tracking.updateNotificationConfig(thresholds: ordered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final warnNearLimit = _tracking.notifWarnNearLimit;
          final thresholds = _tracking.notifThresholds.toSet();
          final granted = _tracking.isNotificationGranted;

          return SafeArea(
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
                          borderColor: (granted
                                  ? AppColors.success
                                  : AppColors.warning)
                              .withValues(alpha: 0.35),
                          onTap: () async {
                            HapticService.light();
                            if (!granted) {
                              await _tracking.requestNotificationPermission();
                            } else {
                              await _tracking.checkPermissions();
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                granted
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_off_outlined,
                                color: granted
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  granted
                                      ? 'Allowed by Android'
                                      : 'Permission needed in Android',
                                  style: AppTypography.subheading()
                                      .copyWith(fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                granted ? 'Refresh' : 'Enable',
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
                                    value: warnNearLimit,
                                    onChanged: (v) => _tracking
                                        .updateNotificationConfig(
                                            warnNearLimit: v),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                warnNearLimit
                                    ? 'Alert when I reach'
                                    : 'Turn on limit alerts to pick thresholds',
                                style: AppTypography.caption(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 10),
                              IgnorePointer(
                                ignoring: !warnNearLimit,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity: warnNearLimit ? 1.0 : 0.4,
                                  child: Row(
                                    children: [
                                      for (int i = 0; i < 3; i++) ...[
                                        if (i > 0) const SizedBox(width: 8),
                                        Expanded(
                                          child: Builder(
                                            builder: (context) {
                                              const options = [
                                                '50%',
                                                '80%',
                                                '100%',
                                              ];
                                              final pct = options[i];
                                              final selected =
                                                  thresholds.contains(pct);
                                              return GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () => _toggleThreshold(
                                                    pct, thresholds),
                                                child: Container(
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    color: selected
                                                        ? AppColors.primaryAccent
                                                        : AppColors
                                                            .elevatedSurface,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      pct,
                                                      style:
                                                          AppTypography.numeric(
                                                        color: selected
                                                            ? AppColors
                                                                .textOnAccent
                                                            : AppColors
                                                                .secondaryText,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
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
                                ),
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
                                value: _tracking.notifStreakReminder,
                                onChanged: (v) =>
                                    _tracking.updateNotificationConfig(
                                        streakReminder: v),
                              ),
                              const Divider(
                                  color: AppColors.borderSubtle, height: 22),
                              _ReminderToggle(
                                title: 'Focus session ends',
                                subtitle: 'When the timer finishes',
                                value: _tracking.notifFocusEnd,
                                onChanged: (v) => _tracking
                                    .updateNotificationConfig(focusEnd: v),
                              ),
                              const Divider(
                                  color: AppColors.borderSubtle, height: 22),
                              _ReminderToggle(
                                title: 'Level-ups and badges',
                                subtitle: 'When you unlock something',
                                value: _tracking.notifLevelUps,
                                onChanged: (v) => _tracking
                                    .updateNotificationConfig(levelUps: v),
                              ),
                              const Divider(
                                  color: AppColors.borderSubtle, height: 22),
                              _ReminderToggle(
                                title: 'Weekly report',
                                subtitle: 'Sundays',
                                value: _tracking.notifWeeklyReport,
                                onChanged: (v) =>
                                    _tracking.updateNotificationConfig(
                                        weeklyReport: v),
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
                            value: _tracking.notifQuietHours,
                            onChanged: (v) => _tracking
                                .updateNotificationConfig(quietHours: v),
                          ),
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

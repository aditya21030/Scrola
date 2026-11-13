import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_toggle.dart';
import 'blocking_schedule_screen.dart';
import 'blocking_settings_screen.dart';
import 'scroll_detox_screen.dart';
import '../widgets/limit_reached_modal.dart';

class BlockingDashboardScreen extends StatefulWidget {
  const BlockingDashboardScreen({super.key});

  @override
  State<BlockingDashboardScreen> createState() =>
      _BlockingDashboardScreenState();
}

class _BlockingDashboardScreenState extends State<BlockingDashboardScreen> {
  final TrackingService _tracking = TrackingService();

  int _blocksThisWeek() {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final history = _tracking.dailyHistory;
    int sum = 0;
    for (int i = 0; i < 7; i++) {
      final d = todayDate.subtract(Duration(days: i));
      final key = StorageService.formatDateKey(d);
      sum += i == 0
          ? _tracking.dailyBlocksCount
          : (history[key]?['blocks'] ?? 0);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final isAnyActive = _tracking.nightBlockEnabled ||
              _tracking.workBlockEnabled ||
              _tracking.isDetoxActive ||
              _tracking.blockAtLimitEnabled;
          final weeklyBlocks = _blocksThisWeek();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Blocking',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isAnyActive
                            ? AppColors.successBackground
                            : AppColors.elevatedSurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        isAnyActive ? 'Active' : 'Off',
                        style: AppTypography.caption(
                          color: isAnyActive
                              ? AppColors.success
                              : AppColors.secondaryText,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ScrolaCard(
                    padding: const EdgeInsets.all(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.16),
                        AppColors.surfaceSolid,
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAnyActive ? 'Blocking is on' : 'Blocking is off',
                          style: AppTypography.title().copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Reels in ${_tracking.selectedPlatforms.length} apps are protected by your active rules.',
                          style: AppTypography.caption(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ScrolaCard(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _BlockingStat(
                              value: '$weeklyBlocks',
                              label: 'Blocks this week',
                            ),
                          ),
                          const VerticalDivider(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                          Expanded(
                            child: _BlockingStat(
                              value: '${_tracking.selectedPlatforms.length}',
                              label: 'Apps covered',
                            ),
                          ),
                          const VerticalDivider(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                          Expanded(
                            child: _BlockingStat(
                              value: '${_tracking.emergencyUnlocksLeft}',
                              label: 'Unlocks left',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'RULES',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  _RuleToggleTile(
                    title: 'Night schedule',
                    subtitle: '10:00 pm – 7:00 am',
                    value: _tracking.nightBlockEnabled,
                    onChanged: (v) =>
                        _tracking.updateBlockingConfig(nightBlock: v),
                  ),
                  const SizedBox(height: 10),
                  _RuleToggleTile(
                    title: 'Work hours',
                    subtitle: '9:00 am – 5:00 pm',
                    value: _tracking.workBlockEnabled,
                    onChanged: (v) =>
                        _tracking.updateBlockingConfig(workBlock: v),
                  ),
                  const SizedBox(height: 10),
                  _RuleToggleTile(
                    title: 'When daily limit is reached',
                    subtitle: 'Blocks until midnight',
                    value: _tracking.blockAtLimitEnabled,
                    onChanged: (v) =>
                        _tracking.updateBlockingConfig(blockAtLimit: v),
                  ),
                  const SizedBox(height: 10),
                  ScrolaCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      HapticService.subtle();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ScrollDetoxScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detox days',
                                style: AppTypography.subheading()
                                    .copyWith(fontSize: 15),
                              ),
                              Text(
                                'Multi-day complete break',
                                style: AppTypography.caption(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _tracking.isDetoxActive ? 'Active' : 'Off',
                          style: AppTypography.caption(
                            color: _tracking.isDetoxActive
                                ? AppColors.success
                                : AppColors.secondaryText,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.secondaryText,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ScrolaSecondaryButton(
                          label: 'Schedule',
                          onPressed: () {
                            HapticService.subtle();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BlockingScheduleScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ScrolaSecondaryButton(
                          label: 'Settings',
                          onPressed: () {
                            HapticService.subtle();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BlockingSettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ScrolaSecondaryButton(
                    label: 'Preview limit reached screen',
                    onPressed: () => LimitReachedModal.show(context),
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

class _BlockingStat extends StatelessWidget {
  final String value;
  final String label;
  const _BlockingStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.numeric(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.caption(color: AppColors.secondaryText)
              .copyWith(fontSize: 11.5),
        ),
      ],
    );
  }
}

class _RuleToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RuleToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
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
          ScrolaToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

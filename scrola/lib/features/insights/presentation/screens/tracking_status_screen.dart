import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../overlay/presentation/screens/floating_overlay_settings_screen.dart';
import '../../../overlay/presentation/screens/floating_overlay_setup_screen.dart';
import '../../../profile/presentation/screens/notifications_settings_screen.dart';

class TrackingStatusScreen extends StatefulWidget {
  const TrackingStatusScreen({super.key});

  @override
  State<TrackingStatusScreen> createState() => _TrackingStatusScreenState();
}

class _TrackingStatusScreenState extends State<TrackingStatusScreen>
    with WidgetsBindingObserver {
  final TrackingService _tracking = TrackingService();
  bool _batteryOptimized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tracking.refreshPermissionsAndSyncOverlay();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tracking.refreshPermissionsAndSyncOverlay(animateEntrance: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final accessOn = _tracking.isAccessibilityGranted;
          final overlayOn = _tracking.isOverlayGranted;
          final active = accessOn && _tracking.isTrackingEnabled && !_batteryOptimized;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScrolaAppBar(title: 'Tracking status'),
                  const SizedBox(height: 16),
                  ScrolaCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (active ? AppColors.success : AppColors.warning)
                                .withValues(alpha: 0.16),
                            border: Border.all(
                              color: (active
                                      ? AppColors.success
                                      : AppColors.warning)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(
                            active
                                ? Icons.check_circle_rounded
                                : Icons.power_settings_new_rounded,
                            color: active ? AppColors.success : AppColors.warning,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          active
                              ? 'Scrola is on'
                              : accessOn
                                  ? 'Scrola is turned off'
                                  : 'Action needed to track smoothly',
                          style: AppTypography.heading(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          active
                              ? 'Counting reels & showing Brainy in overlay'
                              : accessOn
                                  ? 'Turn on from Home or below whenever ready'
                                  : 'Accessibility permission is required',
                          style: AppTypography.caption(
                            color: AppColors.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _StatusCheckRow(
                          title: 'Scrola master switch',
                          subtitle: _tracking.isTrackingEnabled
                              ? 'Monitoring active feeds'
                              : 'Paused until you turn Scrola on',
                          isOk: _tracking.isTrackingEnabled && accessOn,
                          actionLabel: _tracking.isTrackingEnabled
                              ? 'Turn Off'
                              : 'Turn On',
                          onTap: () async {
                            if (!accessOn) {
                              _tracking.requestAccessibilityPermission();
                            } else {
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              final next = !_tracking.isTrackingEnabled;
                              await _tracking.toggleTracking(next);
                              if (next &&
                                  mounted &&
                                  _tracking.isOverlayEnabled &&
                                  !_tracking.isOverlayGranted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.surfaceSolid,
                                    content: Text(
                                      'Scrola is ON! Allow Display over other apps to show Brainy.',
                                      style: AppTypography.caption(
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Allow',
                                      textColor: AppColors.primaryAccent,
                                      onPressed: () {
                                        navigator.push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const FloatingOverlaySetupScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        _StatusCheckRow(
                          title: 'Accessibility',
                          subtitle: 'Counts reel swipes',
                          isOk: accessOn,
                          actionLabel: accessOn ? 'On' : 'Enable',
                          onTap: () => _tracking.requestAccessibilityPermission(),
                        ),
                        const SizedBox(height: 10),
                        _StatusCheckRow(
                          title: 'Floating counter',
                          subtitle: 'Shows over supported apps',
                          isOk: overlayOn,
                          actionLabel: overlayOn ? 'On' : 'Enable',
                          onTap: () {
                            if (!overlayOn) {
                              _tracking.requestOverlayPermission();
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const FloatingOverlaySettingsScreen(),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        _StatusCheckRow(
                          title: 'Notifications',
                          subtitle: 'Limit and streak nudges',
                          isOk: true,
                          actionLabel: 'On',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NotificationsSettingsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _StatusCheckRow(
                          title: 'Battery optimisation',
                          subtitle:
                              'May pause tracking in the background',
                          isOk: !_batteryOptimized,
                          actionLabel: _batteryOptimized ? 'Fix' : 'Unrestricted',
                          onTap: () {
                            HapticService.light();
                            setState(() => _batteryOptimized = false);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ScrolaPrimaryButton(
                    label: accessOn
                        ? 'Refresh permissions'
                        : 'Grant Accessibility permission',
                    useMediumHaptic: true,
                    onPressed: () {
                      if (accessOn) {
                        _tracking.checkPermissions();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tracking status verified.'),
                          ),
                        );
                      } else {
                        _tracking.requestAccessibilityPermission();
                      }
                    },
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: ScrolaLinkButton(
                      label: 'Troubleshoot tracking',
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.cardSurface,
                            title: const Text('Troubleshoot tracking'),
                            content: const Text(
                              '1. Keep Scrola Accessibility turned on in Android Settings.\n'
                              '2. Disable battery restriction for Scrola.\n'
                              '3. Lock Scrola in Recents on MIUI/OnePlus/Samsung.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text(
                                  'Got it',
                                  style: TextStyle(color: AppColors.primaryAccent),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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

class _StatusCheckRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isOk;
  final String actionLabel;
  final VoidCallback onTap;

  const _StatusCheckRow({
    required this.title,
    required this.subtitle,
    required this.isOk,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOk ? AppColors.success : AppColors.warning;

    return ScrolaCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () {
        HapticService.subtle();
        onTap();
      },
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(
              isOk ? Icons.check_rounded : Icons.priority_high_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
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
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              actionLabel,
              style: AppTypography.caption(color: color)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

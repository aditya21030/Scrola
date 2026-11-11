import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_segmented_control.dart';
import '../../../../shared/widgets/scrola_toggle.dart';
import '../../../focus/presentation/screens/blocking_dashboard_screen.dart';
import '../../../insights/presentation/screens/platform_breakdown_screen.dart';
import '../../../insights/presentation/screens/reel_limit_setup_screen.dart';
import '../../../insights/presentation/screens/tracking_status_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_wizard_screen.dart';
import '../../../overlay/presentation/screens/floating_overlay_settings_screen.dart';
import 'subscription_pro_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: tracking,
        builder: (context, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScrolaAppBar(title: 'Settings'),
                  const SizedBox(height: 18),
                  Text('TRACKING',
                      style:
                          AppTypography.label(color: AppColors.secondaryText)),
                  const SizedBox(height: 10),
                  ScrolaCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        _SettingLinkRow(
                          title: 'Platforms',
                          value: '${tracking.selectedPlatforms.length} apps',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PlatformBreakdownScreen(),
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _SettingLinkRow(
                          title: 'Daily limit',
                          value: '${tracking.totalLimit} reels',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReelLimitSetupScreen(),
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _SettingLinkRow(
                          title: 'Tracking status',
                          value: tracking.isAccessibilityGranted
                              ? 'Active'
                              : 'Setup needed',
                          valueColor: tracking.isAccessibilityGranted
                              ? AppColors.success
                              : AppColors.warning,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TrackingStatusScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('COUNTER AND BLOCKING',
                      style:
                          AppTypography.label(color: AppColors.secondaryText)),
                  const SizedBox(height: 10),
                  ScrolaCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        _SettingLinkRow(
                          title: 'Floating mascot',
                          value: tracking.isOverlayEnabled ? 'Shown' : 'Hidden',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const FloatingOverlaySettingsScreen(),
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _SettingLinkRow(
                          title: 'Blocking',
                          value: 'Rules',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BlockingDashboardScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('FEEL',
                      style:
                          AppTypography.label(color: AppColors.secondaryText)),
                  const SizedBox(height: 10),
                  ScrolaCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Haptic feedback',
                                    style: AppTypography.subheading()
                                        .copyWith(fontSize: 15),
                                  ),
                                  Text(
                                    'Tactile clicks & celebrations',
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ScrolaToggle(
                              value: tracking.hapticsEnabled,
                              onChanged: (v) =>
                                  tracking.updateHapticsConfig(enabled: v),
                            ),
                          ],
                        ),
                        if (tracking.hapticsEnabled) ...[
                          const SizedBox(height: 14),
                          ScrolaSegmentedControl<HapticIntensity>(
                            items: HapticIntensity.values,
                            selectedItem: tracking.hapticIntensity,
                            labelBuilder: (i) =>
                                i.name[0].toUpperCase() + i.name.substring(1),
                            onChanged: (i) =>
                                tracking.updateHapticsConfig(intensity: i),
                          ),
                        ],
                        const Divider(color: AppColors.borderSubtle, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reduce motion',
                              style: AppTypography.subheading()
                                  .copyWith(fontSize: 15),
                            ),
                            Text(
                              MediaQuery.of(context).disableAnimations
                                  ? 'Reduced'
                                  : 'System',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('ACCOUNT',
                      style:
                          AppTypography.label(color: AppColors.secondaryText)),
                  const SizedBox(height: 10),
                  ScrolaCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        _SettingLinkRow(
                          title: 'Subscription',
                          value: 'Free',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SubscriptionProScreen(),
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _SettingLinkRow(
                          title: 'Replay setup walkthrough',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OnboardingWizardScreen(),
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _SettingLinkRow(
                          title: 'Export my data',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data export ready as JSON.'),
                              ),
                            );
                          },
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _SettingLinkRow(
                          title: 'Delete local data',
                          titleColor: AppColors.error,
                          onTap: () {
                            HapticService.warning();
                            showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.cardSurface,
                                title: const Text('Reset local stats?'),
                                content: const Text(
                                  'Your daily counts will be cleared on this device.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      tracking.resetSession();
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(
                                      'Reset',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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

class _SettingLinkRow extends StatelessWidget {
  final String title;
  final String? value;
  final Color? titleColor;
  final Color? valueColor;
  final VoidCallback onTap;

  const _SettingLinkRow({
    required this.title,
    required this.onTap,
    this.value,
    this.titleColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticService.subtle();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.subheading(
                  color: titleColor ?? AppColors.primaryText,
                ).copyWith(fontSize: 15),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: AppTypography.caption(
                  color: valueColor ?? AppColors.secondaryText,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

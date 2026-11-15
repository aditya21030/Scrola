import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/scrola_native_bridge.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_toggle.dart';
import '../widgets/delete_account_modal.dart';

class PrivacyControlsScreen extends StatefulWidget {
  const PrivacyControlsScreen({super.key});

  @override
  State<PrivacyControlsScreen> createState() => _PrivacyControlsScreenState();
}

class _PrivacyControlsScreenState extends State<PrivacyControlsScreen> {
  bool _isPolicyExpanded = false;

  static const String publicPolicyUrl =
      'https://github.com/aditya21030/Scrola/blob/main/scrola-play-store/PRIVACY_POLICY.md';

  void _copyPolicyLink() {
    HapticService.light();
    Clipboard.setData(const ClipboardData(text: publicPolicyUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy Policy URL copied to clipboard.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScrolaAppBar(
                title: 'Privacy & Data Controls',
                trailing: GestureDetector(
                  onTap: _copyPolicyLink,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link_rounded,
                          color: AppColors.primaryAccent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Copy Link',
                        style: AppTypography.caption(
                          color: AppColors.primaryAccent,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // Top Security Assurance Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSolid,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                color: AppColors.success,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '100% Private by Design',
                                    style: AppTypography.subheading().copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your reel tracking, swipes, and daily limits are calculated strictly on your physical phone in RAM. Scrola never sells personal data and never displays third-party ads.',
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ).copyWith(height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section: Accessibility API Disclosure
                      Text(
                        'ACCESSIBILITY SERVICE PERMISSION',
                        style: AppTypography.label(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ScrolaCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.accessibility_new_rounded,
                                  color: AppColors.primaryAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Short-Form Video Detection',
                                    style: AppTypography.subheading()
                                        .copyWith(fontSize: 15),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tracking.isAccessibilityGranted
                                        ? AppColors.success
                                            .withValues(alpha: 0.2)
                                        : AppColors.warning
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tracking.isAccessibilityGranted
                                        ? 'Active'
                                        : 'Not Granted',
                                    style: AppTypography.caption(
                                      color: tracking.isAccessibilityGranted
                                          ? AppColors.success
                                          : AppColors.warning,
                                    ).copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _BulletPoint(
                              icon: Icons.check_circle_outline_rounded,
                              iconColor: AppColors.success,
                              text:
                                  'Detects when supported video players (Instagram Reels, YouTube Shorts, etc.) enter the foreground.',
                            ),
                            const SizedBox(height: 8),
                            _BulletPoint(
                              icon: Icons.block_rounded,
                              iconColor: AppColors.error,
                              text:
                                  'NEVER accesses private messages, chats, passwords, keystrokes, photos, or browsing history.',
                            ),
                            const SizedBox(height: 8),
                            _BulletPoint(
                              icon: Icons.memory_rounded,
                              iconColor: AppColors.secondaryText,
                              text:
                                  'Processed ephemerally in RAM. No raw screen content is ever saved or sent over the internet.',
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: ScrolaSecondaryButton(
                                label: 'Manage Permission in Android Settings',
                                onPressed: () {
                                  HapticService.light();
                                  ScrolaNativeBridge
                                      .openAccessibilitySettings();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section: Data & Telemetry Controls
                      Text(
                        'DATA & PRIVACY CONTROLS',
                        style: AppTypography.label(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ScrolaCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Anonymous Crash Diagnostics',
                                          style: AppTypography.subheading()
                                              .copyWith(fontSize: 15),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Share anonymized error logs to help us squash bugs. Never includes personal data.',
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ScrolaToggle(
                                    value:
                                        tracking.anonymousDiagnosticsEnabled,
                                    onChanged: (val) async {
                                      HapticService.subtle();
                                      await tracking
                                          .setAnonymousDiagnostics(val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: AppColors.borderSubtle,
                              height: 1,
                            ),
                            _ControlRow(
                              title: 'Export My Data (CSV)',
                              subtitle:
                                  'Download all your daily reel logs and focus records.',
                              icon: Icons.download_rounded,
                              onTap: () {
                                HapticService.medium();
                                final csv = tracking.buildCsvExport();
                                Clipboard.setData(ClipboardData(text: csv));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Daily tracking CSV copied to clipboard.',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              color: AppColors.borderSubtle,
                              height: 1,
                            ),
                            _ControlRow(
                              title: 'Reset Local Tracking Stats',
                              subtitle:
                                  'Clear all daily counters on this phone without deleting account.',
                              icon: Icons.refresh_rounded,
                              iconColor: AppColors.warning,
                              onTap: () {
                                HapticService.warning();
                                showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: AppColors.cardSurface,
                                    title:
                                        const Text('Reset local statistics?'),
                                    content: const Text(
                                      'Your daily watched counts will be cleared on this device. Your account and evolutions remain safe.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await tracking.resetDailyStats();
                                          if (ctx.mounted) {
                                            Navigator.of(ctx).pop();
                                          }
                                        },
                                        child: const Text(
                                          'Reset',
                                          style: TextStyle(
                                              color: AppColors.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              color: AppColors.borderSubtle,
                              height: 1,
                            ),
                            _ControlRow(
                              title: 'Delete Account & All Data',
                              subtitle:
                                  'Permanently remove cloud account and all local data.',
                              icon: Icons.delete_forever_rounded,
                              iconColor: AppColors.error,
                              titleColor: AppColors.error,
                              onTap: () {
                                DeleteAccountModal.show(
                                  context,
                                  onConfirmDelete: () async {
                                    final err = await AuthService().deleteAccount();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: err != null
                                              ? AppColors.error
                                              : AppColors.success,
                                          content: Text(
                                            err ??
                                                'Account and all associated data have been permanently deleted.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section: Full Privacy Policy Document Accordion
                      Text(
                        'FULL PRIVACY POLICY',
                        style: AppTypography.label(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ScrolaCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticService.subtle();
                                setState(() =>
                                    _isPolicyExpanded = !_isPolicyExpanded);
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.description_outlined,
                                    color: AppColors.primaryAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Read Policy Document',
                                      style: AppTypography.subheading()
                                          .copyWith(fontSize: 15),
                                    ),
                                  ),
                                  Icon(
                                    _isPolicyExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.secondaryText,
                                  ),
                                ],
                              ),
                            ),
                            if (_isPolicyExpanded) ...[
                              const Divider(
                                color: AppColors.borderSubtle,
                                height: 24,
                              ),
                              const _PolicyTextSection(
                                title: '1. What Scrola Collects',
                                body:
                                    'Scrola collects only local metrics: daily counts of short-form videos watched, remaining limits, and Brainy companion XP. If you choose to register, your email and username are securely stored in Google Firebase to enable multi-device sync.',
                              ),
                              const _PolicyTextSection(
                                title: '2. Accessibility Service Usage',
                                body:
                                    'In strict compliance with Google Play Developer Policy, Scrola uses Android Accessibility APIs only to inspect the current active package and short-video UI nodes to calculate reel consumption. Accessibility data is never logged, stored, or transmitted over any network.',
                              ),
                              const _PolicyTextSection(
                                title: '3. Zero Third-Party Advertising',
                                body:
                                    'Scrola does not include any ad-tracking SDKs or sell personal data to data brokers. Our revenue comes transparently from optional Scrola Pro subscriptions.',
                              ),
                              const _PolicyTextSection(
                                title: '4. Data Deletion Rights',
                                body:
                                    'Under GDPR, CCPA, and Google Play Data Safety standards, you may export your data or delete your account at any time with immediate effect. Contact yousfulstudio@gmail.com with subject "Scrola App" for inquiries.',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Contact & Footer
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Support: yousfulstudio@gmail.com (Subject: Scrola App)',
                              style: AppTypography.caption(
                                color: AppColors.mutedText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Scrola Team · Version 1.0.0 (Build 1)',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText.withValues(
                                  alpha: 0.5,
                                ),
                              ).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _BulletPoint({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption(color: AppColors.secondaryText)
                .copyWith(height: 1.3),
          ),
        ),
      ],
    );
  }
}

class _ControlRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const _ControlRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppColors.secondaryText,
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.subheading().copyWith(
                      fontSize: 15,
                      color: titleColor ?? AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyTextSection extends StatelessWidget {
  final String title;
  final String body;

  const _PolicyTextSection({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.subheading().copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTypography.caption(
              color: AppColors.secondaryText,
            ).copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

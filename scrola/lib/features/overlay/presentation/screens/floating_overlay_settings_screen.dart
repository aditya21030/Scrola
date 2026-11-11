import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_segmented_control.dart';
import '../../../../shared/widgets/scrola_toggle.dart';
import '../widgets/notch_pill_preview.dart';
import 'floating_overlay_preview_screen.dart';
import 'floating_overlay_setup_screen.dart';

class FloatingOverlaySettingsScreen extends StatefulWidget {
  const FloatingOverlaySettingsScreen({super.key});

  @override
  State<FloatingOverlaySettingsScreen> createState() =>
      _FloatingOverlaySettingsScreenState();
}

class _FloatingOverlaySettingsScreenState
    extends State<FloatingOverlaySettingsScreen> {
  final TrackingService _tracking = TrackingService();
  bool _reactToPace = true;
  final Map<String, bool> _showOverApps = {
    'Instagram': true,
    'YouTube': true,
    'Facebook': true,
    'Snapchat': true,
  };

  double _scaleForSize(String size) {
    switch (size) {
      case 'Small':
        return 0.85;
      case 'Large':
        return 1.08;
      default:
        return 0.94;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Counter settings',
                    trailing: ScrolaToggle(
                      value: _tracking.isOverlayEnabled,
                      onChanged: (v) => _tracking.toggleOverlay(v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      HapticService.subtle();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FloatingOverlayPreviewScreen(),
                        ),
                      );
                    },
                    child: ScrolaCard(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                      child: Column(
                        children: [
                          Container(
                            height: 92,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(22),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF5A2812),
                                  Color(0xFF241109),
                                  Color(0xFF150B07),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '9:41',
                                      style: AppTypography.caption(
                                        color: AppColors.secondaryText,
                                      ).copyWith(fontSize: 10),
                                    ),
                                    Text(
                                      '5G ▮',
                                      style: AppTypography.caption(
                                        color: AppColors.secondaryText,
                                      ).copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: NotchPillPreview(
                                    watched: _tracking.totalReelsToday,
                                    remaining: _tracking.remainingReels,
                                    expanded: _tracking.overlayExpanded,
                                    mood: _tracking.currentMood,
                                    skin: _tracking.equippedSkin,
                                    scale: _scaleForSize(_tracking.overlaySize),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        HapticService.subtle();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FloatingOverlaySetupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Style & setup wizard →',
                        style: AppTypography.caption(
                          color: AppColors.primaryAccent,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Text(
                    'COUNTER SHOWS',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  ScrolaCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoLine(
                          label: 'Reels watched',
                          value: 'Left of Brainy',
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 22),
                        _InfoLine(
                          label: 'Reels remaining',
                          value: 'Right of Brainy',
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Brainy reacts to your pace',
                                    style: AppTypography.subheading()
                                        .copyWith(fontSize: 14),
                                  ),
                                  Text(
                                    'Mood changes as you scroll',
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ScrolaToggle(
                              value: _reactToPace,
                              onChanged: (v) => setState(() => _reactToPace = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'POSITION',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  ScrolaSegmentedControl<bool>(
                    items: const [true, false],
                    selectedItem: _tracking.overlayStickToNotch,
                    labelBuilder: (stick) => stick ? 'Top centre' : 'Free',
                    onChanged: (stick) =>
                        _tracking.updateOverlayConfig(stickToNotch: stick),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SIZE',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  ScrolaSegmentedControl<String>(
                    items: const ['Small', 'Medium', 'Large'],
                    selectedItem: _tracking.overlaySize,
                    labelBuilder: (s) => s,
                    onChanged: (s) => _tracking.updateOverlayConfig(size: s),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SHOW OVER',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  ScrolaCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        _AppToggleRow(
                          platform: SocialPlatform.instagram,
                          name: 'Instagram',
                          value: _showOverApps['Instagram']!,
                          onChanged: (v) =>
                              setState(() => _showOverApps['Instagram'] = v),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _AppToggleRow(
                          platform: SocialPlatform.youtube,
                          name: 'YouTube',
                          value: _showOverApps['YouTube']!,
                          onChanged: (v) =>
                              setState(() => _showOverApps['YouTube'] = v),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _AppToggleRow(
                          platform: SocialPlatform.facebook,
                          name: 'Facebook',
                          value: _showOverApps['Facebook']!,
                          onChanged: (v) =>
                              setState(() => _showOverApps['Facebook'] = v),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _AppToggleRow(
                          platform: SocialPlatform.snapchat,
                          name: 'Snapchat',
                          value: _showOverApps['Snapchat']!,
                          onChanged: (v) =>
                              setState(() => _showOverApps['Snapchat'] = v),
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

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTypography.subheading().copyWith(fontSize: 14)),
        Text(value,
            style: AppTypography.caption(color: AppColors.secondaryText)),
      ],
    );
  }
}

class _AppToggleRow extends StatelessWidget {
  final SocialPlatform platform;
  final String name;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AppToggleRow({
    required this.platform,
    required this.name,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          PlatformIcon(platform: platform, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: AppTypography.subheading().copyWith(fontSize: 15)),
          ),
          ScrolaToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

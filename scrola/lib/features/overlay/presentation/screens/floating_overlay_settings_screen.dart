import 'package:flutter/material.dart';
import '../../../../core/services/focus_mode_service.dart';
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

  Future<void> _setOverlayEnabled(bool enabled) async {
    final started = await _tracking.toggleOverlay(enabled);
    if (!mounted || !enabled) {
      return;
    }
    if (started) {
      final isActiveOnScreen = _tracking.isTrackingEnabled ||
          _tracking.isDetoxActive ||
          FocusModeService().isEnforcing;
      if (!isActiveOnScreen) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceSolid,
            content: Text(
              'Floating mascot enabled! Turn Scrola ON from Home to show it.',
              style: AppTypography.caption(color: AppColors.primaryText),
            ),
          ),
        );
      }
      return;
    }
    if (_tracking.isOverlayGranted) {
      return;
    }
    final navigator = Navigator.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceSolid,
        content: Text(
          'Allow "Display over other apps" to show the floating mascot.',
          style: AppTypography.caption(color: AppColors.primaryText),
        ),
        action: SnackBarAction(
          label: 'Allow',
          textColor: AppColors.primaryAccent,
          onPressed: () {
            navigator.push(
              MaterialPageRoute(
                builder: (_) => const FloatingOverlaySetupScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _togglePlatform(SocialPlatform platform, bool enabled) {
    final next = List<String>.from(_tracking.selectedPlatforms);
    if (enabled) {
      if (!next.contains(platform.id)) {
        next.add(platform.id);
      }
    } else {
      if (next.length <= 1 && next.contains(platform.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceSolid,
            content: Text(
              'Keep at least one platform selected.',
              style: AppTypography.caption(color: AppColors.primaryText),
            ),
          ),
        );
        return;
      }
      next.remove(platform.id);
    }
    _tracking.updateSelectedPlatforms(next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: ScrolaAppBar(
                    title: 'Counter settings',
                    trailing: ScrolaToggle(
                      value: _tracking.isOverlayEnabled,
                      onChanged: _setOverlayEnabled,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticService.subtle();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const FloatingOverlayPreviewScreen(),
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
                                          scale: _scaleForSize(
                                              _tracking.overlaySize),
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
                        ScrolaCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Floating Brainy mascot',
                                          style: AppTypography.subheading()
                                              .copyWith(fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _tracking.isOverlayEnabled
                                              ? 'Visible above apps when Scrola is on'
                                              : 'Removed — counting runs silently',
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ScrolaToggle(
                                    value: _tracking.isOverlayEnabled,
                                    onChanged: _setOverlayEnabled,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  HapticService.light();
                                  _setOverlayEnabled(
                                      !_tracking.isOverlayEnabled);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _tracking.isOverlayEnabled
                                        ? AppColors.error
                                            .withValues(alpha: 0.12)
                                        : AppColors.primaryAccent
                                            .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _tracking.isOverlayEnabled
                                          ? AppColors.error
                                              .withValues(alpha: 0.35)
                                          : AppColors.primaryAccent
                                              .withValues(alpha: 0.40),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _tracking.isOverlayEnabled
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        size: 16,
                                        color: _tracking.isOverlayEnabled
                                            ? AppColors.error
                                            : AppColors.primaryAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _tracking.isOverlayEnabled
                                              ? 'Remove floating mascot'
                                              : 'Show floating mascot',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.caption(
                                            color: _tracking.isOverlayEnabled
                                                ? AppColors.error
                                                : AppColors.primaryAccent,
                                          ).copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              HapticService.subtle();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const FloatingOverlaySetupScreen(),
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
                          style: AppTypography.label(
                              color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 10),
                        ScrolaCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const _InfoLine(
                                label: 'Reels watched',
                                value: 'Left of Brainy',
                              ),
                              const Divider(
                                  color: AppColors.borderSubtle, height: 22),
                              const _InfoLine(
                                label: 'Reels remaining',
                                value: 'Right of Brainy',
                              ),
                              const Divider(
                                  color: AppColors.borderSubtle, height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Brainy reacts to your pace',
                                          style: AppTypography.subheading()
                                              .copyWith(fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Mood changes as you scroll',
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ScrolaToggle(
                                    value: _tracking.overlayReactToPace,
                                    onChanged: (v) => _tracking
                                        .updateOverlayConfig(reactToPace: v),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'POSITION',
                          style: AppTypography.label(
                              color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 10),
                        ScrolaSegmentedControl<bool>(
                          items: const [true, false],
                          selectedItem: _tracking.overlayStickToNotch,
                          labelBuilder: (stick) =>
                              stick ? 'Top notch' : 'Free',
                          onChanged: (stick) =>
                              _tracking.updateOverlayConfig(stickToNotch: stick),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tracking.overlayStickToNotch
                              ? 'Pinned securely at the top camera notch.'
                              : 'Free mode — drag Brainy anywhere on screen.',
                          style: AppTypography.caption(
                              color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'SIZE',
                          style: AppTypography.label(
                              color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 10),
                        ScrolaSegmentedControl<String>(
                          items: const ['Small', 'Medium', 'Large'],
                          selectedItem: _tracking.overlaySize,
                          labelBuilder: (s) => s,
                          onChanged: (s) =>
                              _tracking.updateOverlayConfig(size: s),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'SHOW OVER',
                          style: AppTypography.label(
                              color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 10),
                        ScrolaCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < SocialPlatform.values.length;
                                  i++) ...[
                                if (i > 0)
                                  const Divider(
                                    color: AppColors.borderSubtle,
                                    height: 1,
                                  ),
                                _AppToggleRow(
                                  platform: SocialPlatform.values[i],
                                  name: SocialPlatform.values[i].shortName,
                                  value: _tracking.selectedPlatforms
                                      .contains(SocialPlatform.values[i].id),
                                  onChanged: (v) => _togglePlatform(
                                    SocialPlatform.values[i],
                                    v,
                                  ),
                                ),
                              ],
                            ],
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

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: AppTypography.subheading().copyWith(fontSize: 14)),
        ),
        const SizedBox(width: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          PlatformIcon(platform: platform, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: AppTypography.subheading().copyWith(fontSize: 15)),
          ),
          const SizedBox(width: 12),
          ScrolaToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

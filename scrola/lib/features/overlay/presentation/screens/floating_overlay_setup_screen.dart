import 'package:flutter/material.dart';
import '../../../../core/services/focus_mode_service.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_toggle.dart';
import '../widgets/notch_pill_preview.dart';
import 'floating_overlay_preview_screen.dart';

class FloatingOverlaySetupScreen extends StatefulWidget {
  const FloatingOverlaySetupScreen({super.key});

  @override
  State<FloatingOverlaySetupScreen> createState() =>
      _FloatingOverlaySetupScreenState();
}

class _FloatingOverlaySetupScreenState extends State<FloatingOverlaySetupScreen>
    with WidgetsBindingObserver {
  final TrackingService _tracking = TrackingService();

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
    final tracking = _tracking;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: tracking,
        builder: (context, _) {
          final isExpanded = tracking.overlayExpanded;
          final stickToNotch = tracking.overlayStickToNotch;
          final overlayGranted = tracking.isOverlayGranted;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScrolaAppBar(title: 'Set up counter'),
                  const SizedBox(height: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!overlayGranted) ...[
                            ScrolaCard(
                              backgroundColor: AppColors.warningBackground,
                              borderColor:
                                  AppColors.warning.withValues(alpha: 0.4),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.layers_rounded,
                                        color: AppColors.warning,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Allow display over other apps',
                                          style: AppTypography.subheading()
                                              .copyWith(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Required for the floating Brainy mascot. If greyed out in Settings, open App Info → ⋮ → Allow restricted settings.',
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ScrolaPrimaryButton(
                                    label: 'Open Overlay Settings',
                                    useMediumHaptic: true,
                                    onPressed: () {
                                      tracking.requestOverlayPermission();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successBackground,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      AppColors.success.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Display over other apps allowed',
                                      style: AppTypography.caption(
                                        color: AppColors.success,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _StyleChoiceCard(
                                    title: 'Compact',
                                    subtitle: 'Brainy + numbers',
                                    selected: !isExpanded,
                                    expandedPill: false,
                                    watched: tracking.totalReelsToday,
                                    remaining: tracking.remainingReels,
                                    mood: tracking.currentMood,
                                    skin: tracking.equippedSkin,
                                    onTap: () {
                                      tracking.updateOverlayConfig(
                                          expanded: false);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StyleChoiceCard(
                                    title: 'Expanded',
                                    subtitle: 'With labels',
                                    selected: isExpanded,
                                    expandedPill: true,
                                    watched: tracking.totalReelsToday,
                                    remaining: tracking.remainingReels,
                                    mood: tracking.currentMood,
                                    skin: tracking.equippedSkin,
                                    onTap: () {
                                      tracking.updateOverlayConfig(
                                          expanded: true);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'POSITION',
                            style: AppTypography.label(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ScrolaSelectableCard(
                            isSelected: stickToNotch,
                            onTap: () {
                              tracking.updateOverlayConfig(stickToNotch: true);
                            },
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.vertical_align_top_rounded,
                                  color: AppColors.primaryAccent,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Stick to top notch',
                                        style: AppTypography.subheading()
                                            .copyWith(fontSize: 15),
                                      ),
                                      Text(
                                        'Pinned cleanly in the notch area',
                                        style: AppTypography.caption(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ScrolaSelectableCard(
                            isSelected: !stickToNotch,
                            onTap: () {
                              tracking.updateOverlayConfig(stickToNotch: false);
                            },
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.open_with_rounded,
                                  color: AppColors.secondaryText,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Free',
                                        style: AppTypography.subheading()
                                            .copyWith(fontSize: 15),
                                      ),
                                      Text(
                                        'Drag it anywhere on screen',
                                        style: AppTypography.caption(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ScrolaCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Auto-show over supported apps',
                                        style: AppTypography.subheading()
                                            .copyWith(fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Instagram, YouTube and more',
                                        style: AppTypography.caption(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ScrolaToggle(
                                  value: tracking.isOverlayEnabled,
                                  onChanged: (v) async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final ok = await tracking.toggleOverlay(v);
                                    if (!mounted || !v) return;
                                    if (!ok && !tracking.isOverlayGranted) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              AppColors.surfaceSolid,
                                          content: Text(
                                            'Tap "Open Overlay Settings" above to allow displaying over other apps.',
                                            style: AppTypography.caption(
                                              color: AppColors.primaryText,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (ok) {
                                      final isActiveOnScreen =
                                          tracking.isTrackingEnabled ||
                                              tracking.isDetoxActive ||
                                              FocusModeService().isEnforcing;
                                      if (!isActiveOnScreen) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                AppColors.surfaceSolid,
                                            content: Text(
                                              'Auto-show enabled! Turn Scrola ON from Home to display it.',
                                              style: AppTypography.caption(
                                                color: AppColors.primaryText,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Pinned at the top camera notch by default. Choose Free mode anytime if you want to drag Brainy anywhere.',
                            style: AppTypography.caption(
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ScrolaPrimaryButton(
                    label: 'Preview counter',
                    useMediumHaptic: true,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FloatingOverlayPreviewScreen(),
                        ),
                      );
                    },
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

class _StyleChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final bool expandedPill;
  final int watched;
  final int remaining;
  final BrainyMood mood;
  final BrainySkin skin;
  final VoidCallback onTap;

  const _StyleChoiceCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.expandedPill,
    required this.watched,
    required this.remaining,
    required this.mood,
    required this.skin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScrolaSelectableCard(
      isSelected: selected,
      checkPosition: ScrolaCheckPosition.none,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A210F), Color(0xFF190C07)],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '9:41',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ).copyWith(fontSize: 9),
                    ),
                    Text(
                      '5G',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ).copyWith(fontSize: 9),
                    ),
                  ],
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: NotchPillPreview(
                    watched: watched,
                    remaining: remaining,
                    expanded: expandedPill,
                    mood: mood,
                    skin: skin,
                    scale: 0.64,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                            AppTypography.subheading().copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          AppTypography.caption(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      selected ? AppColors.primaryAccent : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryAccent
                        : AppColors.border,
                    width: 1.8,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: AppColors.textOnAccent,
                      )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

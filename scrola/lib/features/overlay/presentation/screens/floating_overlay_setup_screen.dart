import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_toggle.dart';
import '../widgets/notch_pill_preview.dart';
import 'floating_overlay_preview_screen.dart';

class FloatingOverlaySetupScreen extends StatelessWidget {
  const FloatingOverlaySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: tracking,
        builder: (context, _) {
          final isExpanded = tracking.overlayExpanded;
          final stickToNotch = tracking.overlayStickToNotch;

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
                          Row(
                            children: [
                              Expanded(
                                child: _StyleChoiceCard(
                                  title: 'Compact',
                                  subtitle: 'Brainy + numbers',
                                  selected: !isExpanded,
                                  expandedPill: false,
                                  watched: tracking.totalReelsToday,
                                  remaining: tracking.remainingReels,
                                  onTap: () {
                                    HapticService.subtle();
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
                                  onTap: () {
                                    HapticService.subtle();
                                    tracking.updateOverlayConfig(
                                        expanded: true);
                                  },
                                ),
                              ),
                            ],
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
                              HapticService.subtle();
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
                                        'Stick to top centre',
                                        style: AppTypography.subheading()
                                            .copyWith(fontSize: 15),
                                      ),
                                      Text(
                                        'Brainy stays in the notch area',
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
                              HapticService.subtle();
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
                                  onChanged: (v) => tracking.toggleOverlay(v),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sits at the top centre. On phones with a camera cutout, Scrola places it just beside the cutout.',
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
  final VoidCallback onTap;

  const _StyleChoiceCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.expandedPill,
    required this.watched,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScrolaSelectableCard(
      isSelected: selected,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
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
                    scale: 0.64,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.subheading().copyWith(fontSize: 15)),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

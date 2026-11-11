import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_segmented_control.dart';
import '../../../../shared/widgets/scrola_toggle.dart';
import '../widgets/notch_pill_preview.dart';

class FloatingOverlayPreviewScreen extends StatefulWidget {
  const FloatingOverlayPreviewScreen({super.key});

  @override
  State<FloatingOverlayPreviewScreen> createState() =>
      _FloatingOverlayPreviewScreenState();
}

class _FloatingOverlayPreviewScreenState
    extends State<FloatingOverlayPreviewScreen> {
  final TrackingService _tracking = TrackingService();
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final isExpanded = _tracking.overlayExpanded;
          final stickToNotch = _tracking.overlayStickToNotch;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6A2E14),
                  Color(0xFF2A140B),
                  Color(0xFF120A06),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Simulated status bar
                  Positioned(
                    left: 24,
                    top: 10,
                    child: Text(
                      '9:41',
                      style: AppTypography.caption(
                        color: AppColors.primaryText,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Positioned(
                    right: 24,
                    top: 10,
                    child: Text(
                      '5G ▮',
                      style: AppTypography.caption(
                        color: AppColors.primaryText,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  // Mock video play icon
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 160),
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Mock side reel controls
                  Positioned(
                    right: 16,
                    bottom: 290,
                    child: Column(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Top-centered or free draggable Notch Pill
                  Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: stickToNotch
                          ? const Offset(0, 4)
                          : _dragOffset + const Offset(0, 60),
                      child: GestureDetector(
                        onPanUpdate: stickToNotch
                            ? null
                            : (d) => setState(() => _dragOffset += d.delta),
                        child: NotchPillPreview(
                          watched: _tracking.totalReelsToday,
                          remaining: _tracking.remainingReels,
                          expanded: isExpanded,
                          mood: _tracking.currentMood,
                          skin: _tracking.equippedSkin,
                          onTap: () {
                            HapticService.subtle();
                            _tracking.updateOverlayConfig(
                              expanded: !isExpanded,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Hint label
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 66),
                      child: Text(
                        stickToNotch
                            ? 'Sticks to top centre · tap pill to toggle'
                            : 'Drag pill anywhere · tap to toggle',
                        style: AppTypography.caption(
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ),
                  ),
                  // Bottom configuration sheet
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: ScrolaCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('How it looks', style: AppTypography.heading()),
                            const SizedBox(height: 14),
                            ScrolaSegmentedControl<bool>(
                              items: const [false, true],
                              selectedItem: isExpanded,
                              labelBuilder: (e) => e ? 'Expanded' : 'Compact',
                              onChanged: (e) =>
                                  _tracking.updateOverlayConfig(expanded: e),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
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
                                        'Pinned cleanly below camera cutout',
                                        style: AppTypography.caption(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ScrolaToggle(
                                  value: stickToNotch,
                                  onChanged: (v) {
                                    setState(() => _dragOffset = Offset.zero);
                                    _tracking.updateOverlayConfig(
                                      stickToNotch: v,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            ScrolaPrimaryButton(
                              label: 'Show floating mascot',
                              useMediumHaptic: true,
                              onPressed: () {
                                _tracking.toggleOverlay(true);
                                Navigator.of(context).pop();
                              },
                            ),
                            if (_tracking.isOverlayEnabled) ...[
                              const SizedBox(height: 8),
                              ScrolaLinkButton(
                                label: 'Remove floating mascot',
                                onPressed: () {
                                  _tracking.toggleOverlay(false);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
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

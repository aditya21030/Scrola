import 'package:flutter/material.dart';
import '../../../../core/services/focus_mode_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_segmented_control.dart';
import '../../../../shared/widgets/scrola_toggle.dart';
import '../widgets/notch_pill_preview.dart';
import 'floating_overlay_setup_screen.dart';

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pillScale = _scaleForSize(_tracking.overlaySize);
                  final maxSheetHeight =
                      (constraints.maxHeight * 0.56).clamp(240.0, 520.0);
                  final maxDx = ((constraints.maxWidth / 2) - 70)
                      .clamp(24.0, constraints.maxWidth);
                  final maxDy = (constraints.maxHeight - 360)
                      .clamp(40.0, constraints.maxHeight);

                  return Stack(
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
                        left: 16,
                        top: 38,
                        child: Semantics(
                          button: true,
                          label: 'Back',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(19),
                            onTap: () {
                              HapticService.subtle();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.16),
                                ),
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
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
                      // Top-centered or free draggable Notch Pill (offset below real system notch & mock status bar)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Transform.translate(
                          offset: stickToNotch
                              ? const Offset(0, 34)
                              : _dragOffset + const Offset(0, 40),
                          child: GestureDetector(
                            onPanUpdate: stickToNotch
                                ? null
                                : (d) {
                                    setState(() {
                                      final next = _dragOffset + d.delta;
                                      _dragOffset = Offset(
                                        next.dx.clamp(-maxDx, maxDx),
                                        next.dy.clamp(-12.0, maxDy),
                                      );
                                    });
                                  },
                            child: NotchPillPreview(
                              watched: _tracking.totalReelsToday,
                              remaining: _tracking.remainingReels,
                              expanded: isExpanded,
                              mood: _tracking.currentMood,
                              skin: _tracking.equippedSkin,
                              scale: pillScale,
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
                          padding: const EdgeInsets.only(top: 100),
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
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: maxSheetHeight,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'How it looks',
                                      style: AppTypography.heading(),
                                    ),
                                    const SizedBox(height: 14),
                                    ScrolaSegmentedControl<bool>(
                                      items: const [false, true],
                                      selectedItem: isExpanded,
                                      labelBuilder: (e) =>
                                          e ? 'Expanded' : 'Compact',
                                      onChanged: (e) => _tracking
                                          .updateOverlayConfig(expanded: e),
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
                                                style:
                                                    AppTypography.subheading()
                                                        .copyWith(fontSize: 15),
                                              ),
                                              Text(
                                                'Pinned cleanly below camera cutout',
                                                style: AppTypography.caption(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ScrolaToggle(
                                          value: stickToNotch,
                                          onChanged: (v) {
                                            setState(
                                                () => _dragOffset = Offset.zero);
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
                                      onPressed: () async {
                                        final navigator = Navigator.of(context);
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        final ok =
                                            await _tracking.toggleOverlay(true);
                                        if (!mounted) return;
                                        if (!ok &&
                                            !_tracking.isOverlayGranted) {
                                          await navigator.push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const FloatingOverlaySetupScreen(),
                                            ),
                                          );
                                        } else {
                                          final isActiveOnScreen =
                                              _tracking.isTrackingEnabled ||
                                                  _tracking.isDetoxActive ||
                                                  FocusModeService().isEnforcing;
                                          if (ok && !isActiveOnScreen) {
                                            messenger.showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    AppColors.surfaceSolid,
                                                content: Text(
                                                  'Floating mascot enabled! Turn Scrola ON from Home to display it.',
                                                  style: AppTypography.caption(
                                                    color:
                                                        AppColors.primaryText,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          navigator.pop();
                                        }
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

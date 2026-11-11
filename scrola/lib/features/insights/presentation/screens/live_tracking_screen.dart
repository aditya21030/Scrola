import 'package:flutter/material.dart';
import '../../../../core/services/focus_mode_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../focus/presentation/screens/active_focus_session_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  final TrackingService _tracking = TrackingService();
  final FocusModeService _focus = FocusModeService();
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final isLive = _tracking.isAccessibilityGranted;
          final remaining = _tracking.remainingReels;
          final activePlatform =
              SocialPlatformMeta.tryParse(_tracking.lastPlatform) ??
                  SocialPlatform.instagram;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Live tracking',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: (isLive ? AppColors.success : AppColors.warning)
                            .withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (isLive
                                  ? AppColors.success
                                  : AppColors.warning)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _pulseController,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isLive
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLive ? 'LIVE' : 'IDLE',
                            style: AppTypography.label(
                              color: isLive
                                  ? AppColors.success
                                  : AppColors.warning,
                            ).copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 22,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primaryAccent.withValues(alpha: 0.22),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            '${_tracking.sessionReels}',
                            style: AppTypography.heroDisplay(),
                          ),
                        ),
                        Text(
                          'reels this session',
                          style: AppTypography.subheading(
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${_tracking.totalReelsToday} ',
                                style: AppTypography.numeric(
                                  color: AppColors.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: 'of ${_tracking.totalLimit} today · ',
                                style: AppTypography.caption(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              TextSpan(
                                text: '$remaining left',
                                style: AppTypography.caption(
                                  color: AppColors.primaryAccent,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ScrolaCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            PlatformIcon(
                              platform: activePlatform,
                              size: 42,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activePlatform.reelsName,
                                    style: AppTypography.subheading(),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Session time ${_tracking.screenTimeFormatted}',
                                    style: AppTypography.numeric(
                                      color: AppColors.secondaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                remaining > 5 ? 'On pace' : 'Slow down',
                                style: AppTypography.caption(
                                  color: AppColors.success,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '10 min ago',
                              style: AppTypography.caption(
                                color: AppColors.mutedText,
                              ),
                            ),
                            Text(
                              'Now',
                              style: AppTypography.caption(
                                color: AppColors.primaryAccent,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_tracking.sessionReels / 15).clamp(0.15, 1.0),
                            minHeight: 6,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.08),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ScrolaPrimaryButton(
                    label: 'Take a 5 minute break',
                    useMediumHaptic: true,
                    onPressed: () {
                      _focus.startSession(minutes: 5);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const ActiveFocusSessionScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ScrolaSecondaryButton(
                    label: 'Reset session count',
                    onPressed: () {
                      HapticService.light();
                      _tracking.resetSession();
                      Navigator.of(context).pop();
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

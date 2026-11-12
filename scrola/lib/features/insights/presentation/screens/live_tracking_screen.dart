import 'dart:math' as math;
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
          final isLive =
              _tracking.isAccessibilityGranted && _tracking.isTrackingEnabled;
          final remaining = _tracking.remainingReels;
          final fallbackPlatform = _tracking.activePlatforms.isNotEmpty
              ? _tracking.activePlatforms.first
              : SocialPlatform.instagram;
          final activePlatform =
              SocialPlatformMeta.tryParse(_tracking.lastPlatform) ??
                  fallbackPlatform;
          final lowRemainingThreshold =
              math.max(1, (_tracking.totalLimit * 0.2).round());
          final isSlowPace = remaining <= lowRemainingThreshold;
          final sessionProgress = (_tracking.sessionReels /
                  math.max(1, _tracking.totalLimit))
              .clamp(0.0, 1.0);

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0, constraints.maxHeight - 32),
                  ),
                  child: IntrinsicHeight(
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
                              color: (isLive
                                      ? AppColors.success
                                      : AppColors.warning)
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
                                      AppColors.primaryAccent
                                          .withValues(alpha: 0.22),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${_tracking.sessionReels}',
                                    style: AppTypography.heroDisplay(),
                                  ),
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
                                      text:
                                          'of ${_tracking.totalLimit} today · ',
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
                        const SizedBox(height: 24),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activePlatform.reelsName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.subheading(),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Today est. ${_tracking.screenTimeFormatted}',
                                          style: AppTypography.numeric(
                                            color: AppColors.secondaryText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSlowPace
                                          ? AppColors.warningBackground
                                          : AppColors.successBackground,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isSlowPace ? 'Slow down' : 'On pace',
                                      style: AppTypography.caption(
                                        color: isSlowPace
                                            ? AppColors.warning
                                            : AppColors.success,
                                      ).copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Session start',
                                    style: AppTypography.caption(
                                      color: AppColors.mutedText,
                                    ),
                                  ),
                                  Text(
                                    '${_tracking.sessionReels} / ${_tracking.totalLimit}',
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
                                  value: sessionProgress,
                                  minHeight: 6,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.08),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 18),
                        ScrolaPrimaryButton(
                          label: 'Take a 5 minute break',
                          useMediumHaptic: true,
                          onPressed: () async {
                            await _focus.startSession(minutes: 5);
                            if (!context.mounted) return;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ActiveFocusSessionScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ScrolaSecondaryButton(
                          label: 'Reset session count',
                          onPressed: () async {
                            HapticService.light();
                            await _tracking.resetSession();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

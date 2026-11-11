import 'package:flutter/material.dart';
import '../../../../core/services/focus_mode_service.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../brain/presentation/screens/brain_details_screen.dart';
import '../../../brain/presentation/screens/brain_overview_screen.dart';
import '../../../brain/presentation/screens/rewards_screen.dart';
import '../../../brain/presentation/screens/streak_calendar_screen.dart';
import '../../../brain/presentation/screens/xp_progress_screen.dart';
import '../../../focus/presentation/screens/active_focus_session_screen.dart';
import '../../../focus/presentation/screens/focus_dashboard_screen.dart';
import '../../../insights/presentation/screens/live_tracking_screen.dart';
import '../../../insights/presentation/screens/platform_breakdown_screen.dart';
import '../../../insights/presentation/screens/reel_limit_setup_screen.dart';
import '../../../insights/presentation/screens/tracking_status_screen.dart';
import '../../../overlay/presentation/screens/floating_overlay_settings_screen.dart';
import '../../../overlay/presentation/screens/floating_overlay_setup_screen.dart';
import '../../../profile/presentation/screens/notifications_settings_screen.dart';
import '../widgets/brain_level_card.dart';
import '../widgets/focus_banner_card.dart';
import '../widgets/hero_gauge_section.dart';
import '../widgets/home_header.dart';
import '../widgets/notch_flight_overlay.dart';
import '../widgets/platform_breakdown_section.dart';
import '../widgets/session_stats_bar.dart';
import '../widgets/streak_week_card.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onSwitchTab;

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _mascotKey = GlobalKey();
  bool _isLaunchingToNotch = false;

  String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _handleToggleScrola(TrackingService tracking) async {
    if (!tracking.isAccessibilityGranted) {
      HapticService.light();
      _push(context, const TrackingStatusScreen());
      return;
    }

    if (tracking.isTrackingEnabled) {
      HapticService.light();
      await tracking.toggleTracking(false);
      return;
    }

    if (_isLaunchingToNotch) return;
    setState(() => _isLaunchingToNotch = true);

    await playNotchFlightAnimation(
      context: context,
      mascotKey: _mascotKey,
      mood: tracking.currentMood,
      skin: tracking.equippedSkin,
      stickToNotch: tracking.overlayStickToNotch,
      onArrive: () {
        tracking.toggleTracking(true, startOverlayNow: true);
      },
    );

    if (!mounted) return;
    setState(() => _isLaunchingToNotch = false);

    if (!tracking.isOverlayGranted && tracking.isOverlayEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceSolid,
          content: Text(
            'Scrola is ON! Enable overlay permission to dock Brainy in the notch.',
            style: AppTypography.caption(color: AppColors.primaryText),
          ),
          action: SnackBarAction(
            label: 'Allow',
            textColor: AppColors.primaryAccent,
            onPressed: () =>
                _push(context, const FloatingOverlaySetupScreen()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();
    final focus = FocusModeService();

    return ListenableBuilder(
      listenable: Listenable.merge([tracking, focus]),
      builder: (context, _) {
        final levelInfo = GamificationEngine.getLevelForXP(tracking.xpTotal);
        final stage = GamificationEngine.getStageForLevel(levelInfo.level);
        final nextStageIdx =
            GamificationEngine.evolutionStages.indexOf(stage) + 1;
        final nextEvolveLevel =
            nextStageIdx < GamificationEngine.evolutionStages.length
                ? GamificationEngine.evolutionStages[nextStageIdx].minLevel
                : levelInfo.level;

        final permissionsReady = tracking.isAccessibilityGranted;
        final isScrolaOn = permissionsReady && tracking.isTrackingEnabled;
        final greeting = _greetingForHour(DateTime.now().hour);

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          body: Stack(
            children: [
              // Warm hero top gradient (#26120A -> #101010 matching 12-home-dashboard.html)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 540,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF26120A),
                        AppColors.primaryBackground,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                height: 320,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.72,
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.30),
                        AppColors.primaryAccent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: AppColors.primaryAccent,
                  backgroundColor: AppColors.surfaceSolid,
                  onRefresh: () async {
                    HapticService.light();
                    await tracking.checkPermissions();
                    await tracking.syncFromNative();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: 118),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HomeHeader(
                          greeting: greeting,
                          userName: tracking.displayName,
                          isTracking: isScrolaOn,
                          permissionsReady: permissionsReady,
                          onTrackingTap: () =>
                              _push(context, const TrackingStatusScreen()),
                          onNotificationTap: () =>
                              _push(context, const NotificationsSettingsScreen()),
                        ),
                        HeroGaugeSection(
                          reelsToday: tracking.totalReelsToday,
                          totalLimit: tracking.totalLimit,
                          streakDays: tracking.streakDays,
                          xpToday: 20,
                          currentLevel: levelInfo.level,
                          levelTitle: stage.title,
                          mood: tracking.currentMood,
                          skin: tracking.equippedSkin,
                          isTracking: isScrolaOn,
                          permissionsReady: permissionsReady,
                          stickToNotch: tracking.overlayStickToNotch,
                          isLaunchingToNotch: _isLaunchingToNotch,
                          mascotKey: _mascotKey,
                          onToggleScrola: () => _handleToggleScrola(tracking),
                          onMascotTap: () => _push(
                            context,
                            BrainDetailsScreen(
                              initialSkin: tracking.equippedSkin,
                            ),
                          ),
                          onStreakTap: () =>
                              _push(context, const StreakCalendarScreen()),
                          onXpTap: () =>
                              _push(context, const XpProgressScreen()),
                          onLevelTap: () {
                            if (widget.onSwitchTab != null) {
                              widget.onSwitchTab!(3);
                            } else {
                              _push(context, const BrainOverviewScreen());
                            }
                          },
                          onCounterTap: () =>
                              _push(context, const ReelLimitSetupScreen()),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SessionStatsBar(
                                sessionReels: tracking.sessionReels,
                                screenTime: tracking.screenTimeFormatted,
                                resetTime: tracking.resetTimeFormatted,
                                onTap: () =>
                                    _push(context, const LiveTrackingScreen()),
                              ),
                              const SizedBox(height: 24),
                              PlatformBreakdownSection(
                                instagramReels: tracking.instagramReels,
                                instagramLimit: tracking.instagramLimit,
                                youtubeReels: tracking.youtubeReels,
                                youtubeLimit: tracking.youtubeLimit,
                                facebookReels: tracking.facebookReels,
                                facebookLimit: tracking.facebookLimit,
                                snapchatReels: tracking.snapchatReels,
                                snapchatLimit: tracking.snapchatLimit,
                                onDetailsTap: () => _push(
                                    context, const PlatformBreakdownScreen()),
                                onPlatformTap: (_) => _push(
                                    context, const PlatformBreakdownScreen()),
                              ),
                              const SizedBox(height: 24),
                              BrainLevelCard(
                                level: levelInfo.level,
                                stageTitle: stage.title,
                                currentXp: levelInfo.xpInCurrentLevel,
                                targetXp: levelInfo.xpForNextLevel,
                                nextEvolveLevel: nextEvolveLevel,
                                onRewardsTap: () =>
                                    _push(context, const RewardsScreen()),
                                onCardTap: () {
                                  if (widget.onSwitchTab != null) {
                                    widget.onSwitchTab!(3);
                                  } else {
                                    _push(context, const BrainOverviewScreen());
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                              StreakWeekCard(
                                streakDays: tracking.streakDays,
                                onCalendarTap: () =>
                                    _push(context, const StreakCalendarScreen()),
                              ),
                              const SizedBox(height: 24),
                              FocusBannerCard(
                                isFocusActive: focus.isActive,
                                formattedRemainingTime:
                                    focus.formattedRemainingTime,
                                onStartFocus: () {
                                  if (focus.isActive) {
                                    _push(context,
                                        const ActiveFocusSessionScreen());
                                  } else if (widget.onSwitchTab != null) {
                                    widget.onSwitchTab!(2);
                                  } else {
                                    _push(
                                        context, const FocusDashboardScreen());
                                  }
                                },
                              ),
                              const SizedBox(height: 18),
                              // Bottom 3-dot status strip from 12-home-dashboard.html
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSolid,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.borderSubtle,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: _StatusDotItem(
                                            label: 'Tracking',
                                            active: isScrolaOn,
                                            onTap: () => _push(context,
                                                const TrackingStatusScreen()),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: _StatusDotItem(
                                            label: 'Overlay',
                                            active: tracking.isOverlayEnabled &&
                                                tracking.isOverlayGranted,
                                            onTap: () => _push(
                                              context,
                                              tracking.isOverlayGranted
                                                  ? const FloatingOverlaySettingsScreen()
                                                  : const FloatingOverlaySetupScreen(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: _StatusDotItem(
                                            label: 'Accessibility',
                                            active:
                                                tracking.isAccessibilityGranted,
                                            onTap: () => _push(context,
                                                const TrackingStatusScreen()),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusDotItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _StatusDotItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = active ? AppColors.success : AppColors.warning;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticService.subtle();
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption(color: AppColors.secondaryText)
                .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

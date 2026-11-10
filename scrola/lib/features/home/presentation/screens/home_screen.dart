import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/services/focus_mode_service.dart';
import '../widgets/home_header.dart';
import '../widgets/hero_gauge_section.dart';
import '../widgets/session_stats_bar.dart';
import '../widgets/platform_breakdown_section.dart';
import '../widgets/brain_level_card.dart';
import '../widgets/streak_week_card.dart';
import '../widgets/focus_banner_card.dart';
import '../widgets/scrola_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentNavIndex = 0;
  final TrackingService _trackingService = TrackingService();
  final FocusModeService _focusModeService = FocusModeService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _trackingService.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-verify accessibility and overlay permissions and sync stats
      _trackingService.checkPermissions();
      _trackingService.syncFromNative();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primaryBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return ListenableBuilder(
      listenable: Listenable.merge([_trackingService, _focusModeService]),
      builder: (context, _) {
        final tracking = _trackingService;
        final focus = _focusModeService;

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          body: Stack(
            children: [
              // Ambient glow behind mascot
              Positioned(
                top: -100,
                left: MediaQuery.of(context).size.width / 2 - 180,
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.16),
                        AppColors.primaryAccent.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Main Scrollable Screen Content
              SafeArea(
                bottom: false,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // Top Header
                    SliverToBoxAdapter(
                      child: HomeHeader(
                        greeting: 'Good evening',
                        userName: 'Alex',
                        isTracking: tracking.isAccessibilityGranted,
                        onTrackingTap: () {
                          if (!tracking.isAccessibilityGranted) {
                            _showPermissionSheet(context);
                          } else {
                            _showTrackingStatusSheet(context);
                          }
                        },
                        onNotificationTap: () {
                          _showNotificationSheet(context);
                        },
                      ),
                    ),

                    // Permission Warning Banner if Accessibility is disabled
                    if (!tracking.isAccessibilityGranted)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: GestureDetector(
                            onTap: () {
                              HapticService.medium();
                              tracking.requestAccessibilityPermission();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.warningBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.warning.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Accessibility Service Required',
                                          style: AppTypography.subheading(
                                            color: AppColors.warning,
                                          ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          'Tap to enable reel tracking for Instagram, YouTube, etc.',
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                          ).copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 8),
                    ),

                    // Hero Orbit Gauge & 3D Brainy Mascot
                    SliverToBoxAdapter(
                      child: HeroGaugeSection(
                        reelsToday: tracking.totalReelsToday,
                        totalLimit: tracking.totalLimit,
                        streakDays: tracking.streakDays,
                        xpToday: 20,
                        currentLevel: tracking.currentLevel,
                        levelTitle: 'Curious',
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),

                    // 3-Column Session Stats Bar
                    SliverToBoxAdapter(
                      child: SessionStatsBar(
                        sessionReels: tracking.sessionReels,
                        screenTime: tracking.screenTimeFormatted,
                        resetTime: tracking.resetTimeFormatted,
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 28),
                    ),

                    // Platforms 2x2 Breakdown
                    SliverToBoxAdapter(
                      child: PlatformBreakdownSection(
                        instagramCount: tracking.instagramReels,
                        instagramLimit: tracking.instagramLimit,
                        youtubeCount: tracking.youtubeReels,
                        youtubeLimit: tracking.youtubeLimit,
                        facebookCount: tracking.facebookReels,
                        facebookLimit: tracking.facebookLimit,
                        snapchatCount: tracking.snapchatReels,
                        snapchatLimit: tracking.snapchatLimit,
                        onDetailsTap: () {
                          _showDetailsSheet(context);
                        },
                        onPlatformTap: (platform) {
                          _showPlatformSheet(context, platform.name);
                        },
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 28),
                    ),

                    // Brain Level & Evolution Card
                    SliverToBoxAdapter(
                      child: BrainLevelCard(
                        level: tracking.currentLevel,
                        levelTitle: 'Curious Cortex',
                        currentXP: tracking.xpTotal,
                        targetXP: 500,
                        nextEvolutionLevel: 5,
                        onRewardsTap: () {
                          _showRewardsSheet(context);
                        },
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 28),
                    ),

                    // This Week (7-Day Streak)
                    SliverToBoxAdapter(
                      child: StreakWeekCard(
                        streakDays: tracking.streakDays,
                        onCalendarTap: () {
                          _showCalendarSheet(context);
                        },
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 28),
                    ),

                    // Focus Banner Card
                    SliverToBoxAdapter(
                      child: FocusBannerCard(
                        minutes: focus.isActive ? (focus.remainingSeconds ~/ 60) : 25,
                        onStartFocus: () {
                          if (focus.isActive) {
                            focus.cancelSession();
                          } else {
                            focus.startSession(minutes: 25);
                          }
                        },
                      ),
                    ),

                    // Bottom Padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 110),
                    ),
                  ],
                ),
              ),

              // Floating Bottom Nav Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ScrolaBottomNav(
                  currentIndex: _currentNavIndex,
                  onTabSelected: (index) {
                    setState(() {
                      _currentNavIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPermissionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enable Scrola Tracking',
                style: AppTypography.heading(color: AppColors.primaryText),
              ),
              const SizedBox(height: 12),
              Text(
                'Scrola uses Android Accessibility capabilities to count reels across Instagram, YouTube, Facebook, and Snapchat, and show real-time limits.',
                style: AppTypography.body(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticService.medium();
                    Navigator.pop(ctx);
                    _trackingService.requestAccessibilityPermission();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: AppColors.textOnAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Open Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTrackingStatusSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      title: 'Tracking Active',
      content: 'Scrola Accessibility Service is running.\n\n• Reels Tracking: Active\n• Floating Overlay: Enabled\n• Auto-Blocking: Armed at 40 reels',
    );
  }

  void _showNotificationSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      title: 'Notifications',
      content: 'You are on track to beat your weekly scroll average by 28%!',
    );
  }

  void _showDetailsSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      title: 'Platforms Overview',
      content: 'Detailed breakdown of short-form consumption across Instagram, YouTube, Facebook, and Snapchat.',
    );
  }

  void _showPlatformSheet(BuildContext context, String platformName) {
    _showBottomSheet(
      context: context,
      title: platformName.toUpperCase(),
      content: 'Daily limit and auto-blocking rules configured for $platformName.',
    );
  }

  void _showRewardsSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      title: 'Brainy Rewards',
      content: 'Reach Level 5 (500 XP) to evolve Brainy into "Analytical Mind" and unlock the Neon Orange aura.',
    );
  }

  void _showCalendarSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      title: 'Streak Calendar',
      content: '7 consecutive days under your daily limit! Keep it up tomorrow to earn the "Clean Mind" badge.',
    );
  }

  void _showBottomSheet({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticService.subtle();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: AppColors.textOnAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

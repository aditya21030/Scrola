import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrola/core/services/focus_mode_service.dart';
import 'package:scrola/core/services/gamification_engine.dart';
import 'package:scrola/core/services/haptic_service.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';
import 'package:scrola/features/brain/presentation/screens/achievements_screen.dart';
import 'package:scrola/features/brain/presentation/screens/brain_collection_screen.dart';
import 'package:scrola/features/brain/presentation/screens/brain_details_screen.dart';
import 'package:scrola/features/brain/presentation/screens/brain_evolution_screen.dart';
import 'package:scrola/features/brain/presentation/screens/brain_overview_screen.dart';
import 'package:scrola/features/brain/presentation/screens/rewards_screen.dart';
import 'package:scrola/features/brain/presentation/screens/streak_calendar_screen.dart';
import 'package:scrola/features/brain/presentation/screens/xp_progress_screen.dart';
import 'package:scrola/features/focus/presentation/screens/active_focus_session_screen.dart';
import 'package:scrola/features/focus/presentation/screens/blocking_dashboard_screen.dart';
import 'package:scrola/features/focus/presentation/screens/blocking_schedule_screen.dart';
import 'package:scrola/features/focus/presentation/screens/blocking_settings_screen.dart';
import 'package:scrola/features/focus/presentation/screens/focus_dashboard_screen.dart';
import 'package:scrola/features/focus/presentation/screens/focus_session_setup_screen.dart';
import 'package:scrola/features/focus/presentation/screens/scroll_detox_screen.dart';
import 'package:scrola/features/home/presentation/screens/home_screen.dart';
import 'package:scrola/features/home/presentation/screens/main_shell.dart';
import 'package:scrola/features/home/presentation/widgets/scrola_bottom_nav.dart';
import 'package:scrola/features/insights/presentation/screens/daily_scroll_history_screen.dart';
import 'package:scrola/features/insights/presentation/screens/live_tracking_screen.dart';
import 'package:scrola/features/insights/presentation/screens/platform_breakdown_screen.dart';
import 'package:scrola/features/insights/presentation/screens/platform_limits_screen.dart';
import 'package:scrola/features/insights/presentation/screens/reel_limit_setup_screen.dart';
import 'package:scrola/features/insights/presentation/screens/tracking_status_screen.dart';
import 'package:scrola/features/onboarding/presentation/screens/onboarding_wizard_screen.dart';
import 'package:scrola/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:scrola/features/overlay/presentation/screens/floating_overlay_preview_screen.dart';
import 'package:scrola/features/overlay/presentation/screens/floating_overlay_settings_screen.dart';
import 'package:scrola/features/overlay/presentation/screens/floating_overlay_setup_screen.dart';
import 'package:scrola/features/overlay/presentation/widgets/notch_pill_preview.dart';
import 'package:scrola/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:scrola/features/profile/presentation/screens/notifications_settings_screen.dart';
import 'package:scrola/features/profile/presentation/screens/profile_screen.dart';
import 'package:scrola/features/profile/presentation/screens/settings_screen.dart';
import 'package:scrola/features/profile/presentation/screens/subscription_pro_screen.dart';
import 'package:scrola/core/services/auth_service.dart';
import 'package:scrola/features/auth/presentation/screens/create_account_screen.dart';
import 'package:scrola/features/auth/presentation/screens/login_screen.dart';
import 'package:scrola/features/auth/presentation/widgets/registration_prompt_modal.dart';
import 'package:scrola/features/focus/presentation/widgets/emergency_unlock_modal.dart';
import 'package:scrola/features/focus/presentation/widgets/limit_reached_modal.dart';
import 'package:scrola/main.dart';
import 'package:scrola/shared/widgets/platform_icon.dart';
import 'package:scrola/shared/widgets/scrola_card.dart';
import 'package:scrola/shared/widgets/scrola_toggle.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ScrolaApp renders SplashScreen and navigates cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ScrolaApp());
    expect(find.text('Scrola'), findsOneWidget);

    // Advance past SplashScreen 1900ms delay
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });

  testWidgets('MainShell renders home dashboard cleanly at 320dp width',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MainShell()),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('REELS TODAY'), findsOneWidget);
    expect(find.text('Platforms'), findsOneWidget);
    expect(find.text('Instagram Reels'), findsOneWidget);
    expect(find.text('YouTube Shorts'), findsOneWidget);
    expect(find.text('/ 20'), findsNWidgets(2));
    expect(find.text('TikTok'), findsNothing);
    expect(find.text('X Videos'), findsNothing);
    expect(find.text('Reddit Watch'), findsNothing);
    expect(find.text('Moj Reels'), findsNothing);
    expect(find.text('Brain level'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);

    // Floating streak / XP / level orbs were removed from HomeScreen hero
    expect(find.text('+20'), findsNothing);
    expect(find.text('XP'), findsNothing);
    expect(find.text('streak'), findsNothing);

    // Verify scrolling up on HomeScreen runs smoothly without layout/paint errors
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -320));
    await tester.pump(const Duration(milliseconds: 250));

    // Switch across tabs cleanly
    await tester.tap(
      find.descendant(
        of: find.byType(ScrolaBottomNav),
        matching: find.byType(GestureDetector),
      ).at(2),
    );
    await tester.pump(const Duration(milliseconds: 250));
  });

  test('GamificationEngine evaluates mood and level progression', () {
    expect(
      GamificationEngine.evaluateMood(reelsWatched: 0, dailyLimit: 40),
      BrainyMood.happy,
    );
    expect(
      GamificationEngine.evaluateMood(reelsWatched: 26, dailyLimit: 40),
      BrainyMood.neutral,
    );
    expect(
      GamificationEngine.evaluateMood(reelsWatched: 36, dailyLimit: 40),
      BrainyMood.tired,
    );
    expect(
      GamificationEngine.evaluateMood(reelsWatched: 41, dailyLimit: 40),
      BrainyMood.sad,
    );
    expect(
      GamificationEngine.evaluateMood(
        reelsWatched: 10,
        dailyLimit: 40,
        isFocusModeActive: true,
      ),
      BrainyMood.focused,
    );

    final lv4 = GamificationEngine.getLevelForXP(320);
    expect(lv4.level, 4);
    expect(
      GamificationEngine.getStageForLevel(4).name,
      'Curious Cortex',
    );
  });

  test('HapticService toggles cleanly without throwing', () async {
    HapticService.isEnabled = false;
    await HapticService.light();
    HapticService.isEnabled = true;
    HapticService.intensity = HapticIntensity.strong;
    await HapticService.subtle();
  });

  test('StorageService defaults keep Scrola off and track all short-video apps', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.getInstance();
    expect(storage.isTrackingEnabled, isFalse);
    expect(storage.platformLimitsEnabled, isFalse);
    expect(storage.overlayStickToNotch, isTrue);

    await storage.recordReel('tiktok');
    await storage.recordReel('x');
    await storage.recordReel('reddit');
    await storage.recordReel('moj');
    expect(storage.tiktokReels, 1);
    expect(storage.xReels, 1);
    expect(storage.redditReels, 1);
    expect(storage.mojReels, 1);
    expect(storage.totalReelsToday, 4);
  });

  testWidgets('WelcomeScreen and OnboardingWizardScreen fit 320dp cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Get started'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: OnboardingWizardScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('See every reel, live'), findsOneWidget);

    Future<void> advanceStep() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
    }

    await tester.tap(find.text('Skip'));
    await advanceStep();
    expect(find.textContaining('Where do you'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await advanceStep();
    expect(find.textContaining('Let Scrola count'), findsOneWidget);

    await tester.tap(find.text('Continue to Settings'));
    await advanceStep();
    expect(find.textContaining('Turn on'), findsOneWidget);

    await tester.tap(find.text("I've turned it on"));
    await advanceStep();
    expect(find.textContaining('Brainy docked'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await advanceStep();
    expect(find.text('Allow display over\nother apps'), findsOneWidget);

    await tester.tap(find.text("I've turned it on"));
    await advanceStep();
    expect(find.textContaining('Know before'), findsOneWidget);

    await tester.tap(find.text('Maybe later'));
    await advanceStep();
    expect(find.text('Setup complete'), findsOneWidget);

    await tester.tap(find.text('Choose my goal'));
    await advanceStep();
    expect(find.text('Finish setup'), findsOneWidget);
  });

  testWidgets(
      'HomeScreen Turn Scrola On runs notch flight and starts overlay reliably',
      (WidgetTester tester) async {
    const channel = MethodChannel('com.scrola.app/native');
    final recordedCalls = <MethodCall>[];
    var overlayGranted = true;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      recordedCalls.add(call);
      switch (call.method) {
        case 'isAccessibilityServiceEnabled':
          return true;
        case 'isOverlayPermissionGranted':
          return overlayGranted;
        case 'isNotificationPermissionGranted':
          return true;
        case 'startOverlayService':
          return overlayGranted;
        case 'stopOverlayService':
        case 'syncLimits':
        case 'refreshOverlayConfig':
          return true;
        case 'getNativeStats':
          return <String, dynamic>{'totalToday': 0, 'sessionCount': 0};
        default:
          return null;
      }
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tracking = TrackingService();
    await tracking.initialize();
    await tracking.toggleOverlay(true);
    await tracking.toggleTracking(false);
    await tracking.checkPermissions();
    recordedCalls.clear();

    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Turn Scrola On'), findsOneWidget);

    await tester.tap(find.text('Turn Scrola On'));
    await tester.pump();
    expect(find.text('Docking Brainy to Notch...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tracking.isTrackingEnabled, isTrue);
    expect(find.text('Scrola Active · Tap to Turn Off'), findsOneWidget);
    final startCalls = recordedCalls
        .where((c) => c.method == 'startOverlayService')
        .toList();
    expect(startCalls, hasLength(1));
    expect(
      (startCalls.single.arguments as Map)['animateEntrance'],
      isFalse,
    );

    // Concurrent lifecycle permission refreshes coalesce into a single native start
    recordedCalls.clear();
    await Future.wait([
      tracking.refreshPermissionsAndSyncOverlay(animateEntrance: true),
      tracking.refreshPermissionsAndSyncOverlay(animateEntrance: true),
    ]);
    expect(
      recordedCalls.where((c) => c.method == 'startOverlayService'),
      hasLength(1),
    );

    // Turning off then testing Turn On when overlay permission is missing
    await tester.tap(find.text('Scrola Active · Tap to Turn Off'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(tracking.isTrackingEnabled, isFalse);

    overlayGranted = false;
    await tracking.checkPermissions();
    await tester.pump();

    await tester.tap(find.text('Turn Scrola On'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tracking.isTrackingEnabled, isTrue);
    expect(
      find.text('Allow display over apps for mascot'),
      findsOneWidget,
    );

    await tester.tap(find.text('Allow display over apps for mascot'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Open Overlay Settings'), findsOneWidget);
  });

  testWidgets(
      'EditProfile, BrainDetails, Profile, Settings, and Notifications screens align cleanly at 360dp',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 804);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tracking = TrackingService();
    await tracking.initialize();

    // 1. EditProfileScreen: 6 skin cards equal height, 1-line labels, aligned rails
    await tester.pumpWidget(const MaterialApp(home: EditProfileScreen()));
    await tester.pump(const Duration(milliseconds: 200));

    final backRect = tester.getRect(find.byIcon(Icons.arrow_back_ios_new_rounded));
    final classicCardRect = tester.getRect(
      find.ancestor(
        of: find.text('Classic'),
        matching: find.byType(ScrolaSelectableCard),
      ),
    );
    final goldenCardRect = tester.getRect(
      find.ancestor(
        of: find.text('Golden'),
        matching: find.byType(ScrolaSelectableCard),
      ),
    );
    final frostCardRect = tester.getRect(
      find.ancestor(
        of: find.text('Frost'),
        matching: find.byType(ScrolaSelectableCard),
      ),
    );
    final midnightCardRect = tester.getRect(
      find.ancestor(
        of: find.text('Midnight'),
        matching: find.byType(ScrolaSelectableCard),
      ),
    );
    final saveButtonRect = tester.getRect(find.text('Save changes'));

    expect(find.text('Mint'), findsOneWidget);
    expect(find.text('Midnight'), findsOneWidget);
    expect(classicCardRect.left, closeTo(20.0, 0.5));
    expect(goldenCardRect.right, closeTo(340.0, 0.5));
    expect(frostCardRect.left, closeTo(20.0, 0.5));
    expect(midnightCardRect.right, closeTo(340.0, 0.5));
    expect(classicCardRect.height, closeTo(goldenCardRect.height, 0.5));
    expect(classicCardRect.height, closeTo(frostCardRect.height, 0.5));
    expect(classicCardRect.height, closeTo(midnightCardRect.height, 0.5));
    expect(backRect.left, greaterThanOrEqualTo(20.0));
    expect(backRect.left, lessThan(40.0)); // Aligned with 20px circle left edge
    expect(saveButtonRect.width, greaterThan(0));
    expect(tester.getSize(find.text('Classic')).height, lessThan(22));
    expect(tester.getSize(find.text('Golden')).height, lessThan(22));

    // 2. BrainDetailsScreen: all 8 mood cards visible cleanly with full labels
    await tester.pumpWidget(const MaterialApp(home: BrainDetailsScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    for (final label in [
      'Happy',
      'Neutral',
      'Tired',
      'Sad',
      'Focused',
      'Sleepy',
      'Excited',
      'Celebrating',
    ]) {
      expect(find.text(label), findsWidgets);
    }

    // 3. ProfileScreen, SettingsScreen, NotificationsSettingsScreen
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Scrola Pro'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('TRACKING'), findsOneWidget);
    expect(find.text('COUNTER AND BLOCKING'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: NotificationsSettingsScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('LIMIT ALERTS'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets(
      'Selected onboarding apps scope Home, Breakdown, and Limits screens instead of 8 apps',
      (WidgetTester tester) async {
    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'isAccessibilityServiceEnabled':
        case 'isOverlayPermissionGranted':
        case 'isNotificationPermissionGranted':
        case 'syncLimits':
        case 'refreshOverlayConfig':
          return true;
        case 'getNativeStats':
          return <String, dynamic>{'totalToday': 0, 'sessionCount': 0};
        default:
          return null;
      }
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tracking = TrackingService();
    await tracking.initialize();

    // 1. Selecting 3 apps on onboarding scopes cards and divides 40 cleanly (14/13/13)
    await tracking.completeOnboarding(
      goal: 'Reduce doomscrolling',
      dailyLimit: 40,
      platforms: ['instagram', 'tiktok', 'snapchat'],
    );

    expect(tracking.activePlatforms, [
      SocialPlatform.instagram,
      SocialPlatform.tiktok,
      SocialPlatform.snapchat,
    ]);
    expect(tracking.limitForId('instagram'), 14);
    expect(tracking.limitForId('tiktok'), 13);
    expect(tracking.limitForId('snapchat'), 13);
    expect(tracking.limitForId('youtube'), 0);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Instagram Reels'), findsOneWidget);
    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('Snapchat Spotlight'), findsOneWidget);
    expect(find.text('/ 14'), findsOneWidget);
    expect(find.text('/ 13'), findsNWidgets(2));
    expect(find.text('YouTube Shorts'), findsNothing);
    expect(find.text('Facebook Reels'), findsNothing);
    expect(find.text('X Videos'), findsNothing);
    expect(find.text('Reddit Watch'), findsNothing);
    expect(find.text('Moj Reels'), findsNothing);

    await tester.pumpWidget(const MaterialApp(home: PlatformBreakdownScreen()));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Instagram Reels'), findsOneWidget);
    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('Snapchat Spotlight'), findsOneWidget);
    expect(find.text('0 / 14 limit'), findsOneWidget);
    expect(find.text('0 / 13 limit'), findsNWidgets(2));
    expect(find.text('YouTube Shorts'), findsNothing);
    expect(find.text('Moj Reels'), findsNothing);

    await tester.pumpWidget(const MaterialApp(home: PlatformLimitsScreen()));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Instagram Reels'), findsOneWidget);
    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('Snapchat Spotlight'), findsOneWidget);
    expect(find.text('14 reels'), findsOneWidget);
    expect(find.text('13 reels'), findsNWidgets(2));
    expect(find.text('40 / 40 reels'), findsOneWidget);
    expect(find.text('All of your daily limit is assigned.'), findsOneWidget);
    expect(find.text('YouTube Shorts'), findsNothing);
    expect(find.text('Facebook Reels'), findsNothing);

    // 2. Selecting 2 apps with a 30-reel daily limit divides cleanly into 15 + 15
    await tracking.completeOnboarding(
      goal: 'Protect focus',
      dailyLimit: 30,
      platforms: ['facebook', 'reddit'],
    );

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Facebook Reels'), findsOneWidget);
    expect(find.text('Reddit Watch'), findsOneWidget);
    expect(find.text('/ 15'), findsNWidgets(2));
    expect(find.text('Instagram Reels'), findsNothing);
    expect(find.text('YouTube Shorts'), findsNothing);
    expect(find.text('TikTok'), findsNothing);
    expect(find.text('Snapchat Spotlight'), findsNothing);
    expect(find.text('X Videos'), findsNothing);
    expect(find.text('Moj Reels'), findsNothing);

    // 3. Updating daily limit in shared mode updates the 2-app split, while custom per-app mode keeps explicit caps
    await tracking.updateLimits(total: 50);
    expect(tracking.limitForId('facebook'), 25);
    expect(tracking.limitForId('reddit'), 25);

    await tracking.updateLimits(
      platformLimits: {'facebook': 32, 'reddit': 18},
      platformLimitsEnabled: true,
    );
    expect(tracking.limitForId('facebook'), 32);
    expect(tracking.limitForId('reddit'), 18);
  });

  test('GamificationEngine scales through Lv 20+ and clamps negative XP', () {
    final neg = GamificationEngine.getLevelForXP(-250);
    expect(neg.level, 1);
    expect(neg.xpInCurrentLevel, 0);

    final lv8 = GamificationEngine.getLevelForXP(1400);
    expect(lv8.level, 8);
    expect(lv8.stageNumber, 3);
    expect(lv8.title, 'Bright Mind');

    final lv12 = GamificationEngine.getLevelForXP(3300);
    expect(lv12.level, 12);
    expect(lv12.stageNumber, 5);
    expect(lv12.title, 'Explorer');

    final lv15 = GamificationEngine.getLevelForXP(5250);
    expect(lv15.level, 15);
    expect(lv15.stageNumber, 6);
    expect(lv15.title, 'Ninja Focus');

    final lv20 = GamificationEngine.getLevelForXP(9500);
    expect(lv20.level, 20);
    expect(lv20.stageNumber, 7);

    final lv21 = GamificationEngine.getLevelForXP(10500);
    expect(lv21.level, 21);
    expect(lv21.stageNumber, 8);
    expect(lv21.title, 'Wizard');

    final lv23 = GamificationEngine.getLevelForXP(12500);
    expect(lv23.level, 23);
    expect(lv23.stageNumber, 8);
    expect(lv23.title, 'Wizard');

    expect(GamificationEngine.unlockLevelForSkin(BrainySkin.classic), 1);
    expect(GamificationEngine.unlockLevelForSkin(BrainySkin.ember), 2);
    expect(GamificationEngine.unlockLevelForSkin(BrainySkin.golden), 4);
    expect(GamificationEngine.unlockLevelForSkin(BrainySkin.frost), 8);
    expect(GamificationEngine.unlockLevelForSkin(BrainySkin.mint), 12);
    expect(GamificationEngine.unlockLevelForSkin(BrainySkin.midnight), 20);
  });

  testWidgets(
      'RewardsScreen and XpProgressScreen persist claims/daily XP and fix Lv 1 nodes',
      (WidgetTester tester) async {
    StorageService.resetForTest();
    SharedPreferences.setMockInitialValues({
      'scrola_xp_total': 320, // Level 4
      'scrola_streak_days': 7,
    });
    final tracking = TrackingService();
    await tracking.resetForTest();

    await tester.pumpWidget(const MaterialApp(home: RewardsScreen()));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('3 ready'), findsOneWidget);
    expect(find.text('Level 2 reward'), findsOneWidget);

    await tester.tap(find.text('Open chest'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tracking.xpTotal, 420);

    await tester.tap(find.text('Claim').first);
    await tester.pump(const Duration(milliseconds: 250));
    expect(tracking.xpTotal, 520);

    await tester.tap(find.text('Claim').first);
    await tester.pump(const Duration(milliseconds: 250));
    expect(tracking.equippedSkin, BrainySkin.ember);
    expect(find.text('0 ready'), findsOneWidget);

    // Re-mounting RewardsScreen must NOT allow re-claiming XP or rewards
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpWidget(const MaterialApp(home: RewardsScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('0 ready'), findsOneWidget);
    expect(find.text('Opened'), findsOneWidget);
    expect(find.text('Claimed'), findsNWidgets(2));
    expect(tracking.xpTotal, 520);

    // At Level 1, XpProgressScreen shows 1..4 unique milestone nodes and collects once/day
    StorageService.resetForTest();
    SharedPreferences.setMockInitialValues({
      'scrola_xp_total': 0, // Level 1
      'scrola_streak_days': 7,
    });
    await tracking.resetForTest();

    await tester.pumpWidget(const MaterialApp(home: XpProgressScreen()));
    await tester.pump(const Duration(milliseconds: 200));

    // Big level ring "1" + single milestone node "1" (no duplicate Lv 1 node)
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Collect +30 XP'), findsOneWidget);

    await tester.tap(find.text('Collect +30 XP'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tracking.xpTotal, 30);

    // Re-mount XpProgressScreen: stays collected for today
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpWidget(const MaterialApp(home: XpProgressScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Collected today'), findsOneWidget);
    expect(tracking.xpTotal, 30);
  });

  testWidgets(
      'BrainDetailsScreen enforces skin unlock level, Collection handles empty filter, EditProfile validates fields & locks',
      (WidgetTester tester) async {
    StorageService.resetForTest();
    SharedPreferences.setMockInitialValues({
      'scrola_xp_total': 320, // Level 4
    });
    final tracking = TrackingService();
    await tracking.resetForTest();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // BrainDetailsScreen with default requiredLevel resolves Midnight -> Level 20
    await tester.pumpWidget(
      const MaterialApp(
        home: BrainDetailsScreen(initialSkin: BrainySkin.midnight),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Level 20'), findsOneWidget);
    expect(find.text('Unlock at Level 20'), findsOneWidget);

    // EditProfileScreen: locked Midnight skin cannot be equipped, empty name fails validation
    await tester.pumpWidget(const MaterialApp(home: EditProfileScreen()));
    await tester.pump(const Duration(milliseconds: 200));

    await tester.ensureVisible(find.text('Midnight'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Midnight'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Unlock Midnight Brainy at Level 20.'), findsOneWidget);
    expect(tracking.equippedSkin, BrainySkin.classic);

    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.ensureVisible(find.text('Save changes'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Save changes'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Display name cannot be empty'), findsOneWidget);
    expect(tracking.displayName, 'Alex');

    // BrainCollectionScreen: empty 'Locked' filter when all skins unlocked shows friendly state
    StorageService.resetForTest();
    SharedPreferences.setMockInitialValues({
      'scrola_xp_total': 100000, // Level 100+ (all skins unlocked)
    });
    await tracking.resetForTest();

    await tester.pumpWidget(const MaterialApp(home: BrainCollectionScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Locked'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('All Brainy skins unlocked!'), findsOneWidget);
  });

  testWidgets(
      'FocusModeService syncs pause/Detox, recovers expired timers, Settings resets daily stats, and PlatformLimits preserves caps',
      (WidgetTester tester) async {
    const channel = MethodChannel('com.scrola.app/native');
    final recordedCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      recordedCalls.add(call);
      switch (call.method) {
        case 'isAccessibilityServiceEnabled':
        case 'isOverlayPermissionGranted':
        case 'isNotificationPermissionGranted':
        case 'startOverlayService':
        case 'stopOverlayService':
        case 'syncLimits':
        case 'refreshOverlayConfig':
        case 'resetDailyStats':
          return true;
        case 'getNativeStats':
          return <String, dynamic>{'totalToday': 0, 'sessionCount': 0};
        default:
          return null;
      }
    });
    addTearDown(() async {
      await FocusModeService().cancelSession();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    StorageService.resetForTest();
    SharedPreferences.setMockInitialValues({
      'scrola_selected_platforms': ['instagram', 'tiktok'],
      'scrola_xp_total': 320,
      'scrola_detox_active': true,
    });
    final tracking = TrackingService();
    await tracking.resetForTest();

    // updateBlockingConfig syncs native flags including detoxActive
    recordedCalls.clear();
    await tracking.updateBlockingConfig(nightBlock: true, workBlock: true, strict: true);
    final syncAfterConfig = recordedCalls
        .where((c) => c.method == 'syncLimits')
        .last
        .arguments as Map;
    expect(syncAfterConfig['nightBlockEnabled'], isTrue);
    expect(syncAfterConfig['workBlockEnabled'], isTrue);
    expect(syncAfterConfig['strictBlocking'], isTrue);
    expect(syncAfterConfig['detoxActive'], isTrue);

    // Start focus session -> active apps match onboarding selection, pause turns isFocusActive false while keeping detoxActive true
    final focus = FocusModeService();
    await focus.startSession(minutes: 25);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ActiveFocusSessionScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Instagram, TikTok'), findsOneWidget);

    recordedCalls.clear();
    await focus.togglePause();
    final pauseSync = recordedCalls
        .where((c) => c.method == 'syncLimits')
        .last
        .arguments as Map;
    expect(pauseSync['isFocusActive'], isFalse);
    expect(pauseSync['detoxActive'], isTrue);

    // Canceling focus preserves Detox overlay & Detox flag
    recordedCalls.clear();
    await focus.cancelSession();
    expect(recordedCalls.where((c) => c.method == 'stopOverlayService'), isEmpty);
    expect(tracking.isDetoxActive, isTrue);

    // Expired persisted focus timer completes cleanly on initialize() and shows Done state
    final storage = await StorageService.getInstance();
    await storage.saveFocusSessionState(
      isActive: true,
      isPaused: false,
      durationMinutes: 25,
      endEpochMs: DateTime.now().millisecondsSinceEpoch - 5000,
      remainingSeconds: 10,
      blockedAttempts: 2,
    );
    await focus.initialize();
    expect(focus.isActive, isFalse);
    expect(focus.isJustCompleted, isTrue);
    expect(tracking.xpTotal, 350);
    expect(tracking.focusMinutesToday, 25);

    await tester.pumpWidget(const MaterialApp(home: ActiveFocusSessionScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Focus session complete!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Add time'), findsNothing);

    // PlatformLimitsScreen preserves custom limits when toggled off and clamps minimum to 1
    await tracking.updateLimits(
      total: 40,
      platformLimits: {'instagram': 1, 'tiktok': 39},
      platformLimitsEnabled: true,
    );
    await tracking.updateLimits(total: 50, platformLimitsEnabled: false);
    expect(tracking.savedLimitForId('instagram'), 1);
    expect(tracking.limitForId('instagram'), 25);

    await tester.pumpWidget(const MaterialApp(home: PlatformLimitsScreen()));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('1 reels'), findsOneWidget);
    // Tap '-' button on Instagram (limit 1 -> stays clamped at 1, enabling per-app limits)
    await tester.tap(find.byIcon(Icons.remove_rounded).first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('1 reels'), findsOneWidget);

    // SettingsScreen 'Delete local data' -> 'Reset' resets today's counts + native daily stats
    await storage.recordReel('instagram');
    expect(tracking.totalReelsToday, 1);

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -400));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Delete local data'));
    await tester.pump(const Duration(milliseconds: 150));
    recordedCalls.clear();
    await tester.tap(find.text('Reset'));
    await tester.pump(const Duration(milliseconds: 250));

    expect(tracking.totalReelsToday, 0);
    expect(tracking.instagramReels, 0);
    expect(recordedCalls.where((c) => c.method == 'resetDailyStats'), isNotEmpty);
  });

  testWidgets(
      'Batch 2: Notifications persistence & threshold disabling, Profile badges/join date, and Settings CSV export',
      (WidgetTester tester) async {
    StorageService.resetForTest();
    SharedPreferences.setMockInitialValues({});
    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'isAccessibilityServiceEnabled':
        case 'isOverlayPermissionGranted':
        case 'isNotificationPermissionGranted':
        case 'startOverlayService':
        case 'stopOverlayService':
        case 'syncLimits':
        case 'refreshOverlayConfig':
        case 'resetDailyStats':
          return true;
        case 'getNativeStats':
          return <String, dynamic>{'totalToday': 0, 'sessionCount': 0};
        default:
          return null;
      }
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final tracking = TrackingService();
    await tracking.resetForTest();
    await tracking.checkPermissions();
    await tracking.updateNotificationConfig(
      warnNearLimit: true,
      thresholds: const ['80%', '100%'],
    );

    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: NotificationsSettingsScreen()),
    );
    await tester.pump(const Duration(milliseconds: 150));

    // Toggle 'Warn before hitting limit' OFF -> chip '50%' stays ignored
    await tester.tap(find.byType(ScrolaToggle).first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tracking.notifWarnNearLimit, isFalse);

    await tester.tap(find.text('50%'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tracking.notifThresholds, const ['80%', '100%']);

    // Toggle back ON -> chip '50%' becomes interactive and persists
    await tester.tap(find.byType(ScrolaToggle).first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tracking.notifWarnNearLimit, isTrue);

    await tester.tap(find.text('50%'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tracking.notifThresholds, const ['50%', '80%', '100%']);

    // ProfileScreen renders dynamic joinedMonthYear and unlockedBadgeCount
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining(tracking.joinedMonthYear), findsOneWidget);
    expect(find.text('${tracking.unlockedBadgeCount}'), findsWidgets);

    // SettingsScreen 'Export my data' and CSV export verification
    expect(
      tracking.buildCsvExport(),
      contains('date,reels,limit,focus_minutes,blocks'),
    );
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -400),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Export my data'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Daily history CSV copied to clipboard.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'Batch 2: Pro, Achievements, StreakCalendar, BrainEvolution, and DailyScrollHistory fit 320dp with dynamic data',
      (WidgetTester tester) async {
    StorageService.resetForTest();
    SharedPreferences.setMockInitialValues({});
    final tracking = TrackingService();
    await tracking.resetForTest();
    await tracking.addXP(320); // Lv 3 -> Toddler stage in progress

    final stageProgress = GamificationEngine.getStageProgress(tracking.xpTotal);
    expect(stageProgress, greaterThan(0.0));
    expect(stageProgress, lessThanOrEqualTo(1.0));

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SubscriptionProScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull, reason: 'SubscriptionProScreen');

    await tester.pumpWidget(const MaterialApp(home: AchievementsScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull, reason: 'AchievementsScreen');

    await tester.pumpWidget(const MaterialApp(home: StreakCalendarScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    final streakErr = tester.takeException();
    if (streakErr is FlutterError) {
      // ignore: avoid_print
      print(streakErr.toStringDeep());
    }
    expect(streakErr, isNull, reason: 'StreakCalendarScreen');

    await tester.pumpWidget(const MaterialApp(home: BrainEvolutionScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull, reason: 'BrainEvolutionScreen');

    await tester.pumpWidget(const MaterialApp(home: DailyScrollHistoryScreen()));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull, reason: 'DailyScrollHistoryScreen');

    // Verify Achievements shows real unlocked / total count (not static '12 / 40')
    await tester.pumpWidget(const MaterialApp(home: AchievementsScreen()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.text('${tracking.unlockedBadgeCount} / ${tracking.badges.length}'),
      findsOneWidget,
    );
    expect(find.text('12 / 40'), findsNothing);
  });

  testWidgets(
      'Batch 2: Onboarding replay preserves settings & Tracking goal disables auto-block',
      (WidgetTester tester) async {
    StorageService.resetForTest();
    SharedPreferences.setMockInitialValues({});
    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'isAccessibilityServiceEnabled':
        case 'isOverlayPermissionGranted':
        case 'isNotificationPermissionGranted':
          return false;
        default:
          return true;
      }
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final tracking = TrackingService();
    await tracking.resetForTest();
    await tracking.updateOverlayConfig(expanded: false);
    await tracking.updateNotificationConfig(warnNearLimit: false);
    await tracking.updateLimits(total: 70);

    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: OnboardingWizardScreen(isReplay: true)),
    );
    await tester.pump(const Duration(milliseconds: 250));

    Future<void> stepDelay() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
    }

    await tester.tap(find.text('Skip'));
    await stepDelay();
    expect(find.textContaining('Where do you'), findsOneWidget);

    // Verify back navigation using PopScope / step history
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await stepDelay();
    expect(find.text('See every reel, live'), findsOneWidget);

    // Verify completeOnboarding with 'Just track for now' goal disables auto-block on initial setup
    await tracking.completeOnboarding(
      goal: 'Just track for now',
      dailyLimit: 70,
      platforms: ['instagram', 'youtube'],
      preserveExistingSettings: false,
    );

    expect(tracking.selectedGoal, 'Just track for now');
    expect(tracking.blockAtLimitEnabled, isFalse);
    expect(tracking.overlayExpanded, isFalse);
    expect(tracking.notifWarnNearLimit, isFalse);
  });

  testWidgets(
      'Batch 2: Blocking dashboard, Schedule days/timeline, Detox persistence, and Overlay screens work cleanly at 320dp',
      (WidgetTester tester) async {
    StorageService.resetForTest();
    SharedPreferences.setMockInitialValues({});
    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'isAccessibilityServiceEnabled':
        case 'isOverlayPermissionGranted':
        case 'isNotificationPermissionGranted':
        case 'startOverlayService':
        case 'stopOverlayService':
        case 'syncLimits':
        case 'refreshOverlayConfig':
        case 'resetDailyStats':
          return true;
        case 'getNativeStats':
          return <String, dynamic>{'totalToday': 0, 'sessionCount': 0};
        default:
          return null;
      }
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final tracking = TrackingService();
    await tracking.resetForTest();
    await tracking.checkPermissions();

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // BlockingDashboardScreen reflects persisted blockAtLimitEnabled toggle (3rd toggle in rules)
    await tester.pumpWidget(
      const MaterialApp(home: BlockingDashboardScreen()),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull, reason: 'BlockingDashboardScreen');
    expect(tracking.blockAtLimitEnabled, isTrue);
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -250),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byType(ScrolaToggle).at(2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tracking.blockAtLimitEnabled, isFalse);

    // BlockingScheduleScreen renders cleanly & saves schedule config
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => const BlockingScheduleScreen(),
                ),
              ),
              child: const Text('OpenSchedule'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('OpenSchedule'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'BlockingScheduleScreen');
    await tester.tap(find.text('Save schedule'));
    await tester.pumpAndSettle();

    // ScrollDetoxScreen persists selected 7-day duration
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => const ScrollDetoxScreen(),
                ),
              ),
              child: const Text('OpenDetox'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('OpenDetox'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('7'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Start 7 day detox'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(tracking.isDetoxActive, isTrue);
    expect(tracking.detoxDays, 7);

    // NotchPillPreview at scale 0.64 & FloatingOverlayPreviewScreen / Settings fit 320dp
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: NotchPillPreview(
              watched: 12,
              remaining: 38,
              expanded: true,
              scale: 0.64,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const MaterialApp(home: FloatingOverlayPreviewScreen()),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const MaterialApp(home: FloatingOverlaySettingsScreen()),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'ActiveFocusSessionScreen renders cleanly at constrained 320x520 viewport',
      (WidgetTester tester) async {
    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      return true;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final tracking = TrackingService();
    await tracking.resetForTest();
    await tracking.checkPermissions();

    final focus = FocusModeService();
    await focus.startSession(minutes: 25);

    tester.view.physicalSize = const Size(320, 520);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: ActiveFocusSessionScreen()),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull,
        reason: 'ActiveFocusSessionScreen initial render at 320x520');

    expect(find.text('Focus session'), findsOneWidget);
    expect(find.text('Blocking on'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);

    // Toggle Pause
    await tester.tap(find.text('Pause'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(focus.isPaused, isTrue);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);

    // Toggle Resume
    await tester.tap(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(focus.isPaused, isFalse);
    expect(find.text('Pause'), findsOneWidget);

    // Add 5 min
    await tester.tap(find.text('+5 min'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(focus.totalDurationSeconds, 30 * 60);

    // Cancel Session
    await focus.cancelSession();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Done'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Full App Suite: All feature screens render cleanly without overflow at 320x560',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 560);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final screens = <WidgetBuilder>[
      (_) => const AchievementsScreen(),
      (_) => const BrainCollectionScreen(),
      (_) => const BrainDetailsScreen(),
      (_) => const BrainEvolutionScreen(),
      (_) => const BrainOverviewScreen(),
      (_) => const RewardsScreen(),
      (_) => const StreakCalendarScreen(),
      (_) => const XpProgressScreen(),
      (_) => const ActiveFocusSessionScreen(),
      (_) => const BlockingDashboardScreen(),
      (_) => const BlockingScheduleScreen(),
      (_) => const BlockingSettingsScreen(),
      (_) => const FocusDashboardScreen(),
      (_) => const FocusSessionSetupScreen(),
      (_) => const ScrollDetoxScreen(),
      (_) => const HomeScreen(),
      (_) => const DailyScrollHistoryScreen(),
      (_) => const LiveTrackingScreen(),
      (_) => const PlatformBreakdownScreen(),
      (_) => const PlatformLimitsScreen(),
      (_) => const ReelLimitSetupScreen(),
      (_) => const TrackingStatusScreen(),
      (_) => const OnboardingWizardScreen(),
      (_) => const WelcomeScreen(),
      (_) => const FloatingOverlayPreviewScreen(),
      (_) => const FloatingOverlaySettingsScreen(),
      (_) => const FloatingOverlaySetupScreen(),
      (_) => const EditProfileScreen(),
      (_) => const NotificationsSettingsScreen(),
      (_) => const ProfileScreen(),
      (_) => const SettingsScreen(),
      (_) => const SubscriptionProScreen(),
    ];

    for (final builder in screens) {
      await tester.pumpWidget(MaterialApp(home: Builder(builder: builder)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
      'Auth screens, RegistrationPromptModal, LimitReachedModal, and EmergencyUnlockModal render cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. AuthService guest check
    expect(AuthService().isGuest, isTrue);

    // 2. LoginScreen renders
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);

    // 3. CreateAccountScreen renders
    await tester.pumpWidget(const MaterialApp(home: CreateAccountScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Create account'), findsWidgets);

    // 4. RegistrationPromptModal renders
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RegistrationPromptModal()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Save your streak & progress'), findsOneWidget);
    expect(find.text('Create free account'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);

    // 5. LimitReachedModal renders
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LimitReachedModal()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text("That's your limit for today"), findsOneWidget);
    expect(find.text('Limit reached'), findsOneWidget);
    expect(find.text('Back to Scrola'), findsOneWidget);

    // 6. EmergencyUnlockModal renders
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EmergencyUnlockModal()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Unlock for 5 minutes?'), findsOneWidget);
    expect(find.text('Keep it locked'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrola/core/services/gamification_engine.dart';
import 'package:scrola/core/services/haptic_service.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';
import 'package:scrola/features/brain/presentation/screens/brain_details_screen.dart';
import 'package:scrola/features/home/presentation/screens/home_screen.dart';
import 'package:scrola/features/home/presentation/screens/main_shell.dart';
import 'package:scrola/features/home/presentation/widgets/scrola_bottom_nav.dart';
import 'package:scrola/features/insights/presentation/screens/platform_breakdown_screen.dart';
import 'package:scrola/features/insights/presentation/screens/platform_limits_screen.dart';
import 'package:scrola/features/onboarding/presentation/screens/onboarding_wizard_screen.dart';
import 'package:scrola/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:scrola/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:scrola/features/profile/presentation/screens/notifications_settings_screen.dart';
import 'package:scrola/features/profile/presentation/screens/profile_screen.dart';
import 'package:scrola/features/profile/presentation/screens/settings_screen.dart';
import 'package:scrola/main.dart';
import 'package:scrola/shared/widgets/platform_icon.dart';
import 'package:scrola/shared/widgets/scrola_card.dart';

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
    expect(find.text('Permissions ready'), findsOneWidget);

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

    // 1. EditProfileScreen: skin cards equal height, 1-line labels, aligned rails
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
    final saveButtonRect = tester.getRect(find.text('Save changes'));

    expect(classicCardRect.left, closeTo(20.0, 0.5));
    expect(frostCardRect.right, closeTo(340.0, 0.5));
    expect(classicCardRect.height, closeTo(goldenCardRect.height, 0.5));
    expect(classicCardRect.height, closeTo(frostCardRect.height, 0.5));
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
}

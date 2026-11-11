import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrola/core/services/gamification_engine.dart';
import 'package:scrola/core/services/haptic_service.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/features/home/presentation/screens/main_shell.dart';
import 'package:scrola/features/home/presentation/widgets/scrola_bottom_nav.dart';
import 'package:scrola/features/onboarding/presentation/screens/onboarding_wizard_screen.dart';
import 'package:scrola/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:scrola/main.dart';

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
    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('X Videos'), findsOneWidget);
    expect(find.text('Reddit Watch'), findsOneWidget);
    expect(find.text('Moj Reels'), findsOneWidget);
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
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrola/core/services/gamification_engine.dart';
import 'package:scrola/core/services/haptic_service.dart';
import 'package:scrola/features/home/presentation/screens/main_shell.dart';
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
    expect(find.text('Brain level'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);

    // Switch across tabs cleanly
    await tester.tap(find.byType(GestureDetector).at(2));
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
}

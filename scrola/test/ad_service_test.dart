import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/ad_service.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTest();
    AdService.isTesting = true;

    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      return true;
    });
  });

  tearDown(() {
    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Rewarded Video Ads & Pro Ad-Free Rules', () {
    testWidgets('Placement 1: Free user consumes notch then watches rewarded ad to earn +1 session',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Test'))));
      final context = tester.element(find.text('Test'));

      final storage = await StorageService.getInstance();
      final tracking = TrackingService();
      await storage.resetFreeNotchForTest();

      // Free user uses their 1 free session
      await storage.consumeFreeNotchSession();
      expect(storage.canUseNotch, isFalse);

      // User watches rewarded ad for notch session
      final ok = await AdService().showRewardedAd(
        context: context,
        placement: ScrolaAdPlacement.notchSession,
      );

      expect(ok, isTrue);
      expect(tracking.canUseNotch, isTrue);
    });

    testWidgets('Placement 2: Rewarded ad grants instant 5-min emergency unlock',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Test'))));
      final context = tester.element(find.text('Test'));

      final ok = await AdService().showRewardedAd(
        context: context,
        placement: ScrolaAdPlacement.emergencyUnlock,
      );

      expect(ok, isTrue);
    });

    testWidgets('Placement 3: Rewarded ad repairs/shields streak',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Test'))));
      final context = tester.element(find.text('Test'));

      final storage = await StorageService.getInstance();
      expect(storage.streakDays, equals(0));

      final ok = await AdService().showRewardedAd(
        context: context,
        placement: ScrolaAdPlacement.streakRepair,
      );

      expect(ok, isTrue);
      expect(storage.streakDays, greaterThanOrEqualTo(1));
    });

    testWidgets('Placement 4: Rewarded ad grants +50 Bonus XP',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Test'))));
      final context = tester.element(find.text('Test'));

      final storage = await StorageService.getInstance();
      final startXP = storage.xpTotal;

      final ok = await AdService().showRewardedAd(
        context: context,
        placement: ScrolaAdPlacement.bonusXp,
      );

      expect(ok, isTrue);
      expect(storage.xpTotal, equals(startXP + 50));
    });

    testWidgets('Pro User Rule: Pro subscribers get instant rewards with ZERO ADS',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Test'))));
      final context = tester.element(find.text('Test'));

      final storage = await StorageService.getInstance();
      await storage.setProSubscription(subscribed: true, plan: 'yearly');

      expect(storage.isProSubscribed, isTrue);

      // Calling showRewardedAd returns immediately without showing any ad
      final ok = await AdService().showRewardedAd(
        context: context,
        placement: ScrolaAdPlacement.bonusXp,
      );

      expect(ok, isTrue);
    });
  });
}

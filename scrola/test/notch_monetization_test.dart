import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Scrola Notch Monetization & Pro Gating Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTest();
    });

    test('Fresh user starts with 0 notch sessions and canUseNotch is true', () async {
      final storage = await StorageService.getInstance();
      await storage.resetFreeNotchForTest();

      expect(storage.isProSubscribed, isFalse);
      expect(storage.freeNotchSessionsUsed, equals(0));
      expect(storage.canUseNotch, isTrue);
    });

    test('Free user consumes exactly 1 session, then canUseNotch becomes false', () async {
      final storage = await StorageService.getInstance();
      await storage.resetFreeNotchForTest();

      expect(storage.canUseNotch, isTrue);

      // Consume first session
      await storage.consumeFreeNotchSession();
      expect(storage.freeNotchSessionsUsed, equals(1));
      expect(storage.canUseNotch, isFalse);

      // Further attempts should remain false for free user
      await storage.consumeFreeNotchSession();
      expect(storage.freeNotchSessionsUsed, equals(2));
      expect(storage.canUseNotch, isFalse);
    });

    test('Upgrading to Pro unlocks notch counter regardless of sessions used', () async {
      final storage = await StorageService.getInstance();
      await storage.resetFreeNotchForTest();
      await storage.consumeFreeNotchSession();
      expect(storage.canUseNotch, isFalse);

      // Subscribe to Pro (monthly / yearly / lifetime)
      await storage.setProSubscription(subscribed: true, plan: 'yearly');
      expect(storage.isProSubscribed, isTrue);
      expect(storage.proPlan, equals('yearly'));
      expect(storage.canUseNotch, isTrue);

      // Changing plan to lifetime maintains Pro
      await storage.setProSubscription(subscribed: true, plan: 'lifetime');
      expect(storage.isProSubscribed, isTrue);
      expect(storage.proPlan, equals('lifetime'));
      expect(storage.canUseNotch, isTrue);
    });

    test('Reverting Pro locks notch if free sessions were already consumed', () async {
      final storage = await StorageService.getInstance();
      await storage.resetFreeNotchForTest();
      await storage.consumeFreeNotchSession();
      await storage.setProSubscription(subscribed: true, plan: 'monthly');
      expect(storage.canUseNotch, isTrue);

      // Revert subscription
      await storage.setProSubscription(subscribed: false);
      expect(storage.isProSubscribed, isFalse);
      expect(storage.canUseNotch, isFalse);
    });
  });
}

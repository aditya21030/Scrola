import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTest();
  });

  group('Free mode limit & 24hr cycle tests', () {
    test('Free mode limit over blocks notch and turns canUseNotch false', () async {
      final storage = await StorageService.getInstance();
      await storage.setLimits(total: 10);
      expect(storage.canUseNotch, isTrue);

      // Record 10 reels (reaching the daily limit in free mode)
      for (int i = 0; i < 10; i++) {
        await storage.recordReel('instagram');
      }

      expect(storage.totalReelsToday, 10);
      expect(storage.canUseNotch, isFalse,
          reason: 'Once free daily limit is reached, notch tracking is blocked');
    });

    test('24 hour cycle resets freeNotchSessionsUsed and counts', () async {
      final storage = await StorageService.getInstance();
      await storage.setLimits(total: 20);
      await storage.consumeFreeNotchSession();
      expect(storage.freeNotchSessionsUsed, 1);

      // Force a new day via resetDailyStats
      await storage.resetDailyStats();
      expect(storage.freeNotchSessionsUsed, 0,
          reason: 'Daily reset restores free notch session');
      expect(storage.totalReelsToday, 0);
    });

    test('Username saves reliably in StorageService', () async {
      final storage = await StorageService.getInstance();
      await storage.setProfile(
        displayName: 'Aditya Jain',
        username: 'aditya_pro',
        email: 'aditya@example.com',
      );

      expect(storage.displayName, 'Aditya Jain');
      expect(storage.username, 'aditya_pro');
      expect(storage.email, 'aditya@example.com');
    });

    test('Pro subscriber always has canUseNotch enabled', () async {
      final storage = await StorageService.getInstance();
      await storage.setLimits(total: 5);
      for (int i = 0; i < 10; i++) {
        await storage.recordReel('youtube');
      }
      await storage.setProSubscription(subscribed: true, plan: 'yearly');

      expect(storage.isProSubscribed, isTrue);
      expect(storage.canUseNotch, isTrue,
          reason: 'Pro subscriber gets unlimited notch even past limit');
    });
  });
}

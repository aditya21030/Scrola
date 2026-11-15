import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';
import 'package:scrola/features/home/presentation/screens/home_screen.dart';
import 'package:scrola/features/profile/presentation/widgets/notch_pro_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTest();

    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'isAccessibilityServiceEnabled':
          return true;
        case 'isOverlayPermissionGranted':
          return true;
        case 'isNotificationPermissionGranted':
          return true;
        case 'startOverlayService':
          return true;
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
  });

  tearDown(() {
    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('Grace period allows finishing 40 reel session if only 8 watched', () async {
    final storage = await StorageService.getInstance();
    await storage.resetFreeNotchForTest();
    await storage.setLimits(total: 40);

    // Free session started, watched 8 reels
    for (int i = 0; i < 8; i++) {
      await storage.recordReel('instagram');
    }
    expect(storage.totalReelsToday, equals(8));

    // Even if marked with 1 session used from previous launch
    await storage.consumeFreeNotchSession();
    expect(storage.freeNotchSessionsUsed, equals(1));

    // canUseNotch remains TRUE because user is still finishing their 40 reel trial (8 < 40)
    expect(storage.canUseNotch, isTrue);

    // Watch up to 40 reels
    for (int i = 0; i < 32; i++) {
      await storage.recordReel('instagram');
    }
    expect(storage.totalReelsToday, equals(40));

    // Now that limit is reached, canUseNotch is false
    expect(storage.canUseNotch, isFalse);
  });

  testWidgets('When canUseNotch is false, tapping Scrola toggle shows NotchProModal', (tester) async {
    final storage = await StorageService.getInstance();
    await storage.resetFreeNotchForTest();
    await storage.consumeFreeNotchSession();
    await storage.consumeFreeNotchSession(); // ensure completely locked
    expect(storage.canUseNotch, isFalse);

    final tracking = TrackingService();
    await tracking.resetForTest();
    await tracking.initialize();
    await tracking.checkPermissions();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Tap Turn Scrola On hero toggle card
    final toggleFinder = find.text('Turn Scrola On');
    expect(toggleFinder, findsOneWidget);

    await tester.tap(toggleFinder);
    await tester.pump(const Duration(milliseconds: 300));

    // NotchProModal bottom sheet appears immediately instead of flight animation
    expect(find.byType(NotchProModal), findsOneWidget);
    expect(find.text('Floating Notch Counter'), findsOneWidget);
    expect(find.text('View Scrola Pro Plans'), findsOneWidget);
  });
}

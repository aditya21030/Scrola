import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';
import 'package:scrola/features/profile/presentation/screens/about_scrola_screen.dart';
import 'package:scrola/features/profile/presentation/screens/profile_screen.dart';
import 'package:scrola/features/profile/presentation/screens/terms_of_service_screen.dart';
import 'package:scrola/shared/widgets/brainy_mascot.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTest();
    await StorageService.getInstance();
    await TrackingService().initialize();
  });

  testWidgets('ProfileScreen renders Pro Mascot, terms of service, removes guide, and shows version at down centre', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(showBack: false),
      ),
    );
    await tester.pump(const Duration(milliseconds: 150));

    // 1. Pro Mascot is used instead of badge icon
    expect(find.text('Scrola Pro'), findsOneWidget);
    expect(find.byType(BrainyMascot), findsWidgets);
    expect(find.byIcon(Icons.workspace_premium_rounded), findsNothing);

    // 2. How Scrola works guide is removed from profile menu
    expect(find.text('How Scrola works (Guide)'), findsNothing);

    // 3. Terms of Service is in the menu
    expect(find.text('Terms of Service'), findsOneWidget);

    // 4. About Scrola is in menu without old v0.2
    expect(find.text('About Scrola'), findsOneWidget);
    expect(find.text('v0.2'), findsNothing);

    // 5. Updated version number at down centre
    final versionFinder = find.text('Scrola v1.0.0 (Build 3)');
    expect(versionFinder, findsOneWidget);
    final versionCenter = tester.getCenter(versionFinder);
    expect((versionCenter.dx - 195.0).abs(), lessThan(2.0),
        reason: 'Version number must be horizontally centered');
    expect(find.text('Made with ❤️ by Yousful Studio'), findsOneWidget);
  });

  testWidgets('AboutScrolaScreen renders rich content, mission, and version info', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AboutScrolaScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('About Scrola'), findsOneWidget);
    expect(find.text('Mindful Short-Video Counter & Focus Guard'), findsOneWidget);
    expect(find.text('Our Mission'), findsOneWidget);
    expect(find.text('How Scrola Works'), findsOneWidget);
    expect(find.textContaining('Version 1.0.0 (Build 3)'), findsWidgets);
    expect(find.textContaining('Yousful Studio'), findsWidgets);
  });

  testWidgets('TermsOfServiceScreen renders all sections and copy link', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TermsOfServiceScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Scrola Terms & Conditions'), findsOneWidget);
    expect(find.text('Acceptance of Terms'), findsOneWidget);
    expect(find.text('Permitted Use & Purpose'), findsOneWidget);
    expect(find.text('Subscriptions & Google Play Billing'), findsOneWidget);
    expect(find.text('Intellectual Property'), findsOneWidget);
    expect(find.textContaining('Version 1.0.0 (Build 3)'), findsOneWidget);
  });
}

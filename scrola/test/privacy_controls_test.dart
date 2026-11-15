import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/features/profile/presentation/screens/privacy_controls_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTest();
  });

  testWidgets('PrivacyControlsScreen renders all privacy disclosures and controls', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrivacyControlsScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Privacy & Data Controls'), findsOneWidget);
    expect(find.text('100% Private by Design'), findsOneWidget);
    expect(find.text('ACCESSIBILITY SERVICE PERMISSION'), findsOneWidget);
    expect(find.text('Short-Form Video Detection'), findsOneWidget);
    expect(find.text('DATA & PRIVACY CONTROLS'), findsOneWidget);
    expect(find.text('Anonymous Crash Diagnostics'), findsOneWidget);
    expect(find.text('Export My Data (CSV)'), findsOneWidget);
    expect(find.text('Reset Local Tracking Stats'), findsOneWidget);
    expect(find.text('Delete Account & All Data'), findsOneWidget);
    expect(find.text('FULL PRIVACY POLICY'), findsOneWidget);

    // Scroll down to policy section and expand
    await tester.scrollUntilVisible(
      find.text('Read Policy Document'),
      300,
    );
    await tester.tap(find.text('Read Policy Document'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('1. What Scrola Collects'), findsOneWidget);
    expect(find.text('2. Accessibility Service Usage'), findsOneWidget);
    expect(find.text('3. Zero Third-Party Advertising'), findsOneWidget);
  });
}

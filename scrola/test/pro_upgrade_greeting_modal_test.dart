import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/features/profile/presentation/widgets/pro_upgrade_greeting_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTest();
  });

  testWidgets('ProUpgradeGreetingModal renders celebratory content and closes on button tap',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ProUpgradeGreetingModal.show(
                context,
                planTitle: 'Yearly Plan',
              ),
              child: const Text('Open Modal'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Verify modal elements are visible
    expect(find.text('Welcome to Scrola Pro!'), findsOneWidget);
    expect(find.text('PRO ACTIVE'), findsOneWidget);
    expect(find.textContaining('Yearly Plan active'), findsOneWidget);
    expect(find.text('Unlimited Floating Notch Counter'), findsOneWidget);
    expect(find.text('Golden & Premium Brainy Skins'), findsOneWidget);
    expect(find.text('Streak Shield & Deep Insights'), findsOneWidget);
    expect(find.text('Start Exploring Pro'), findsOneWidget);

    // Tap CTA button
    await tester.tap(find.text('Start Exploring Pro'));
    await tester.pumpAndSettle();

    // Modal is dismissed
    expect(find.text('Welcome to Scrola Pro!'), findsNothing);
  });
}

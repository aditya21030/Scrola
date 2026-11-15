import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/features/profile/presentation/screens/subscription_pro_screen.dart';
import 'package:scrola/features/profile/presentation/widgets/notch_pro_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTest();
  });

  testWidgets('SubscriptionProScreen renders 3 pricing tiers and comparison table', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SubscriptionProScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Scrola Pro'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('₹49'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('₹499'), findsOneWidget);
    expect(find.text('Lifetime'), findsOneWidget);
    expect(find.text('₹999'), findsOneWidget);
    expect(find.text('POPULAR · SAVE 15%'), findsOneWidget);
    expect(find.text('BEST VALUE'), findsOneWidget);
    expect(find.text('Floating notch counter'), findsOneWidget);
    expect(find.text('1 free session'), findsOneWidget);
    expect(find.text('Unlimited'), findsNWidgets(2));

    // Tap Monthly card
    await tester.tap(find.text('Monthly'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Continue with Monthly (₹49)'), findsOneWidget);

    // Tap Lifetime card
    await tester.tap(find.text('Lifetime'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Continue with Lifetime (₹999)'), findsOneWidget);

    // Tap Yearly card
    await tester.tap(find.text('Yearly'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Continue with Yearly (₹499)'), findsOneWidget);
  });

  testWidgets('NotchProModal displays pro prompt and quick plan pricing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => NotchProModal.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Floating Notch Counter'), findsOneWidget);
    expect(find.text('PRO FEATURE'), findsOneWidget);
    expect(find.text('₹49'), findsOneWidget);
    expect(find.text('₹499'), findsOneWidget);
    expect(find.text('₹999'), findsOneWidget);
    expect(find.text('View Scrola Pro Plans'), findsOneWidget);
    expect(find.text('Continue with standard tracking'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/features/focus/presentation/widgets/emergency_unlock_modal.dart';
import 'package:scrola/features/focus/presentation/widgets/limit_reached_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'LimitReachedModal.show called multiple times concurrently only opens one bottom sheet',
      (tester) async {
    BuildContext? testContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            testContext = context;
            return const Scaffold(
              body: Center(child: Text('Home')),
            );
          },
        ),
      ),
    );

    expect(testContext, isNotNull);

    // Call LimitReachedModal.show multiple times concurrently
    LimitReachedModal.show(testContext!);
    LimitReachedModal.show(testContext!);
    LimitReachedModal.show(testContext!);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // There should only be ONE "That's your limit for today"
    expect(find.text("That's your limit for today"), findsOneWidget);
    // And only one "Back to Scrola" button
    expect(find.text('Back to Scrola'), findsOneWidget);

    // Dismiss modal
    await tester.tap(find.text('Back to Scrola'));
    await tester.pumpAndSettle();

    expect(find.text("That's your limit for today"), findsNothing);
  });

  testWidgets(
      'EmergencyUnlockModal.show called multiple times concurrently only opens one modal',
      (tester) async {
    BuildContext? testContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            testContext = context;
            return const Scaffold(
              body: Center(child: Text('Home')),
            );
          },
        ),
      ),
    );

    EmergencyUnlockModal.show(testContext!);
    EmergencyUnlockModal.show(testContext!);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Unlock for 5 minutes?'), findsOneWidget);
  });
}

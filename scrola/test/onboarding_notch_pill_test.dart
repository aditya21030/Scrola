import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/gamification_engine.dart';
import 'package:scrola/features/onboarding/presentation/screens/onboarding_wizard_screen.dart';
import 'package:scrola/shared/widgets/brainy_mascot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TopNotchPillMockup is dead-centered, symmetrical, and aligns with pointers',
      (WidgetTester tester) async {
    // 1. Test standard pill mockup without pointers (used on 3 onboarding slides)
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TopNotchPillMockup(
              showPointers: false,
              mood: BrainyMood.happy,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('24 watched'), findsOneWidget);
    expect(find.text('16 left'), findsOneWidget);
    expect(find.byType(BrainyMascot), findsOneWidget);
    expect(find.text('Watched'), findsNothing);

    final watched0 = tester.getCenter(find.text('24 watched'));
    final mascot0 = tester.getCenter(find.byType(BrainyMascot));
    final left0 = tester.getCenter(find.text('16 left'));

    // Brainy must be centered between '24 watched' and '16 left' with pixel precision
    final distLeft0 = mascot0.dx - watched0.dx;
    final distRight0 = left0.dx - mascot0.dx;
    expect(
      (distLeft0 - distRight0).abs(),
      lessThan(0.01),
      reason: 'Brainy must be mathematically centered between 24 watched and 16 left',
    );

    // 2. Test pill mockup with pointers (used on Step 4: Brainy docked at notch)
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TopNotchPillMockup(
              showPointers: true,
              mood: BrainyMood.happy,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('24 watched'), findsOneWidget);
    expect(find.text('16 left'), findsOneWidget);
    expect(find.byType(BrainyMascot), findsOneWidget);
    expect(find.text('Watched'), findsOneWidget);
    expect(find.text('Brainy (Tap)'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);

    final watchedCenter = tester.getCenter(find.text('24 watched'));
    final mascotCenter = tester.getCenter(find.byType(BrainyMascot));
    final leftCenter = tester.getCenter(find.text('16 left'));

    final watchedPointerCenter = tester.getCenter(find.text('Watched'));
    final mascotPointerCenter = tester.getCenter(find.text('Brainy (Tap)'));
    final remainingPointerCenter = tester.getCenter(find.text('Remaining'));

    // Brainy centered
    final distLeft = mascotCenter.dx - watchedCenter.dx;
    final distRight = leftCenter.dx - mascotCenter.dx;
    expect(
      (distLeft - distRight).abs(),
      lessThan(0.01),
      reason: 'Brainy must be centered between watched and left',
    );

    // Pointers align exactly with their matching pill items
    expect(
      (watchedPointerCenter.dx - watchedCenter.dx).abs(),
      lessThan(0.01),
      reason: 'Watched pointer must vertically align with 24 watched text',
    );

    expect(
      (mascotPointerCenter.dx - mascotCenter.dx).abs(),
      lessThan(0.01),
      reason: 'Brainy (Tap) pointer must vertically align with Brainy mascot',
    );

    expect(
      (remainingPointerCenter.dx - leftCenter.dx).abs(),
      lessThan(0.01),
      reason: 'Remaining pointer must vertically align with 16 left text',
    );

    // 3. Test different moods for the 3 slides
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TopNotchPillMockup(
              showPointers: false,
              mood: BrainyMood.celebrating,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final celebratingMascot = tester.widget<BrainyMascot>(find.byType(BrainyMascot));
    expect(celebratingMascot.mood, equals(BrainyMood.celebrating));
  });
}

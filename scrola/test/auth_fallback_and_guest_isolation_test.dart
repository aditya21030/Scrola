import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrola/core/services/auth_service.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';
import 'package:scrola/features/auth/presentation/screens/create_account_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTest();
    await StorageService.getInstance();
  });

  group('Guest Identity & Name Isolation Tests', () {
    test('Guest mode strictly returns Guest and does not leak previous user names', () async {
      final auth = AuthService();
      final tracking = TrackingService();
      await tracking.initialize();

      // Ensure user is signed in as guest
      await auth.signInAsGuest();
      expect(auth.isGuest, isTrue);
      expect(auth.isLoggedIn, isFalse);
      expect(tracking.displayName, equals('Guest'));
      expect(tracking.username, equals('guest'));
      expect(tracking.email, equals(''));

      // Even if legacy prefs had another name stored:
      final storage = await StorageService.getInstance();
      await storage.setProfile(displayName: 'Aditya Jain', username: 'adityajain', email: 'aditya@example.com');

      // TrackingService must still isolate and report 'Guest' while in Guest mode!
      expect(auth.isGuest, isTrue);
      expect(tracking.displayName, equals('Guest'));
      expect(tracking.username, equals('guest'));
      expect(tracking.email, equals(''));
    });

    test('Local account registration and login fallback without hanging', () async {
      final auth = AuthService();
      final tracking = TrackingService();
      await tracking.initialize();

      // Register local account
      final createErr = await auth.createAccountWithEmail(
        email: 'aditya@example.com',
        password: 'password123',
        displayName: 'Aditya Jain',
        username: 'adityajain',
      );

      expect(createErr, isNull);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.isGuest, isFalse);
      expect(auth.displayName, equals('Aditya Jain'));
      expect(tracking.displayName, equals('Aditya Jain'));

      // Sign out
      await auth.signOut();
      expect(auth.isLoggedIn, isFalse);
      expect(auth.isGuest, isTrue);
      expect(tracking.displayName, equals('Guest'));

      // Log back in
      final loginErr = await auth.signInWithEmail('aditya@example.com', 'password123');
      expect(loginErr, isNull);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.isGuest, isFalse);
      expect(tracking.displayName, equals('Aditya Jain'));

      // Test incorrect password
      await auth.signOut();
      final badLoginErr = await auth.signInWithEmail('aditya@example.com', 'wrongpass');
      expect(badLoginErr, contains('Incorrect email or password'));
      expect(auth.isGuest, isTrue);
      expect(tracking.displayName, equals('Guest'));
    });

    test('Username must have at least 3 letters and unique check is enforced', () async {
      final auth = AuthService();

      // Less than 3 letters
      final shortErr = await auth.createAccountWithEmail(
        email: 'short@example.com',
        password: 'password123',
        username: 'ab',
      );
      expect(shortErr, contains('at least 3 letters'));

      // Register a taken username in storage
      StorageService.registerTakenUsernameForTesting('taken_user');
      expect(await auth.isUsernameTaken('taken_user'), isTrue);
      expect(await auth.isUsernameTaken('free_user'), isFalse);

      // Attempt to register taken username
      final takenErr = await auth.createAccountWithEmail(
        email: 'newuser@example.com',
        password: 'password123',
        username: 'taken_user',
      );
      expect(takenErr, contains('already taken'));
    });

    testWidgets('CreateAccountScreen suggests usernames dynamically and enforces 3+ letters realtime', (tester) async {
      StorageService.registerTakenUsernameForTesting('already_taken');

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateAccountScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Initial state: shows instruction to have at least 3 letters
      expect(find.textContaining('At least 3 letters'), findsOneWidget);

      // 2. Type Display Name "Aditya Jain" -> suggestions appear!
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(4)); // Name, Username, Email, Password

      await tester.enterText(textFields.at(0), 'Aditya Jain');
      await tester.pump(const Duration(milliseconds: 100));

      // Verify suggestion chips are shown
      expect(find.text('Suggested for you:'), findsOneWidget);
      expect(find.textContaining('@aditya'), findsWidgets);

      // 3. Enter a 2-letter username -> shows "must have at least 3 letters"
      await tester.enterText(textFields.at(1), 'ad');
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Username must have at least 3 letters'), findsOneWidget);

      // 4. Enter a taken username -> after debounce, shows "@already_taken is already taken"
      await tester.enterText(textFields.at(1), 'already_taken');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('@already_taken is already taken'), findsOneWidget);
      expect(find.text('Taken'), findsOneWidget);

      // 5. Enter an available username -> after debounce, shows "@adityajain is available"
      await tester.enterText(textFields.at(1), 'adityajain');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('@adityajain is available'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);

      // 6. Tap a suggestion chip -> fills the username field
      await tester.tap(find.textContaining('@aditya').first);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Available'), findsOneWidget);
    });
  });
}

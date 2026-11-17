import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrola/core/services/auth_service.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';

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
  });
}

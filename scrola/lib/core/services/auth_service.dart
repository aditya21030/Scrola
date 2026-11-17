import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firebase_sync_service.dart';
import 'local_auth_user.dart';
import 'storage_service.dart';
import 'tracking_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;
  LocalAuthUser? _localUser;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser;
  LocalAuthUser? get localUser => _localUser;

  bool get isLoggedIn =>
      (_currentUser != null && !_currentUser!.isAnonymous) || _localUser != null;

  bool get isGuest =>
      (_currentUser == null || _currentUser!.isAnonymous) && _localUser == null;

  String? get email => _currentUser?.email ?? _localUser?.email;
  String? get displayName =>
      _currentUser?.displayName ?? _localUser?.displayName;
  String? get username => _localUser?.username;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _auth = FirebaseAuth.instance;
      _currentUser = _auth?.currentUser;
      await FirebaseSyncService().initialize();
      _authSubscription = _auth?.authStateChanges().listen((user) async {
        _currentUser = user;
        if (user != null && !user.isAnonymous) {
          final tracking = TrackingService();
          await tracking.updateProfile(
            displayName: user.displayName ?? tracking.displayName,
            email: user.email ?? tracking.email,
          );
          unawaited(FirebaseSyncService()
              .pullFromCloud()
              .timeout(const Duration(seconds: 4), onTimeout: () => false));
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('AuthService initialization error (running in local guest mode): $e');
    }

    // Restore local account session if active and not already signed into Firebase
    try {
      final storage = await StorageService.getInstance();
      if ((_currentUser == null || _currentUser!.isAnonymous) &&
          storage.isLocalAccountActive) {
        _localUser = storage.getLocalAccountUser();
        if (_localUser != null) {
          final tracking = TrackingService();
          await tracking.updateProfile(
            displayName: _localUser!.displayName,
            username: _localUser!.username,
            email: _localUser!.email,
          );
        }
      }
    } catch (e) {
      debugPrint('Local account restore error: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Sign in with email and password
  Future<String?> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Try Firebase Auth with timeout
    if (_auth != null) {
      try {
        final credential = await _auth!
            .signInWithEmailAndPassword(
              email: cleanEmail,
              password: password,
            )
            .timeout(const Duration(seconds: 8));

        _currentUser = credential.user;
        _localUser = null;
        if (_currentUser != null) {
          final tracking = TrackingService();
          final resolvedName = (_currentUser!.displayName != null &&
                  _currentUser!.displayName!.isNotEmpty)
              ? _currentUser!.displayName!
              : cleanEmail.split('@').first;

          await tracking.updateProfile(
            displayName: resolvedName,
            email: _currentUser!.email ?? cleanEmail,
          );

          final storage = await StorageService.getInstance();
          await storage.saveLocalAccount(
            email: cleanEmail,
            password: password,
            displayName: resolvedName,
            username: tracking.username,
          );

          unawaited(FirebaseSyncService()
              .pullFromCloud()
              .timeout(const Duration(seconds: 4), onTimeout: () => false));
        }
        notifyListeners();
        return null; // Success with Firebase!
      } on FirebaseAuthException catch (e) {
        final code = e.code.toLowerCase();
        if (code == 'wrong-password' ||
            code == 'invalid-credential' ||
            code == 'user-disabled' ||
            code == 'invalid-email') {
          return _mapFirebaseAuthError(e);
        }
        debugPrint('Firebase Auth signIn failed (${e.code}), checking local account...');
      } catch (e) {
        debugPrint('Firebase signIn error/timeout ($e), checking local account...');
      }
    }

    // 2. Check Local Account Fallback (offline or when Firebase is unconfigured)
    try {
      final storage = await StorageService.getInstance();
      final savedEmail = storage.localAccountEmail;
      if (savedEmail.isNotEmpty && savedEmail == cleanEmail) {
        if (storage.verifyLocalPassword(cleanEmail, password)) {
          await storage.setLocalAccountActive(true);
          _localUser = storage.getLocalAccountUser();
          final tracking = TrackingService();
          await tracking.updateProfile(
            displayName: _localUser?.displayName ?? cleanEmail.split('@').first,
            username: _localUser?.username ?? 'user',
            email: cleanEmail,
          );
          notifyListeners();
          return null; // Success with local account!
        } else {
          return 'Incorrect email or password. Please try again.';
        }
      }
    } catch (e) {
      debugPrint('Local account verification error: $e');
    }

    return 'No account found with this email. Please check your credentials or create a new account.';
  }

  /// Register / Create account with email, password, and optional displayName & username
  Future<String?> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? username,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : cleanEmail.split('@').first;
    final cleanUsername = (username != null && username.trim().isNotEmpty)
        ? username.trim().replaceAll('@', '').replaceAll(' ', '')
        : cleanEmail.split('@').first;

    // 1. Try Firebase Auth first with timeout
    if (_auth != null) {
      try {
        final credential = await _auth!
            .createUserWithEmailAndPassword(
              email: cleanEmail,
              password: password,
            )
            .timeout(const Duration(seconds: 8));

        final user = credential.user;
        if (user != null) {
          try {
            await user
                .updateDisplayName(cleanName)
                .timeout(const Duration(seconds: 4));
          } catch (e) {
            debugPrint('Non-critical: updateDisplayName error: $e');
          }
          _currentUser = user;
          _localUser = null;

          final storage = await StorageService.getInstance();
          await storage.saveLocalAccount(
            email: cleanEmail,
            password: password,
            displayName: cleanName,
            username: cleanUsername,
          );

          final tracking = TrackingService();
          await tracking.updateProfile(
            displayName: cleanName,
            username: cleanUsername,
            email: cleanEmail,
          );

          unawaited(FirebaseSyncService()
              .pushToCloud()
              .timeout(const Duration(seconds: 4), onTimeout: () => false));

          notifyListeners();
          return null; // Success with Firebase!
        }
      } on FirebaseAuthException catch (e) {
        final code = e.code.toLowerCase();
        if (code == 'email-already-in-use' ||
            code == 'invalid-email' ||
            code == 'weak-password') {
          return _mapFirebaseAuthError(e);
        }
        debugPrint(
            'Firebase Auth unavailable (${e.code}), falling back to local account registration.');
      } catch (e) {
        debugPrint(
            'Firebase Auth exception/timeout ($e), falling back to local account registration.');
      }
    }

    // 2. Local Account Fallback (seamlessly works offline and when Firebase is not configured)
    try {
      final storage = await StorageService.getInstance();
      await storage.saveLocalAccount(
        email: cleanEmail,
        password: password,
        displayName: cleanName,
        username: cleanUsername,
      );

      _localUser = LocalAuthUser(
        uid: 'local_${DateTime.now().millisecondsSinceEpoch}',
        email: cleanEmail,
        displayName: cleanName,
        username: cleanUsername,
      );

      final tracking = TrackingService();
      await tracking.updateProfile(
        displayName: cleanName,
        username: cleanUsername,
        email: cleanEmail,
      );

      notifyListeners();
      return null; // Success with local account!
    } catch (e) {
      debugPrint('Local account creation error: $e');
      return 'Failed to create account: $e';
    }
  }

  /// Send password reset email
  Future<String?> sendPasswordReset(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_auth != null) {
      try {
        await _auth!
            .sendPasswordResetEmail(email: cleanEmail)
            .timeout(const Duration(seconds: 6));
        return null;
      } on FirebaseAuthException catch (e) {
        return _mapFirebaseAuthError(e);
      } catch (e) {
        debugPrint('sendPasswordReset exception: $e');
      }
    }
    // Return null (success UI) even offline
    return null;
  }

  /// Sign in anonymously for guest session tracking
  Future<void> signInAsGuest() async {
    try {
      _localUser = null;
      final storage = await StorageService.getInstance();
      await storage.clearLocalAccountSession();
      if (_auth != null && _currentUser == null) {
        final credential = await _auth!.signInAnonymously().timeout(
              const Duration(seconds: 4),
              onTimeout: () => throw TimeoutException('Guest sign-in timeout'),
            );
        _currentUser = credential.user;
      }
    } catch (e) {
      debugPrint('Guest sign-in notice (running in local guest mode): $e');
    } finally {
      final tracking = TrackingService();
      await tracking.updateProfile(
        displayName: 'Guest',
        username: 'guest',
        email: '',
      );
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
      _currentUser = null;
      _localUser = null;
      final storage = await StorageService.getInstance();
      await storage.clearLocalAccountSession();
      final tracking = TrackingService();
      await tracking.updateProfile(
        displayName: 'Guest',
        username: 'guest',
        email: '',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Permanently delete account, cloud user document, and wipe local data
  Future<String?> deleteAccount() async {
    try {
      final user = _currentUser;
      if (user != null) {
        // 1. Delete cloud database records in Firestore
        unawaited(FirebaseSyncService()
            .deleteUserCloudData()
            .timeout(const Duration(seconds: 4), onTimeout: () => false));
        // 2. Delete Firebase auth user
        try {
          await user.delete().timeout(const Duration(seconds: 6));
        } catch (e) {
          debugPrint('user.delete warning: $e');
        }
      }
      _currentUser = null;
      _localUser = null;

      // 3. Clear local profile and tracking stats
      final tracking = TrackingService();
      await tracking.updateProfile(
        displayName: 'Guest',
        username: 'guest',
        email: '',
      );
      final storage = await StorageService.getInstance();
      await storage.clearAllUserData();

      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'For security, please sign in again before deleting your account.';
      }
      return _mapFirebaseAuthError(e);
    } catch (e) {
      debugPrint('deleteAccount error: $e');
      return 'Failed to delete account: $e';
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    final msg = (e.message ?? '').toUpperCase();
    final code = e.code.toLowerCase();

    if (code.contains('configuration-not-found') ||
        code.contains('configuration_not_found') ||
        msg.contains('CONFIGURATION_NOT_FOUND')) {
      return 'Firebase Email/Password sign-in is not enabled yet in your Firebase Console (scrola-111). Under "Authentication" -> "Sign-in method", turn ON "Email/Password".';
    }

    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is currently disabled in Firebase Console.';
      default:
        return e.message ?? 'Authentication error (${e.code})';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

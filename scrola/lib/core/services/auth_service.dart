import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'tracking_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null && !_currentUser!.isAnonymous;
  bool get isGuest => _currentUser == null || _currentUser!.isAnonymous;
  String? get email => _currentUser?.email;
  String? get displayName => _currentUser?.displayName;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _auth = FirebaseAuth.instance;
      _currentUser = _auth?.currentUser;
      _authSubscription = _auth?.authStateChanges().listen((user) {
        _currentUser = user;
        if (user != null && !user.isAnonymous) {
          final tracking = TrackingService();
          tracking.updateProfile(
            displayName: user.displayName ?? tracking.displayName,
            email: user.email ?? tracking.email,
          );
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('AuthService initialization error (running in local guest mode): $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Sign in with email and password
  Future<String?> signInWithEmail(String email, String password) async {
    if (_auth == null) {
      return 'Firebase is not initialized. Running in guest mode.';
    }
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _currentUser = credential.user;
      if (_currentUser != null) {
        final tracking = TrackingService();
        await tracking.updateProfile(
          displayName: _currentUser!.displayName ?? tracking.displayName,
          email: _currentUser!.email ?? tracking.email,
        );
      }
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthError(e);
    } catch (e) {
      if (e.toString().toUpperCase().contains('CONFIGURATION_NOT_FOUND')) {
        return 'Firebase Authentication is not enabled yet in your Firebase Console (scrola-111). Under "Authentication" -> "Sign-in method", turn ON "Email/Password". You can also continue offline as Guest!';
      }
      return 'An unexpected error occurred: $e';
    }
  }

  /// Register / Create account with email, password, and optional displayName & username
  Future<String?> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? username,
  }) async {
    if (_auth == null) {
      return 'Firebase is not initialized. Running in guest mode.';
    }
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
        _currentUser = user;
        final tracking = TrackingService();
        await tracking.updateProfile(
          displayName: displayName ?? tracking.displayName,
          username: username ?? tracking.username,
          email: user.email ?? tracking.email,
        );
      }
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthError(e);
    } catch (e) {
      if (e.toString().toUpperCase().contains('CONFIGURATION_NOT_FOUND')) {
        return 'Firebase Authentication is not enabled yet in your Firebase Console (scrola-111). Under "Authentication" -> "Sign-in method", turn ON "Email/Password". You can also continue offline as Guest!';
      }
      return 'An unexpected error occurred: $e';
    }
  }

  /// Send password reset email
  Future<String?> sendPasswordReset(String email) async {
    if (_auth == null) {
      return 'Firebase is not initialized.';
    }
    try {
      await _auth!.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  /// Sign in anonymously for guest session tracking
  Future<void> signInAsGuest() async {
    try {
      if (_auth != null && _currentUser == null) {
        final credential = await _auth!.signInAnonymously();
        _currentUser = credential.user;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Guest sign-in error: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    final msg = (e.message ?? '').toUpperCase();
    final code = e.code.toLowerCase();

    if (code.contains('configuration-not-found') ||
        code.contains('configuration_not_found') ||
        msg.contains('CONFIGURATION_NOT_FOUND')) {
      return 'Firebase Email/Password sign-in is not enabled yet in your Firebase Console (scrola-111). Under "Authentication" -> "Sign-in method", turn ON "Email/Password". You can also tap below to save your profile locally!';
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

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'gamification_engine.dart';
import 'storage_service.dart';

class FirebaseSyncService {
  static final FirebaseSyncService _instance = FirebaseSyncService._internal();
  factory FirebaseSyncService() => _instance;
  FirebaseSyncService._internal();

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  bool _isInitialized = false;
  Timer? _debounceTimer;

  bool get isAvailable => _firestore != null && _auth != null;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;

      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _auth!.authStateChanges().listen((user) async {
        if (user != null && !user.isAnonymous) {
          debugPrint('FirebaseSyncService: User authenticated (${user.uid}), syncing stats...');
          await pullFromCloud();
        }
      });
      _isInitialized = true;
      debugPrint('FirebaseSyncService: Initialized successfully with Cloud Firestore.');
    } catch (e) {
      debugPrint('FirebaseSyncService: Firestore init error (running in local guest mode): $e');
    }
  }

  /// Pull user data from Firebase Cloud Firestore into local SharedPreferences
  Future<bool> pullFromCloud() async {
    final user = _auth?.currentUser;
    if (user == null || user.isAnonymous || _firestore == null) {
      return false;
    }

    try {
      final docRef = _firestore!.collection('users').doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        debugPrint('FirebaseSyncService: Remote user doc not found, pushing local stats to cloud.');
        await pushToCloud();
        return true;
      }

      final data = docSnap.data();
      if (data == null) return false;

      final storage = await StorageService.getInstance();

      final remoteXp = (data['xpTotal'] as num?)?.toInt() ?? 0;
      final remoteStreak = (data['streakDays'] as num?)?.toInt() ?? 0;
      final remoteLimit = (data['dailyLimit'] as num?)?.toInt() ?? 40;
      final remoteLastStreakDate = data['lastStreakDate'] as String? ?? '';
      final remoteSkinName = data['equippedSkin'] as String?;
      final remoteClaimed = (data['claimedRewards'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final remoteGoal = data['selectedGoal'] as String?;
      final remoteDisplayName = data['displayName'] as String?;
      final remoteUsername = data['username'] as String?;

      final localXp = storage.xpTotal;
      final localStreak = storage.streakDays;

      // Merge rule: Keep the highest progression
      if (remoteXp > localXp) {
        await storage.addXP(remoteXp - localXp);
      } else if (localXp > remoteXp) {
        await pushToCloud();
      }

      if (remoteStreak > localStreak) {
        await storage.updateStreak(remoteStreak);
      } else if (remoteLastStreakDate.isNotEmpty && storage.lastStreakDate.isEmpty) {
        await storage.updateStreak(remoteStreak);
      }

      if (remoteLimit > 0 && remoteLimit != storage.totalLimit) {
        await storage.setLimits(total: remoteLimit);
      }

      if (remoteSkinName != null) {
        final skin = BrainySkin.values.firstWhere(
          (s) => s.name.toLowerCase() == remoteSkinName.toLowerCase(),
          orElse: () => BrainySkin.classic,
        );
        await storage.setEquippedSkin(skin);
      }

      for (final reward in remoteClaimed) {
        await storage.markRewardClaimed(reward);
      }

      if (remoteGoal != null && remoteGoal.isNotEmpty) {
        await storage.setSelectedGoal(remoteGoal);
      }

      await storage.setProfile(
        displayName: remoteDisplayName,
        username: remoteUsername,
        email: user.email,
      );

      debugPrint('FirebaseSyncService: Successfully synced user profile and stats from Firestore.');
      return true;
    } catch (e) {
      debugPrint('FirebaseSyncService: pullFromCloud warning (offline/local fallback): $e');
      return false;
    }
  }

  /// Push current local stats to Firebase Cloud Firestore
  Future<bool> pushToCloud() async {
    final user = _auth?.currentUser;
    if (user == null || user.isAnonymous || _firestore == null) {
      return false;
    }

    try {
      final storage = await StorageService.getInstance();
      final docRef = _firestore!.collection('users').doc(user.uid);

      final platformCounts = <String, int>{};
      final platformLimits = <String, int>{};
      for (final id in StorageService.supportedPlatformIds) {
        platformCounts[id] = storage.reelsForPlatform(id);
        platformLimits[id] = storage.limitForPlatform(id);
      }

      final payload = <String, dynamic>{
        'uid': user.uid,
        'email': user.email ?? storage.email,
        'displayName': storage.displayName.isNotEmpty ? storage.displayName : user.displayName,
        'username': storage.username,
        'xpTotal': storage.xpTotal,
        'level': storage.currentLevel,
        'levelTitle': GamificationEngine.getLevelForXP(storage.xpTotal).title,
        'stageNumber': GamificationEngine.getLevelForXP(storage.xpTotal).stageNumber,
        'streakDays': storage.streakDays,
        'lastStreakDate': storage.lastStreakDate,
        'dailyLimit': storage.totalLimit,
        'totalReelsToday': storage.totalReelsToday,
        'platformCounts': platformCounts,
        'platformLimits': platformLimits,
        'equippedSkin': storage.equippedSkin.name,
        'claimedRewards': storage.claimedRewards,
        'selectedGoal': storage.selectedGoal,
        'selectedPlatforms': storage.selectedPlatforms,
        'isProSubscribed': storage.isProSubscribed,
        'proPlan': storage.proPlan,
        'joinedDate': storage.joinedDateIso,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(payload, SetOptions(merge: true));
      debugPrint('FirebaseSyncService: User stats pushed to Firestore successfully (Level ${storage.currentLevel}, ${storage.xpTotal} XP, ${storage.streakDays} streak).');
      return true;
    } catch (e) {
      debugPrint('FirebaseSyncService: pushToCloud warning (offline/local fallback): $e');
      return false;
    }
  }

  /// Debounced push to avoid spamming network calls during rapid scrolling
  void schedulePush() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      pushToCloud();
    });
  }
}

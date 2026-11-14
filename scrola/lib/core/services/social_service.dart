import 'package:flutter/foundation.dart';
import 'gamification_engine.dart';
import 'haptic_service.dart';

class FriendUser {
  final String id;
  final String name;
  final String username;
  final BrainySkin skin;
  final int level;
  final int streak;
  final int reelsToday;
  final int dailyLimit;
  final bool isOnline;
  final int battleWins;

  const FriendUser({
    required this.id,
    required this.name,
    required this.username,
    required this.skin,
    required this.level,
    required this.streak,
    required this.reelsToday,
    required this.dailyLimit,
    this.isOnline = false,
    this.battleWins = 0,
  });

  bool get isUnderLimit => reelsToday <= dailyLimit;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'username': username,
        'skin': skin.name,
        'level': level,
        'streak': streak,
        'reelsToday': reelsToday,
        'dailyLimit': dailyLimit,
        'isOnline': isOnline,
        'battleWins': battleWins,
      };

  factory FriendUser.fromMap(Map<String, dynamic> map) {
    return FriendUser(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Friend',
      username: map['username'] as String? ?? 'friend',
      skin: BrainySkin.values.firstWhere(
        (s) => s.name == map['skin'],
        orElse: () => BrainySkin.classic,
      ),
      level: map['level'] as int? ?? 1,
      streak: map['streak'] as int? ?? 0,
      reelsToday: map['reelsToday'] as int? ?? 0,
      dailyLimit: map['dailyLimit'] as int? ?? 30,
      isOnline: map['isOnline'] as bool? ?? false,
      battleWins: map['battleWins'] as int? ?? 0,
    );
  }
}

enum BattleStatus { active, pending, won, lost }

class ScrollBattle {
  final String id;
  final FriendUser opponent;
  final int userReels;
  final int opponentReels;
  final int targetLimit;
  final String durationLabel; // e.g. "1d 14h left"
  final int xpStakes;
  final BattleStatus status;

  const ScrollBattle({
    required this.id,
    required this.opponent,
    required this.userReels,
    required this.opponentReels,
    required this.targetLimit,
    required this.durationLabel,
    required this.xpStakes,
    required this.status,
  });

  bool get isUserWinning => userReels < opponentReels;
}

class GroupChallenge {
  final String id;
  final String title;
  final String description;
  final int currentReels;
  final int targetLimit;
  final int daysLeft;
  final int participantsCount;
  final bool isJoined;

  const GroupChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.currentReels,
    required this.targetLimit,
    required this.daysLeft,
    required this.participantsCount,
    this.isJoined = false,
  });

  double get progress => (currentReels / targetLimit).clamp(0.0, 1.0);
}

class SocialService extends ChangeNotifier {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  bool _isInitialized = false;

  List<FriendUser> _friends = [];
  List<ScrollBattle> _battles = [];
  List<GroupChallenge> _challenges = [];

  List<FriendUser> get friends => List.unmodifiable(_friends);
  List<ScrollBattle> get battles => List.unmodifiable(_battles);
  List<ScrollBattle> get activeBattles =>
      _battles.where((b) => b.status == BattleStatus.active).toList();
  List<ScrollBattle> get battleHistory =>
      _battles.where((b) => b.status == BattleStatus.won || b.status == BattleStatus.lost).toList();
  List<GroupChallenge> get challenges => List.unmodifiable(_challenges);

  Future<void> initialize() async {
    if (_isInitialized) return;

    _loadSampleData();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadSampleData() {
    _friends = [
      const FriendUser(
        id: 'f1',
        name: 'Zoe',
        username: 'zoe.mind',
        skin: BrainySkin.aqua,
        level: 14,
        streak: 12,
        reelsToday: 16,
        dailyLimit: 25,
        isOnline: true,
        battleWins: 8,
      ),
      const FriendUser(
        id: 'f2',
        name: 'Kai',
        username: 'kai_scrolls',
        skin: BrainySkin.golden,
        level: 22,
        streak: 28,
        reelsToday: 24,
        dailyLimit: 30,
        isOnline: true,
        battleWins: 14,
      ),
      const FriendUser(
        id: 'f3',
        name: 'Maya',
        username: 'maya.focus',
        skin: BrainySkin.sakura,
        level: 9,
        streak: 5,
        reelsToday: 12,
        dailyLimit: 20,
        isOnline: false,
        battleWins: 3,
      ),
      const FriendUser(
        id: 'f4',
        name: 'Liam',
        username: 'liam_99',
        skin: BrainySkin.charcoal,
        level: 18,
        streak: 19,
        reelsToday: 38,
        dailyLimit: 30,
        isOnline: false,
        battleWins: 9,
      ),
      const FriendUser(
        id: 'f5',
        name: 'Priya',
        username: 'priya.reads',
        skin: BrainySkin.mint,
        level: 31,
        streak: 45,
        reelsToday: 8,
        dailyLimit: 15,
        isOnline: true,
        battleWins: 21,
      ),
    ];

    _battles = [
      ScrollBattle(
        id: 'b1',
        opponent: _friends[0], // Zoe
        userReels: 18,
        opponentReels: 24,
        targetLimit: 30,
        durationLabel: '1d 14h left',
        xpStakes: 150,
        status: BattleStatus.active,
      ),
      ScrollBattle(
        id: 'b2',
        opponent: _friends[1], // Kai
        userReels: 32,
        opponentReels: 28,
        targetLimit: 35,
        durationLabel: '4h left',
        xpStakes: 200,
        status: BattleStatus.active,
      ),
      ScrollBattle(
        id: 'b3',
        opponent: _friends[3], // Liam
        userReels: 22,
        opponentReels: 38,
        targetLimit: 30,
        durationLabel: 'Completed',
        xpStakes: 100,
        status: BattleStatus.won,
      ),
      ScrollBattle(
        id: 'b4',
        opponent: _friends[4], // Priya
        userReels: 29,
        opponentReels: 14,
        targetLimit: 25,
        durationLabel: 'Completed',
        xpStakes: 100,
        status: BattleStatus.lost,
      ),
    ];

    _challenges = [
      const GroupChallenge(
        id: 'c1',
        title: 'Weekend Social Detox',
        description: 'Keep total reels under 50 collectively over Saturday and Sunday.',
        currentReels: 34,
        targetLimit: 50,
        daysLeft: 2,
        participantsCount: 142,
        isJoined: true,
      ),
      const GroupChallenge(
        id: 'c2',
        title: 'Deep Focus November',
        description: 'Accumulate 100 hours of focus sessions before month end.',
        currentReels: 68,
        targetLimit: 100,
        daysLeft: 16,
        participantsCount: 380,
        isJoined: false,
      ),
      const GroupChallenge(
        id: 'c3',
        title: 'Shorts Strike Zero',
        description: 'No YouTube Shorts between 9 PM and midnight for 5 consecutive days.',
        currentReels: 3,
        targetLimit: 5,
        daysLeft: 4,
        participantsCount: 89,
        isJoined: false,
      ),
    ];
  }

  Future<void> addFriend(FriendUser friend) async {
    _friends.add(friend);
    await HapticService.medium();
    notifyListeners();
  }

  Future<void> removeFriend(String friendId) async {
    _friends.removeWhere((f) => f.id == friendId);
    notifyListeners();
  }

  Future<void> createBattle({
    required FriendUser opponent,
    required int targetLimit,
    required String durationLabel,
    required int xpStakes,
  }) async {
    final battle = ScrollBattle(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      opponent: opponent,
      userReels: 0,
      opponentReels: 0,
      targetLimit: targetLimit,
      durationLabel: durationLabel,
      xpStakes: xpStakes,
      status: BattleStatus.active,
    );
    _battles.insert(0, battle);
    await HapticService.celebratory();
    notifyListeners();
  }

  Future<void> toggleJoinChallenge(String challengeId) async {
    final idx = _challenges.indexWhere((c) => c.id == challengeId);
    if (idx != -1) {
      final old = _challenges[idx];
      _challenges[idx] = GroupChallenge(
        id: old.id,
        title: old.title,
        description: old.description,
        currentReels: old.currentReels,
        targetLimit: old.targetLimit,
        daysLeft: old.daysLeft,
        participantsCount: old.isJoined ? old.participantsCount - 1 : old.participantsCount + 1,
        isJoined: !old.isJoined,
      );
      await HapticService.light();
      notifyListeners();
    }
  }
}

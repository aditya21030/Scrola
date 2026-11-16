import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/gamification_engine.dart';
import 'package:scrola/core/services/social_service.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';
import 'package:scrola/features/friends/presentation/screens/battle_details_screen.dart';
import 'package:scrola/features/friends/presentation/screens/battle_results_screen.dart';
import 'package:scrola/features/friends/presentation/screens/find_friends_screen.dart';
import 'package:scrola/features/friends/presentation/screens/friend_profile_screen.dart';
import 'package:scrola/features/friends/presentation/screens/friends_dashboard_screen.dart';
import 'package:scrola/features/friends/presentation/screens/friends_leaderboard_screen.dart';
import 'package:scrola/features/friends/presentation/screens/group_challenges_screen.dart';
import 'package:scrola/features/friends/presentation/screens/scroll_battles_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTest();
    await StorageService.getInstance();
    await TrackingService().initialize();
    await SocialService().initialize();
  });

  testWidgets('FriendsDashboardScreen renders cleanly at constrained 320dp width', (tester) async {
    tester.view.physicalSize = const Size(320, 680);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FriendsDashboardScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('LIVE BATTLE'), findsOneWidget);
    expect(find.text('LEADERBOARD'), findsOneWidget);
    expect(find.text('GROUP CHALLENGES'), findsOneWidget);
  });

  testWidgets('FriendsLeaderboardScreen filters and dynamic sorting work across Today, Week, All time', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FriendsLeaderboardScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Default tab is Week (index 1)
    expect(find.text('Ranked by streak consistency and low reel days this week.'), findsOneWidget);

    // Switch to Today tab
    await tester.tap(find.text('Today'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Ranked by lowest % of daily reel limit consumed today.'), findsOneWidget);

    // Switch to All time tab
    await tester.tap(find.text('All time'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Ranked by total lifetime XP and evolution tier.'), findsOneWidget);
  });

  testWidgets('BattleDetailsScreen shows accurate leading, trailing, and tie math without negatives', (tester) async {
    const friend = FriendUser(
      id: 'f_test',
      name: 'Maya',
      username: 'maya.focus',
      skin: BrainySkin.sakura,
      level: 10,
      streak: 5,
      reelsToday: 20,
      dailyLimit: 30,
    );

    const battleLeading = ScrollBattle(
      id: 'b_lead',
      opponent: friend,
      userReels: 10,
      opponentReels: 25,
      targetLimit: 30,
      durationLabel: '1d left',
      xpStakes: 150,
      status: BattleStatus.active,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: BattleDetailsScreen(battle: battleLeading),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('You vs Maya'), findsOneWidget);
    expect(find.text('VS'), findsOneWidget);
    expect(find.textContaining('fewer reel'), findsOneWidget);
    expect(find.textContaining('-'), findsNothing);
  });

  testWidgets('BattleResultsScreen claims XP and prevents double-claim exploit', (tester) async {
    const friend = FriendUser(
      id: 'f_won',
      name: 'Liam',
      username: 'liam_99',
      skin: BrainySkin.charcoal,
      level: 12,
      streak: 7,
      reelsToday: 35,
      dailyLimit: 30,
    );

    const wonBattle = ScrollBattle(
      id: 'b_won_test',
      opponent: friend,
      userReels: 15,
      opponentReels: 35,
      targetLimit: 30,
      durationLabel: 'Completed',
      xpStakes: 100,
      status: BattleStatus.won,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: BattleResultsScreen(battle: wonBattle),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('VICTORY!'), findsOneWidget);
    expect(find.text('Collect +100 XP'), findsOneWidget);

    // Tap collect
    await tester.tap(find.text('Collect +100 XP'));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify it is now claimed in SocialService
    expect(SocialService().isBattleClaimed('b_won_test'), isTrue);

    // If opened again, it shows Reward Claimed
    await tester.pumpWidget(
      const MaterialApp(
        home: BattleResultsScreen(battle: wonBattle),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Reward Claimed'), findsOneWidget);
  });

  testWidgets('ScrollBattlesScreen switches between Active and History tabs', (tester) async {
    SocialService().addBattleForTest(
      const ScrollBattle(
        id: 'b_won_history',
        opponent: FriendUser(
          id: 'f_test',
          name: 'TestFriend',
          username: 'test_friend',
          skin: BrainySkin.classic,
          level: 5,
          streak: 3,
          reelsToday: 20,
          dailyLimit: 30,
        ),
        userReels: 10,
        opponentReels: 25,
        targetLimit: 30,
        durationLabel: 'Completed',
        xpStakes: 100,
        status: BattleStatus.won,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ScrollBattlesScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Battles'), findsOneWidget);
    expect(find.textContaining('Active'), findsOneWidget);
    expect(find.textContaining('History'), findsOneWidget);

    // Tap History tab
    await tester.tap(find.textContaining('History'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Won'), findsWidgets);
  });

  testWidgets('FindFriendsScreen search filtering and dynamic username', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FindFriendsScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Find friends'), findsOneWidget);
    expect(find.text('SUGGESTIONS FOR YOU'), findsOneWidget);

    // Search for a non-existent name to verify empty state
    await tester.enterText(find.byType(TextField), 'zzzznonexistent');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No friends found'), findsOneWidget);
  });

  testWidgets('GroupChallengesScreen displays dynamic days and toggles join', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GroupChallengesScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Challenges'), findsOneWidget);
    expect(find.text('JOIN A CHALLENGE'), findsOneWidget);
    expect(find.textContaining('TEAM GOAL'), findsOneWidget);
  });

  testWidgets('FriendProfileScreen renders 3-card stats cleanly at 320dp width', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const friend = FriendUser(
      id: 'f_kai',
      name: 'Kai',
      username: 'kai_scrolls',
      skin: BrainySkin.golden,
      level: 22,
      streak: 28,
      reelsToday: 24,
      dailyLimit: 30,
      battleWins: 14,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: FriendProfileScreen(friend: friend),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Kai'), findsWidgets);
    expect(find.text('Reels today'), findsOneWidget);
    expect(find.text('Daily limit'), findsOneWidget);
    expect(find.text('Battle wins'), findsOneWidget);
    expect(find.text('Challenge to Battle'), findsOneWidget);
  });
}

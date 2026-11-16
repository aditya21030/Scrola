import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/focus_mode_service.dart';
import 'package:scrola/core/services/gamification_engine.dart';
import 'package:scrola/core/services/social_service.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';
import 'package:scrola/features/brain/presentation/screens/brain_details_screen.dart';
import 'package:scrola/features/brain/presentation/screens/rewards_screen.dart';
import 'package:scrola/features/brain/presentation/screens/streak_calendar_screen.dart';
import 'package:scrola/features/focus/presentation/screens/active_focus_session_screen.dart';
import 'package:scrola/features/focus/presentation/screens/focus_session_setup_screen.dart';
import 'package:scrola/features/friends/presentation/screens/create_battle_screen.dart';
import 'package:scrola/features/friends/presentation/screens/find_friends_screen.dart';
import 'package:scrola/features/friends/presentation/screens/friends_dashboard_screen.dart';
import 'package:scrola/features/friends/presentation/screens/friends_leaderboard_screen.dart';
import 'package:scrola/features/friends/presentation/screens/group_challenges_screen.dart';
import 'package:scrola/features/home/presentation/screens/home_screen.dart';
import 'package:scrola/features/insights/presentation/screens/daily_scroll_history_screen.dart';
import 'package:scrola/features/insights/presentation/screens/insights_dashboard_screen.dart';
import 'package:scrola/features/insights/presentation/screens/live_tracking_screen.dart';
import 'package:scrola/features/insights/presentation/screens/monthly_report_screen.dart';
import 'package:scrola/features/insights/presentation/screens/platform_breakdown_screen.dart';
import 'package:scrola/features/insights/presentation/screens/reel_limit_setup_screen.dart';
import 'package:scrola/features/insights/presentation/screens/tracking_status_screen.dart';
import 'package:scrola/features/insights/presentation/screens/weekly_report_screen.dart';
import 'package:scrola/features/profile/presentation/screens/about_scrola_screen.dart';
import 'package:scrola/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:scrola/features/profile/presentation/screens/notifications_settings_screen.dart';
import 'package:scrola/features/profile/presentation/screens/privacy_controls_screen.dart';
import 'package:scrola/features/profile/presentation/screens/profile_screen.dart';
import 'package:scrola/features/profile/presentation/screens/settings_screen.dart';
import 'package:scrola/features/profile/presentation/screens/subscription_pro_screen.dart';
import 'package:scrola/features/profile/presentation/screens/terms_of_service_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'scrola_selected_platforms': ['instagram', 'tiktok', 'youtube'],
      'scrola_xp_total': 150,
      'scrola_streak_days': 3,
      'scrola_total_today': 12,
      'scrola_limit_total': 50,
      'scrola_pro_subscribed': false,
    });
    StorageService.resetForTest();

    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'isAccessibilityServiceEnabled':
        case 'isOverlayPermissionGranted':
        case 'isNotificationPermissionGranted':
        case 'startOverlayService':
        case 'stopOverlayService':
        case 'syncLimits':
        case 'refreshOverlayConfig':
        case 'resetDailyStats':
          return true;
        case 'getNativeStats':
          return <String, dynamic>{'totalToday': 12, 'sessionCount': 2};
        default:
          return null;
      }
    });
  });

  tearDown(() {
    const channel = MethodChannel('com.scrola.app/native');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('Inspection 1: HomeScreen buttons, bars, cards, and modal triggers', (tester) async {
    final tracking = TrackingService();
    await tracking.resetForTest();
    await tracking.initialize();
    await tracking.checkPermissions();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Notification bell button
    final bellFinder = find.byIcon(Icons.notifications_none_rounded);
    expect(bellFinder, findsOneWidget);
    await tester.tap(bellFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(NotificationsSettingsScreen), findsOneWidget);

    // Pop back to HomeScreen
    Navigator.of(tester.element(find.byType(NotificationsSettingsScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 2. Resting badge is centered
    expect(find.text('Scrola is resting. Turn on to launch!'), findsOneWidget);

    // 3. Reels today counter tap opens ReelLimitSetupScreen
    final counterFinder = find.text('12');
    expect(counterFinder, findsOneWidget);
    await tester.tap(counterFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ReelLimitSetupScreen), findsOneWidget);

    // Pop back
    Navigator.of(tester.element(find.byType(ReelLimitSetupScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 4. Primary orange Turn Scrola On card
    final toggleCard = find.text('Turn Scrola On');
    expect(toggleCard, findsOneWidget);
    await tester.tap(toggleCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tracking.isTrackingEnabled, isTrue);
    expect(find.text('Turn Scrola Off'), findsOneWidget);

    // Turn off again
    await tester.tap(find.text('Turn Scrola Off'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tracking.isTrackingEnabled, isFalse);

    // 5. Platform Breakdown tap opens PlatformBreakdownScreen
    final detailsBtn = find.text('Details');
    await tester.ensureVisible(detailsBtn);
    await tester.tap(detailsBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PlatformBreakdownScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(PlatformBreakdownScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 6. Brain Level card rewards button opens RewardsScreen
    final rewardsBtn = find.text('Rewards');
    await tester.ensureVisible(rewardsBtn);
    await tester.tap(rewardsBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(RewardsScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(RewardsScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 7. Streak card calendar button opens StreakCalendarScreen
    final calendarBtn = find.text('Calendar');
    await tester.ensureVisible(calendarBtn);
    await tester.tap(calendarBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(StreakCalendarScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(StreakCalendarScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 8. Focus banner card opens FocusSessionSetupScreen
    final focusBtn = find.text('Start focus');
    await tester.ensureVisible(focusBtn);
    await tester.tap(focusBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(FocusSessionSetupScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(FocusSessionSetupScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 9. Bottom status dot: Tracking opens TrackingStatusScreen
    final trackingDot = find.text('Tracking');
    await tester.ensureVisible(trackingDot);
    await tester.tap(trackingDot);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TrackingStatusScreen), findsOneWidget);
  });

  testWidgets('Inspection 2: Insights tab buttons, period switcher, and reports links', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: InsightsDashboardScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Period toggle: Week / Month
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    await tester.tap(find.text('Month'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('34'), findsOneWidget); // Month average

    await tester.tap(find.text('Week'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('36'), findsOneWidget); // Week average

    // 2. Weekly Report card
    final weeklyCard = find.text('Weekly Report');
    await tester.ensureVisible(weeklyCard);
    await tester.tap(weeklyCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(WeeklyReportScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(WeeklyReportScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 3. Monthly Report card
    final monthlyCard = find.text('Monthly Report');
    await tester.ensureVisible(monthlyCard);
    await tester.tap(monthlyCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MonthlyReportScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(MonthlyReportScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 4. View full daily scroll log button
    final logBtn = find.text('View full daily scroll log');
    await tester.ensureVisible(logBtn);
    await tester.tap(logBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(DailyScrollHistoryScreen), findsOneWidget);
  });

  testWidgets('Inspection 3: Friends tab buttons, avatar strip, battle, and leaderboard', (tester) async {
    final social = SocialService();
    social.resetForTest();
    await social.initialize();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FriendsDashboardScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Header Add friend icon button
    final addIcon = find.byIcon(Icons.person_add_alt_1_rounded);
    expect(addIcon, findsOneWidget);
    await tester.tap(addIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(FindFriendsScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(FindFriendsScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 2. Avatar strip: You avatar and Add button
    expect(find.text('You'), findsWidgets);
    expect(find.text('Add'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(FindFriendsScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(FindFriendsScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 3. Battle button: Start a Battle
    final startBattleBtn = find.text('Start a Battle');
    await tester.ensureVisible(startBattleBtn);
    await tester.tap(startBattleBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CreateBattleScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(CreateBattleScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 4. Leaderboard "View all"
    final viewAllBtn = find.text('View all');
    await tester.ensureVisible(viewAllBtn);
    await tester.tap(viewAllBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(FriendsLeaderboardScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(FriendsLeaderboardScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 5. Group Challenges "Explore"
    final exploreBtn = find.text('Explore');
    await tester.ensureVisible(exploreBtn);
    await tester.tap(exploreBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(GroupChallengesScreen), findsOneWidget);
  });

  testWidgets('Inspection 4: Focus session setup duration chips, steppers, and launch', (tester) async {
    addTearDown(() async => await FocusModeService().cancelSession());
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FocusSessionSetupScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Initial duration is 25 min
    expect(find.text('25'), findsWidgets);

    // 2. Increment duration with stepper
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('30'), findsOneWidget);

    // 3. Tap 45 min chip
    await tester.tap(find.text('45 min'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('45'), findsWidgets);

    // 4. Start Focus Session
    final startBtn = find.text('Start 45 min session');
    expect(startBtn, findsOneWidget);
    await tester.tap(startBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ActiveFocusSessionScreen), findsOneWidget);

    // Cancel the session to clean up the ticker timer
    await FocusModeService().cancelSession();
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Inspection 5: Profile screen, Pro card, menu links, and centered version', (tester) async {
    final tracking = TrackingService();
    await tracking.resetForTest();
    await tracking.initialize();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Edit Profile card tap (via edit pencil icon)
    final editIcon = find.byIcon(Icons.edit_rounded);
    expect(editIcon, findsOneWidget);
    await tester.tap(editIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(EditProfileScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(EditProfileScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 2. Settings gear button
    final settingsGear = find.byIcon(Icons.settings_outlined).first;
    expect(settingsGear, findsOneWidget);
    await tester.tap(settingsGear);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SettingsScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(SettingsScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 3. Scrola Pro card "See plans" button
    final seePlans = find.text('See plans');
    await tester.ensureVisible(seePlans);
    await tester.tap(seePlans);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SubscriptionProScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(SubscriptionProScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 4. Notifications menu row
    final notifFinder = find.text('Notifications');
    await tester.ensureVisible(notifFinder);
    await tester.tap(notifFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(NotificationsSettingsScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(NotificationsSettingsScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 5. Privacy & Data Controls row
    final privacyFinder = find.text('Privacy & Data Controls');
    await tester.ensureVisible(privacyFinder);
    await tester.tap(privacyFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PrivacyControlsScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(PrivacyControlsScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 6. Terms of Service row
    final termsFinder = find.text('Terms of Service');
    await tester.ensureVisible(termsFinder);
    await tester.tap(termsFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TermsOfServiceScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(TermsOfServiceScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 7. About Scrola row
    final aboutFinder = find.text('About Scrola');
    await tester.ensureVisible(aboutFinder);
    await tester.tap(aboutFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AboutScrolaScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(AboutScrolaScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // 8. Help and feedback shows snackbar
    final helpFinder = find.text('Help and feedback');
    await tester.ensureVisible(helpFinder);
    await tester.tap(helpFinder);
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Support: yousfulstudio@gmail.com'), findsOneWidget);

    // 9. Centered version number and publisher branding at bottom
    final versionFinder = find.text('Scrola v1.0.0 (Build 4)');
    await tester.ensureVisible(versionFinder);
    expect(versionFinder, findsOneWidget);
    expect(find.text('Made with ❤️ by Yousful Studio'), findsOneWidget);
  });

  testWidgets('Inspection 6: SubscriptionProScreen tier selector, terms/privacy wrap links, and responsiveness', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: SubscriptionProScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // 1. All 3 tiers exist and are selectable
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('Lifetime'), findsOneWidget);

    await tester.tap(find.text('Lifetime'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('BEST VALUE'), findsOneWidget);
    expect(find.text('Pay once · Keep forever'), findsOneWidget);

    await tester.tap(find.text('Monthly'));
    await tester.pump(const Duration(milliseconds: 200));

    // 2. Footer wrap links: Privacy Policy and Terms of Service
    final privacyLink = find.text('Privacy Policy');
    await tester.ensureVisible(privacyLink);
    await tester.tap(privacyLink);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PrivacyControlsScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(PrivacyControlsScreen))).pop();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    final termsLink = find.text('Terms of Service');
    await tester.ensureVisible(termsLink);
    await tester.tap(termsLink);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TermsOfServiceScreen), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrola/core/services/storage_service.dart';
import 'package:scrola/core/services/tracking_service.dart';
import 'package:scrola/features/insights/presentation/screens/daily_scroll_history_screen.dart';
import 'package:scrola/features/insights/presentation/screens/insights_dashboard_screen.dart';
import 'package:scrola/features/insights/presentation/screens/live_tracking_screen.dart';
import 'package:scrola/features/insights/presentation/screens/monthly_report_screen.dart';
import 'package:scrola/features/insights/presentation/screens/platform_breakdown_screen.dart';
import 'package:scrola/features/insights/presentation/screens/platform_limits_screen.dart';
import 'package:scrola/features/insights/presentation/screens/reel_limit_setup_screen.dart';
import 'package:scrola/features/insights/presentation/screens/tracking_status_screen.dart';
import 'package:scrola/features/insights/presentation/screens/weekly_report_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetForTest();
    await StorageService.getInstance();
    await TrackingService().initialize();
  });

  testWidgets('InsightsDashboardScreen renders cleanly at constrained 320dp width with showBack=true', (tester) async {
    tester.view.physicalSize = const Size(320, 680);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: InsightsDashboardScreen(showBack: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('DAILY AVERAGE'), findsOneWidget);
    expect(find.text('7-Day Scroll Trend'), findsOneWidget);
    expect(find.text('Platform share'), findsOneWidget);
    expect(find.text('Weekly Report'), findsOneWidget);
    expect(find.text('Monthly Report'), findsOneWidget);
  });

  testWidgets('InsightsDashboardScreen period toggle switches between Week and Month', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InsightsDashboardScreen(showBack: false),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);

    // Switch to Month
    await tester.tap(find.text('Month'));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify daily avg updates
    expect(find.text('18% less'), findsOneWidget);

    // Switch back to Week
    await tester.tap(find.text('Week'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('12% less'), findsOneWidget);
  });

  testWidgets('DailyScrollHistoryScreen renders 7-day bars and exports CSV', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DailyScrollHistoryScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('History'), findsOneWidget);
    expect(find.text('DAILY AVERAGE'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);

    // Tap Export
    await tester.tap(find.text('Export'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('CSV copied to clipboard'), findsOneWidget);
  });

  testWidgets('LiveTrackingScreen renders session counter and break button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LiveTrackingScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Live tracking'), findsOneWidget);
    expect(find.text('reels this session'), findsOneWidget);
    expect(find.text('Take a 5 minute break'), findsOneWidget);
    expect(find.text('Reset session count'), findsOneWidget);
  });

  testWidgets('MonthlyReportScreen renders 30-day grid and exports data', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MonthlyReportScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Monthly report'), findsOneWidget);
    expect(find.text('MONTH IN REVIEW'), findsOneWidget);
    expect(find.text('Weekly trajectory'), findsOneWidget);
    expect(find.text('Days under your limit'), findsOneWidget);
    expect(find.text('Export CSV & full data'), findsOneWidget);

    // Ensure visible and tap Export CSV & full data
    await tester.ensureVisible(find.text('Export CSV & full data'));
    await tester.tap(find.text('Export CSV & full data'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Monthly data & CSV copied to clipboard!'), findsOneWidget);
  });

  testWidgets('PlatformBreakdownScreen switches periods and renders per-app cards', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlatformBreakdownScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Platforms'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);

    // Tap Week
    await tester.tap(find.text('Week'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('reels past 7d'), findsOneWidget);
  });

  testWidgets('PlatformLimitsScreen toggles per-app limit enforcement', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlatformLimitsScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Platform limits'), findsOneWidget);
    expect(find.text('ALLOCATED'), findsOneWidget);
    expect(find.text('Enforce per-app limits'), findsOneWidget);
    expect(find.text('Save limits'), findsOneWidget);
  });

  testWidgets('ReelLimitSetupScreen adjusts limits via stepper and presets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ReelLimitSetupScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Daily limit'), findsOneWidget);
    expect(find.text('REELS PER DAY'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('Save limit'), findsOneWidget);

    // Tap preset 60
    await tester.tap(find.text('60'));
    await tester.pump(const Duration(milliseconds: 100));

    // Save
    await tester.tap(find.text('Save limit'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(TrackingService().totalLimit, equals(60));
  });

  testWidgets('TrackingStatusScreen checks permissions and troubleshooting', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TrackingStatusScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tracking status'), findsOneWidget);
    expect(find.text('Accessibility'), findsOneWidget);
    expect(find.text('Floating counter'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Battery optimisation'), findsOneWidget);
    expect(find.text('Troubleshoot tracking'), findsOneWidget);
  });

  testWidgets('WeeklyReportScreen renders weekly stats and Brainy recommendations', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WeeklyReportScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Weekly report'), findsOneWidget);
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('Daily breakdown'), findsOneWidget);
    expect(find.text('Best day'), findsOneWidget);
    expect(find.text('Brainy says'), findsOneWidget);
    expect(find.text('Share report'), findsOneWidget);
  });
}

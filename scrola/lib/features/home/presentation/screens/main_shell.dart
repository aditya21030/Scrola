import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../brain/presentation/screens/brain_overview_screen.dart';
import '../../../focus/presentation/screens/focus_dashboard_screen.dart';
import '../../../insights/presentation/screens/daily_scroll_history_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/scrola_bottom_nav.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  final TrackingService _tracking = TrackingService();
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
    _tracking.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tracking.refreshPermissionsAndSyncOverlay();
      _tracking.syncFromNative();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primaryBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(
                onSwitchTab: (idx) => setState(() => _currentIndex = idx),
              ),
              const DailyScrollHistoryScreen(showBack: false),
              const FocusDashboardScreen(showBack: false),
              const BrainOverviewScreen(showBack: false),
              const ProfileScreen(showBack: false),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScrolaBottomNav(
              currentIndex: _currentIndex,
              onTabSelected: (idx) => setState(() => _currentIndex = idx),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/registration_prompt_modal.dart';
import '../../../brain/presentation/screens/brain_overview_screen.dart';
import '../../../focus/presentation/widgets/limit_reached_modal.dart';
import '../../../friends/presentation/screens/friends_dashboard_screen.dart';
import '../../../insights/presentation/screens/insights_dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/scrola_bottom_nav.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  final bool promptRegistration;

  const MainShell({
    super.key,
    this.initialIndex = 0,
    this.promptRegistration = false,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  final TrackingService _tracking = TrackingService();
  StreamSubscription<void>? _limitSub;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
    _tracking.initialize();

    _limitSub = _tracking.onLimitReached.listen((_) {
      if (mounted) {
        LimitReachedModal.show(context);
      }
    });

    if (widget.promptRegistration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 650), () {
          if (mounted && AuthService().isGuest) {
            RegistrationPromptModal.show(context);
          }
        });
      });
    }
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
    _limitSub?.cancel();
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

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(
                  onSwitchTab: (idx) => setState(() => _currentIndex = idx),
                ),
                const InsightsDashboardScreen(showBack: false),
                const FriendsDashboardScreen(showBack: false),
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
      ),
    );
  }
}

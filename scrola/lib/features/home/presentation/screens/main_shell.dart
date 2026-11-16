import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
      StorageService.getInstance().then((storage) {
        storage.checkDailyReset();
      });
      _tracking.refreshPermissionsAndSyncOverlay();
      _tracking.syncFromNative();
    }
  }

  Future<void> _showSafeExitDialog(BuildContext context) async {
    HapticService.subtle();
    final bool isTracking = _tracking.isTrackingEnabled;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryAccent.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.primaryAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Exit Scrola?',
              style: AppTypography.subheading().copyWith(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          isTracking
              ? 'Brainy will continue guarding and counting your reels in the background.'
              : 'Are you sure you want to close Scrola?',
          style: AppTypography.caption(color: AppColors.secondaryText)
              .copyWith(fontSize: 13.5, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep open',
              style: AppTypography.caption(color: AppColors.secondaryText)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: AppColors.textOnAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Exit',
              style: AppTypography.caption(color: AppColors.textOnAccent)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await SystemNavigator.pop();
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
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        await _showSafeExitDialog(context);
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

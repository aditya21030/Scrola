import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../home/presentation/screens/main_shell.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _entranceController;
  late AnimationController _loadBarController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _loadBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _bootApp();
  }

  Future<void> _bootApp() async {
    final tracking = TrackingService();
    await tracking.initialize();
    await Future.delayed(const Duration(milliseconds: 1900));

    if (!mounted) return;

    final Widget targetScreen = tracking.isOnboardingComplete
        ? const MainShell()
        : const WelcomeScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => targetScreen,
        transitionDuration: AppMotion.standard,
        transitionsBuilder: (_, anim, _, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    _loadBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Top Warm Radial Glow
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.28),
                radius: 0.78,
                colors: [
                  AppColors.primaryAccent.withValues(alpha: 0.45),
                  AppColors.primaryAccent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),

          // Pulsing Concentric Rings (3 staggered rings from 01-splash.html)
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final progress = (_pulseController.value + (index * 0.33)) % 1.0;
                final scale = 0.85 + (progress * 0.35);
                final opacity = (1.0 - progress) * 0.45;
                final diameter = 240.0 + (index * 95.0);

                return Positioned(
                  top: size.height * 0.25 - (diameter - 240) / 2,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: diameter,
                      height: diameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accentHighlight.withValues(alpha: opacity),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Mascot & Brand Title Rising Entrance
          FadeTransition(
            opacity: _entranceController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _entranceController,
                curve: AppMotion.easeOut,
              )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const BrainyMascot(
                    mood: BrainyMood.happy,
                    size: 210,
                    animate: true,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Scrola',
                    style: AppTypography.title(
                      color: AppColors.primaryText,
                      size: 62,
                      weight: FontWeight.w800,
                    ).copyWith(letterSpacing: -2.0, height: 1.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Take Control of Your Scroll.',
                    style: AppTypography.body(
                      color: AppColors.warmText,
                      weight: FontWeight.w600,
                      size: 17,
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          // Bottom Loading Progress Pill
          Positioned(
            bottom: 72,
            child: Container(
              width: 120,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedBuilder(
                  animation: _loadBarController,
                  builder: (context, _) {
                    final curveVal = AppMotion.easeOut.transform(_loadBarController.value);
                    return FractionallySizedBox(
                      widthFactor: 0.08 + (0.92 * curveVal),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(
                            colors: [AppColors.accentHighlight, AppColors.primaryAccent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAccent.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

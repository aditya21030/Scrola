import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../home/presentation/screens/main_shell.dart';
import 'onboarding_wizard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: AppMotion.floatCycle,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          // Top Warm Radial Ambient Glow
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.35),
                radius: 0.72,
                colors: [
                  AppColors.primaryAccent.withValues(alpha: 0.38),
                  AppColors.primaryAccent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Arena with Orbiting Platforms & Brainy
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: SizedBox(
                        width: 320,
                        height: 290,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Dashed Orbit Circle
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.border.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                            ),

                            // Brainy Center
                            const BrainyMascot(
                              mood: BrainyMood.happy,
                              size: 165,
                            ),

                            // Orbiting Platform Tiles
                            _buildFloatingPlatform(
                              top: 26,
                              left: 24,
                              offsetFactor: 1.0,
                              platform: SocialPlatform.instagram,
                            ),
                            _buildFloatingPlatform(
                              top: 18,
                              right: 28,
                              offsetFactor: -0.8,
                              platform: SocialPlatform.youtube,
                            ),
                            _buildFloatingPlatform(
                              bottom: 24,
                              left: 22,
                              offsetFactor: -1.0,
                              platform: SocialPlatform.facebook,
                            ),
                            _buildFloatingPlatform(
                              bottom: 28,
                              right: 20,
                              offsetFactor: 0.9,
                              platform: SocialPlatform.snapchat,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Editorial Copy
                  Text(
                    'Take Control\nof Your\nScroll.',
                    style: AppTypography.title(
                      color: AppColors.primaryText,
                      size: 44,
                      weight: FontWeight.w800,
                    ).copyWith(height: 1.04, letterSpacing: -1.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scrola counts the reels you watch and keeps you under the limit you set.',
                    style: AppTypography.body(
                      color: AppColors.secondaryText,
                      size: 16,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Primary CTA
                  ScrolaPrimaryButton(
                    label: 'Get started',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OnboardingWizardScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // Secondary Link
                  ScrolaLinkButton(
                    label: 'I already have an account',
                    onPressed: () async {
                      await TrackingService().completeOnboarding(
                        goal: 'Stay under a daily limit',
                        dailyLimit: 40,
                        platforms: ['instagram', 'youtube'],
                      );
                      await HapticService.medium();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainShell()),
                        (_) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingPlatform({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double offsetFactor,
    required SocialPlatform platform,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final dy = (_floatController.value - 0.5) * 10 * offsetFactor;
          return Transform.translate(
            offset: Offset(0, dy),
            child: child,
          );
        },
        child: PlatformIcon(
          platform: platform,
          size: 46,
        ),
      ),
    );
  }
}

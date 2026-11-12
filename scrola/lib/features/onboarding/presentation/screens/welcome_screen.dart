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
  bool _completingQuickStart = false;

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 42).clamp(0.0, 2000.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        // Hero Arena with Orbiting Platforms & Brainy
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: 280,
                              height: 268,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 224,
                                    height: 224,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primaryAccent
                                            .withValues(alpha: 0.14),
                                        width: 1,
                                      ),
                                      gradient: RadialGradient(
                                        colors: [
                                          AppColors.primaryAccent
                                              .withValues(alpha: 0.14),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  const BrainyMascot(
                                    mood: BrainyMood.happy,
                                    size: 156,
                                  ),
                                  _buildFloatingPlatform(
                                    top: 18,
                                    left: 16,
                                    offsetFactor: 1.0,
                                    platform: SocialPlatform.instagram,
                                  ),
                                  _buildFloatingPlatform(
                                    top: 14,
                                    right: 16,
                                    offsetFactor: -0.8,
                                    platform: SocialPlatform.youtube,
                                  ),
                                  _buildFloatingPlatform(
                                    bottom: 18,
                                    left: 14,
                                    offsetFactor: -1.0,
                                    platform: SocialPlatform.facebook,
                                  ),
                                  _buildFloatingPlatform(
                                    bottom: 20,
                                    right: 14,
                                    offsetFactor: 0.9,
                                    platform: SocialPlatform.snapchat,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Centered Editorial Copy matching 02-welcome.html
                        Column(
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Take Control of\nYour ',
                                style: AppTypography.title(
                                  color: AppColors.primaryText,
                                  size: 38,
                                  weight: FontWeight.w800,
                                ).copyWith(height: 1.08, letterSpacing: -1.0),
                                children: [
                                  TextSpan(
                                    text: 'Scroll.',
                                    style: AppTypography.title(
                                      color: AppColors.primaryAccent,
                                      size: 38,
                                      weight: FontWeight.w800,
                                    ).copyWith(
                                        height: 1.08, letterSpacing: -1.0),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 310),
                              child: Text(
                                'Scrola counts the reels you watch and stops endless loops before they steal your day.',
                                textAlign: TextAlign.center,
                                style: AppTypography.body(
                                  color: AppColors.secondaryText,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ScrolaPrimaryButton(
                              label: 'Get started',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const OnboardingWizardScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            ScrolaLinkButton(
                              label: 'Skip setup & use defaults',
                              onPressed: () async {
                                if (_completingQuickStart) return;
                                _completingQuickStart = true;
                                try {
                                  await TrackingService().completeOnboarding(
                                    goal: 'Stay under a daily limit',
                                    dailyLimit: 40,
                                    platforms: const ['instagram', 'youtube'],
                                  );
                                  await HapticService.medium();
                                  if (!context.mounted) return;
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const MainShell(),
                                    ),
                                    (_) => false,
                                  );
                                } finally {
                                  if (mounted) _completingQuickStart = false;
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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

import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import 'evolution_cutscene_screen.dart';

class LevelUpScreen extends StatefulWidget {
  final int newLevel;
  final int bonusXP;

  const LevelUpScreen({
    super.key,
    required this.newLevel,
    this.bonusXP = 150,
  });

  static Future<void> show(BuildContext context, {required int newLevel, int bonusXP = 150}) {
    HapticService.celebratory();
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            LevelUpScreen(newLevel: newLevel, bonusXP: bonusXP),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends State<LevelUpScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();
    final stage = GamificationEngine.getStageForLevel(widget.newLevel);
    final hasNewStage = widget.newLevel == stage.minLevel && stage.stageNumber > 1;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.94),
      body: Stack(
        children: [
          // Background ambient orange glow
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryAccent.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Expanding celebration rings
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    Transform.scale(
                      scale: 0.7 + ((_anim.value + i * 0.33) % 1.0) * 0.6,
                      child: Opacity(
                        opacity: (1.0 - ((_anim.value + i * 0.33) % 1.0)).clamp(0.0, 0.6),
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryAccent.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Level Up badge
                  Center(
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'LEVEL UP',
                        style: AppTypography.caption(
                          color: AppColors.warmText,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mascot
                  Center(
                    child: BrainyMascot(
                      mood: BrainyMood.celebrating,
                      skin: tracking.equippedSkin,
                      size: 150,
                      animate: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    'Level ${widget.newLevel}',
                    textAlign: TextAlign.center,
                    style: AppTypography.title(
                      size: 38,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '+${widget.bonusXP} XP Claimed! Keep staying focused.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rewards Card
                  ScrolaCard(
                    padding: const EdgeInsets.all(18),
                    radius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UNLOCKED AT LEVEL ${widget.newLevel}',
                          style: AppTypography.label(color: AppColors.warmText),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.warmText,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hasNewStage ? 'New Evolution: ${stage.name}' : 'Daily Streak Multiplier',
                                    style: AppTypography.body(weight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    hasNewStage
                                        ? 'Your Brainy is ready to evolve to Form ${stage.stageNumber}!'
                                        : 'Earn +10% bonus XP for maintaining your clean streak.',
                                    style: AppTypography.caption(color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Actions
                  if (hasNewStage) ...[
                    ScrolaPrimaryButton(
                      label: 'Evolve Brainy Now',
                      leadingIcon: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.primaryBackground,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => EvolutionCutsceneScreen(targetStage: stage),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  ScrolaPrimaryButton(
                    label: hasNewStage ? 'Evolve Later' : 'Collect Rewards',
                    onPressed: () {
                      HapticService.light();
                      Navigator.of(context).pop();
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
}

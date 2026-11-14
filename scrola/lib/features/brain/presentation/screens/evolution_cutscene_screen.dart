import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

enum EvolutionCutsceneStep {
  ready,
  evolving,
  reveal,
  complete,
}

class EvolutionCutsceneScreen extends StatefulWidget {
  final EvolutionStage targetStage;

  const EvolutionCutsceneScreen({
    super.key,
    required this.targetStage,
  });

  @override
  State<EvolutionCutsceneScreen> createState() => _EvolutionCutsceneScreenState();
}

class _EvolutionCutsceneScreenState extends State<EvolutionCutsceneScreen>
    with TickerProviderStateMixin {
  late EvolutionCutsceneStep _currentStep;
  late final AnimationController _pulseAnim;
  late final AnimationController _rotateAnim;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _currentStep = EvolutionCutsceneStep.ready;
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _rotateAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulseAnim.dispose();
    _rotateAnim.dispose();
    super.dispose();
  }

  void _startEvolution() async {
    await HapticService.medium();
    setState(() => _currentStep = EvolutionCutsceneStep.evolving);

    // Evolve animation plays for 3.2 seconds
    _stepTimer = Timer(const Duration(milliseconds: 3200), () async {
      await HapticService.celebratory();
      if (!mounted) return;
      setState(() => _currentStep = EvolutionCutsceneStep.reveal);
    });
  }

  void _proceedToComplete() async {
    await HapticService.celebratory();
    setState(() => _currentStep = EvolutionCutsceneStep.complete);
  }

  void _finish() async {
    await HapticService.light();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == EvolutionCutsceneStep.ready ||
          _currentStep == EvolutionCutsceneStep.complete,
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Stack(
          children: [
            // Background ambient glow
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) {
                  final glowRadius = _currentStep == EvolutionCutsceneStep.evolving
                      ? 0.9
                      : (0.55 + _pulseAnim.value * 0.2);
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.15),
                        radius: glowRadius,
                        colors: [
                          _currentStep == EvolutionCutsceneStep.evolving
                              ? const Color(0xFFFFD76A).withValues(alpha: 0.55)
                              : AppColors.primaryAccent.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Rotating radiant rays
            AnimatedBuilder(
              animation: _rotateAnim,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnim.value * 2 * math.pi,
                  child: child,
                );
              },
              child: Center(
                child: Opacity(
                  opacity: _currentStep == EvolutionCutsceneStep.evolving ? 0.35 : 0.15,
                  child: Image.network(
                    'data:image/svg+xml;utf8,<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><circle cx="50" cy="50" r="48" fill="none" stroke="%23FF6B24" stroke-width="0.5" stroke-dasharray="2 4"/></svg>',
                    width: 480,
                    height: 480,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case EvolutionCutsceneStep.ready:
        return _buildReadyStep();
      case EvolutionCutsceneStep.evolving:
        return _buildEvolvingStep();
      case EvolutionCutsceneStep.reveal:
        return _buildRevealStep();
      case EvolutionCutsceneStep.complete:
        return _buildCompleteStep();
    }
  }

  // 1. Ready Step
  Widget _buildReadyStep() {
    final prevStage = widget.targetStage.stageNumber > 1
        ? widget.targetStage.stageNumber - 1
        : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Level ${widget.targetStage.minLevel} reached',
                style: AppTypography.caption(
                  color: AppColors.warmText,
                  weight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'Form $prevStage to ${widget.targetStage.stageNumber}',
              style: AppTypography.caption(color: AppColors.secondaryText),
            ),
          ],
        ),
        const Spacer(),

        Center(
          child: BrainyMascot(
            stageNumber: prevStage,
            size: 180,
            animate: true,
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Your Brainy is ready\nto evolve!',
          textAlign: TextAlign.center,
          style: AppTypography.title(size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          'Your consistent focus has unlocked the next consciousness evolution form.',
          textAlign: TextAlign.center,
          style: AppTypography.body(color: AppColors.secondaryText),
        ),

        const Spacer(),

        ScrolaPrimaryButton(
          label: 'Evolve Brainy',
          leadingIcon: const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primaryBackground,
            size: 20,
          ),
          onPressed: _startEvolution,
        ),
      ],
    );
  }

  // 2. Evolving Step
  Widget _buildEvolvingStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) {
              final scale = 1.0 + math.sin(_pulseAnim.value * math.pi) * 0.12;
              return Transform.scale(
                scale: scale,
                child: BrainyMascot(
                  stageNumber: widget.targetStage.stageNumber,
                  size: 180,
                  silhouette: true,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 36),
        Text(
          'Brainy is evolving...',
          textAlign: TextAlign.center,
          style: AppTypography.title(
            size: 28,
            color: AppColors.warmText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Absorbing focus energy and expanding cortex...',
          textAlign: TextAlign.center,
          style: AppTypography.body(color: AppColors.secondaryText),
        ),
      ],
    );
  }

  // 3. Reveal Step
  Widget _buildRevealStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryAccent),
            ),
            child: Text(
              'NEW EVOLUTION UNLOCKED',
              style: AppTypography.caption(
                color: AppColors.primaryAccent,
                weight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const Spacer(),

        Center(
          child: BrainyMascot(
            stageNumber: widget.targetStage.stageNumber,
            size: 190,
            animate: true,
          ),
        ),
        const SizedBox(height: 20),

        Text(
          widget.targetStage.name,
          textAlign: TextAlign.center,
          style: AppTypography.title(size: 32),
        ),
        const SizedBox(height: 6),
        Text(
          'Form ${widget.targetStage.stageNumber} of 30',
          textAlign: TextAlign.center,
          style: AppTypography.body(
            color: AppColors.warmText,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.targetStage.description,
          textAlign: TextAlign.center,
          style: AppTypography.body(color: AppColors.secondaryText),
        ),

        const Spacer(),

        ScrolaPrimaryButton(
          label: 'Continue',
          onPressed: _proceedToComplete,
        ),
      ],
    );
  }

  // 4. Complete Step
  Widget _buildCompleteStep() {
    final prevStage = widget.targetStage.stageNumber > 1
        ? widget.targetStage.stageNumber - 1
        : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(
          'Evolution complete!',
          textAlign: TextAlign.center,
          style: AppTypography.title(size: 30),
        ),
        const SizedBox(height: 6),
        Text(
          'Your Brainy has ascended to Form ${widget.targetStage.stageNumber}.',
          textAlign: TextAlign.center,
          style: AppTypography.body(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 24),

        // Comparison card
        ScrolaCard(
          padding: const EdgeInsets.all(20),
          radius: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Old form
              Column(
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: BrainyMascot(
                      stageNumber: prevStage,
                      size: 64,
                      animate: false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Form $prevStage',
                    style: AppTypography.caption(color: AppColors.secondaryText),
                  ),
                  Text('Previous', style: AppTypography.caption()),
                ],
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.warmText,
                size: 24,
              ),
              // New form
              Column(
                children: [
                  BrainyMascot(
                    stageNumber: widget.targetStage.stageNumber,
                    size: 80,
                    animate: true,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.targetStage.name,
                    style: AppTypography.body(
                      color: AppColors.primaryAccent,
                      weight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Form ${widget.targetStage.stageNumber}',
                    style: AppTypography.caption(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Added to collection badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Added to your collection & unlocked forever',
                  style: AppTypography.body(weight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        ScrolaPrimaryButton(
          label: 'Continue to Scrola',
          onPressed: _finish,
        ),
      ],
    );
  }
}

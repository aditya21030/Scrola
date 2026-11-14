import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';

class InAppGuideScreen extends StatefulWidget {
  const InAppGuideScreen({super.key});

  @override
  State<InAppGuideScreen> createState() => _InAppGuideScreenState();
}

class _InAppGuideScreenState extends State<InAppGuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_GuideStep> _steps = const [
    _GuideStep(
      stepNum: 1,
      title: "Hi, I'm Brainy",
      body: "I'll show you around Scrola. It takes about 30 seconds.",
      mood: BrainyMood.happy,
      skin: BrainySkin.classic,
      ctaLabel: "Show me around",
    ),
    _GuideStep(
      stepNum: 2,
      title: "Your reels today",
      body:
          "Every short-form video you swipe counts up in real-time. Your daily limit keeps dopamine in check.",
      mood: BrainyMood.focused,
      skin: BrainySkin.classic,
      ctaLabel: "Next",
    ),
    _GuideStep(
      stepNum: 3,
      title: "Every app counted",
      body:
          "Instagram Reels, YouTube Shorts, and Facebook Reels are automatically tracked under one shared daily limit.",
      mood: BrainyMood.neutral,
      skin: BrainySkin.classic,
      ctaLabel: "Next",
    ),
    _GuideStep(
      stepNum: 4,
      title: "Stay under it, level up",
      body:
          "Staying under your limit earns you XP, extends your streak, and unlocks all 30 Brainy evolution forms.",
      mood: BrainyMood.celebrating,
      skin: BrainySkin.golden,
      ctaLabel: "Next",
    ),
    _GuideStep(
      stepNum: 5,
      title: "Need a break?",
      body:
          "Start a quick Focus session to block short-form reels completely while you work, study, or unwind.",
      mood: BrainyMood.focused,
      skin: BrainySkin.classic,
      ctaLabel: "Next",
    ),
    _GuideStep(
      stepNum: 6,
      title: "Counter over your apps",
      body:
          "A discreet floating counter sits over your reel apps so you always know your reel budget at a glance.",
      mood: BrainyMood.happy,
      skin: BrainySkin.classic,
      ctaLabel: "Next",
    ),
    _GuideStep(
      stepNum: 7,
      title: "Find your way around",
      body:
          "Use the bottom bar to switch between Home, Insights, Battles, Brain evolution, and your Profile.",
      mood: BrainyMood.focused,
      skin: BrainySkin.classic,
      ctaLabel: "Next",
    ),
    _GuideStep(
      stepNum: 8,
      title: "You're ready!",
      body:
          "Reclaim your screen time and start your journey towards healthier digital habits.",
      mood: BrainyMood.celebrating,
      skin: BrainySkin.classic,
      ctaLabel: "Start using Scrola",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticService.light();
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top progress bar / skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${step.stepNum} of ${_steps.length}',
                    style: AppTypography.caption(color: AppColors.primaryAccent)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticService.subtle();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Skip tour',
                      style: AppTypography.caption(
                          color: AppColors.secondaryText)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Segmented progress line
              Row(
                children: List.generate(_steps.length, (index) {
                  final isDone = index <= _currentPage;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.primaryAccent
                            : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(flex: 2),
              // Mascot with halo
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: BrainyMascot(
                      mood: step.mood,
                      skin: step.skin,
                      size: 160,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              // PageView for titles and descriptions
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final item = _steps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.title().copyWith(fontSize: 30),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.body,
                            textAlign: TextAlign.center,
                            style: AppTypography.body(
                              color: AppColors.secondaryText,
                            ).copyWith(fontSize: 15, height: 1.45),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Spacer(flex: 2),
              ScrolaPrimaryButton(
                label: step.ctaLabel,
                onTap: _nextPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideStep {
  final int stepNum;
  final String title;
  final String body;
  final BrainyMood mood;
  final BrainySkin skin;
  final String ctaLabel;

  const _GuideStep({
    required this.stepNum,
    required this.title,
    required this.body,
    required this.mood,
    required this.skin,
    required this.ctaLabel,
  });
}

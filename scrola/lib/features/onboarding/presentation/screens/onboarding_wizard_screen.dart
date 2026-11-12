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
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_toggle.dart';
import '../../../home/presentation/screens/main_shell.dart';

class OnboardingWizardScreen extends StatefulWidget {
  final bool isReplay;

  const OnboardingWizardScreen({super.key, this.isReplay = false});

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> with WidgetsBindingObserver {
  final TrackingService _tracking = TrackingService();
  int _step = 0; // 0 to 8 (maps to screens 03..11)
  final List<int> _stepHistory = [0];
  int _howItWorksSlide = 0; // 0..2 inside screen 03
  bool _submitting = false;

  // Screen 04 state
  final Set<String> _selectedPlatforms = {'instagram', 'youtube'};

  // Screen 11 state
  String _selectedGoal = 'Stay under a daily limit';
  int _dailyLimit = 40;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isReplay) {
      _selectedPlatforms
        ..clear()
        ..addAll(_tracking.selectedPlatforms);
      _selectedGoal = _tracking.selectedGoal;
      _dailyLimit = _tracking.totalLimit.clamp(5, 200);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tracking.refreshPermissionsAndSyncOverlay();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _goToStep(int targetStep) {
    HapticService.light();
    setState(() {
      _step = targetStep;
      if (_stepHistory.isEmpty || _stepHistory.last != targetStep) {
        _stepHistory.add(targetStep);
      }
    });
    if (targetStep == 7) {
      HapticService.celebratory();
    }
  }

  void _nextStep() {
    if (_step < 8) {
      _goToStep(_step + 1);
    }
  }

  void _prevStep() {
    HapticService.subtle();
    if (_step == 0 && _howItWorksSlide > 0) {
      setState(() => _howItWorksSlide--);
    } else if (_stepHistory.length > 1) {
      setState(() {
        _stepHistory.removeLast();
        _step = _stepHistory.last;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _prevStep();
        }
      },
      child: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: AppColors.primaryBackground,
            body: SafeArea(
              child: Column(
                children: [
                  // Top Bar with Back & Step Progress
                  _buildTopProgress(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: AppMotion.standard,
                      switchInCurve: AppMotion.easeOut,
                      child: KeyedSubtree(
                        key: ValueKey('step_${_step}_$_howItWorksSlide'),
                        child: _buildStepBody(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopProgress() {
    const totalSteps = 9;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prevStep,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceSolid,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: AppColors.primaryText,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _step == 0
                ? Row(
                    children: List.generate(3, (i) {
                      final active = i <= _howItWorksSlide;
                      return Expanded(
                        child: Container(
                          height: 5,
                          margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primaryAccent
                                : AppColors.surfaceSolid,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  )
                : Row(
                    children: List.generate(totalSteps - 1, (i) {
                      final active = (i + 1) <= _step;
                      return Expanded(
                        child: Container(
                          height: 5,
                          margin:
                              EdgeInsets.only(right: i < totalSteps - 2 ? 4 : 0),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primaryAccent
                                : AppColors.surfaceSolid,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
          ),
          const SizedBox(width: 14),
          if (_step == 0)
            GestureDetector(
              onTap: () {
                _goToStep(1);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Skip',
                  style: AppTypography.caption(
                    color: AppColors.secondaryText,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: 44,
              child: Text(
                '$_step / ${totalSteps - 1}',
                textAlign: TextAlign.right,
                style: AppTypography.caption(
                  color: AppColors.secondaryText,
                  weight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Scroll-safe step frame keeping scrollable body centered and CTAs anchored.
  Widget _stepScaffold({
    required Widget body,
    required Widget footer,
    bool centerVertically = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 28).clamp(0.0, 2000.0),
                  ),
                  child: Column(
                    mainAxisAlignment: centerVertically
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [body],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
          child: footer,
        ),
      ],
    );
  }

  Widget _stepHeaderWithBrainy({
    required String title,
    required String subtitle,
    BrainyMood mood = BrainyMood.happy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.title(size: 28)),
              const SizedBox(height: 8),
              Text(subtitle, style: AppTypography.body()),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: BrainyMascot(mood: mood, size: 54, animate: false),
        ),
      ],
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case 0:
        return _buildHowScrolaWorks(); // 03
      case 1:
        return _buildPlatformSelection(); // 04
      case 2:
        return _buildAccessibilityExplain(); // 05
      case 3:
        return _buildAccessibilitySetup(); // 06
      case 4:
        return _buildOverlayExplain(); // 07
      case 5:
        return _buildOverlaySetup(); // 08
      case 6:
        return _buildNotificationPermission(); // 09
      case 7:
        return _buildSetupComplete(); // 10
      case 8:
      default:
        return _buildGoalSelection(); // 11
    }
  }

  // 03 - How Scrola Works (1/3, 2/3, 3/3)
  Widget _buildHowScrolaWorks() {
    final slides = [
      (
        title: 'See every reel, live',
        desc: 'Brainy docks in your top notch to show what you\'ve watched and what\'s left over your apps.',
        mood: BrainyMood.happy,
      ),
      (
        title: 'Stay within your limit',
        desc: 'Get gentle nudges as you approach your goal, then let Scrola lock the feed automatically.',
        mood: BrainyMood.focused,
      ),
      (
        title: 'Grow Brainy as you scroll less',
        desc: 'Keep daily streaks, earn XP, and evolve Brainy through 5 distinct forms.',
        mood: BrainyMood.celebrating,
      ),
    ];

    final current = slides[_howItWorksSlide];

    return _stepScaffold(
      centerVertically: true,
      body: Column(
        children: [
          // Top Notch Pill Mockup
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              constraints: const BoxConstraints(minWidth: 268, minHeight: 48),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primaryAccent.withValues(alpha: 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.22),
                    blurRadius: 20,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '24 watched',
                    style: AppTypography.caption(
                      color: AppColors.primaryText,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const BrainyMascot(
                    mood: BrainyMood.happy,
                    size: 28,
                    animate: false,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '16 left',
                    style: AppTypography.caption(
                      color: AppColors.primaryAccent,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: 196,
            height: 196,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryAccent.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: BrainyMascot(mood: current.mood, size: 158),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            current.title,
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 30),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              current.desc,
              textAlign: TextAlign.center,
              style: AppTypography.body(color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
      footer: ScrolaPrimaryButton(
        label: _howItWorksSlide < 2 ? 'Next' : 'Continue',
        onPressed: () {
          if (_howItWorksSlide < 2) {
            HapticService.subtle();
            setState(() => _howItWorksSlide++);
          } else {
            _nextStep();
          }
        },
      ),
    );
  }

  // 04 - Platform Selection
  Widget _buildPlatformSelection() {
    const platforms = SocialPlatform.values;

    return _stepScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepHeaderWithBrainy(
            title: 'Where do you\nscroll most?',
            subtitle: 'Pick the apps to watch. You can change this later.',
            mood: BrainyMood.happy,
          ),
          const SizedBox(height: 22),
          for (int i = 0; i < platforms.length; i++) ...[
            Builder(builder: (context) {
              final platform = platforms[i];
              final isSelected = _selectedPlatforms.contains(platform.id);
              return ScrolaSelectableCard(
                isSelected: isSelected,
                onTap: () {
                  HapticService.subtle();
                  setState(() {
                    if (isSelected && _selectedPlatforms.length > 1) {
                      _selectedPlatforms.remove(platform.id);
                    } else {
                      _selectedPlatforms.add(platform.id);
                    }
                  });
                },
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    PlatformIcon(platform: platform, size: 42),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            platform.reelsName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.subheading(),
                          ),
                          Text(
                            'Track reels watched',
                            style: AppTypography.caption(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primaryAccent
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: AppColors.textOnAccent,
                            )
                          : null,
                    ),
                  ],
                ),
              );
            }),
            if (i < platforms.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${_selectedPlatforms.length} apps selected',
              style: AppTypography.caption(
                color: AppColors.accentHighlight,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      footer: ScrolaPrimaryButton(label: 'Continue', onPressed: _nextStep),
    );
  }

  // 05 - Accessibility Explanation (Sees vs Never Reads)
  Widget _buildAccessibilityExplain() {
    return _stepScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepHeaderWithBrainy(
            title: 'Let Scrola count\nyour reels',
            subtitle:
                'Android notices feed swipes only through Accessibility. Here is everything it sees.',
            mood: BrainyMood.focused,
          ),
          const SizedBox(height: 22),
          ScrolaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCROLA SEES',
                  style: AppTypography.label(color: AppColors.success),
                ),
                const SizedBox(height: 14),
                _buildCheckRow(
                  Icons.check_circle_rounded,
                  AppColors.success,
                  'Which supported app feed is open',
                ),
                const SizedBox(height: 12),
                _buildCheckRow(
                  Icons.check_circle_rounded,
                  AppColors.success,
                  'When you swipe to the next reel',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ScrolaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCROLA NEVER READS',
                  style: AppTypography.label(color: AppColors.error),
                ),
                const SizedBox(height: 14),
                _buildCheckRow(
                  Icons.cancel_rounded,
                  AppColors.error,
                  'Messages, captions or comments',
                ),
                const SizedBox(height: 12),
                _buildCheckRow(
                  Icons.cancel_rounded,
                  AppColors.error,
                  'Passwords, logins or photos',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Everything stays on your device. Turn access off any time in Android Settings.',
            style: AppTypography.caption(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScrolaPrimaryButton(
            label: 'Continue to Settings',
            onPressed: _nextStep,
          ),
          const SizedBox(height: 6),
          ScrolaLinkButton(
            label: 'Not now',
            onPressed: () => _goToStep(4),
          ),
        ],
      ),
    );
  }

  // 06 - Accessibility Setup Guide (with live Android Settings bridge)
  Widget _buildAccessibilitySetup() {
    final granted = _tracking.isAccessibilityGranted;
    return _stepScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Turn on\nAccessibility', style: AppTypography.title(size: 28)),
          const SizedBox(height: 8),
          Text(
            'Do this once in Android Settings. It takes about 10 seconds.',
            style: AppTypography.body(),
          ),
          const SizedBox(height: 20),

          // Android Settings Mockup
          ScrolaCard(
            backgroundColor: AppColors.cardSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DOWNLOADED APPS',
                  style: AppTypography.label(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 10),
                // Skeleton row hinting Android list context
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: BrainyMascot(
                            mood: BrainyMood.happy,
                            size: 28,
                            animate: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Scrola', style: AppTypography.subheading()),
                            Text(
                              'Counts reels when switched on',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ScrolaToggle(
                        value: granted,
                        showPulseRing: !granted,
                        onChanged: (_) =>
                            _tracking.requestAccessibilityPermission(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          _buildNumberStep(1, 'Tap Open Settings below'),
          const SizedBox(height: 12),
          _buildNumberStep(2, 'Choose Scrola under Downloaded apps'),
          const SizedBox(height: 12),
          _buildNumberStep(3, 'Switch it on and tap Allow'),
          const SizedBox(height: 24),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: granted
                    ? AppColors.successBackground
                    : AppColors.warningBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    granted
                        ? Icons.check_circle_rounded
                        : Icons.hourglass_top_rounded,
                    size: 16,
                    color: granted ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      granted
                          ? 'Permission granted!'
                          : 'Waiting for permission',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(
                        color: granted ? AppColors.success : AppColors.warning,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScrolaPrimaryButton(
            label: granted ? 'Continue' : 'Open Settings',
            onPressed: granted
                ? _nextStep
                : () => _tracking.requestAccessibilityPermission(),
          ),
          if (!granted) ...[
            const SizedBox(height: 6),
            ScrolaLinkButton(
              label: 'I\'ve turned it on',
              onPressed: _nextStep,
            ),
          ],
        ],
      ),
    );
  }

  // 07 - Overlay Explanation
  Widget _buildOverlayExplain() {
    return _stepScaffold(
      centerVertically: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Labelled Notch Pill Diagram
                  Container(
                    constraints:
                        const BoxConstraints(minWidth: 276, minHeight: 54),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(
                        color: AppColors.primaryAccent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAccent.withValues(alpha: 0.25),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '24 watched',
                          style: AppTypography.body(
                            color: Colors.white,
                            weight: FontWeight.w700,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const BrainyMascot(
                          mood: BrainyMood.happy,
                          size: 30,
                          animate: false,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '16 left',
                          style: AppTypography.body(
                            color: AppColors.primaryAccent,
                            weight: FontWeight.w700,
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Aligned indicator stems directly below each pill region
                  const SizedBox(
                    width: 284,
                    child: Row(
                      children: [
                        Expanded(
                          child: _PillPointerLabel(
                            label: 'Watched',
                            color: AppColors.secondaryText,
                            align: CrossAxisAlignment.center,
                          ),
                        ),
                        Expanded(
                          child: _PillPointerLabel(
                            label: 'Brainy (Tap)',
                            color: AppColors.accentHighlight,
                            align: CrossAxisAlignment.center,
                          ),
                        ),
                        Expanded(
                          child: _PillPointerLabel(
                            label: 'Remaining',
                            color: AppColors.secondaryText,
                            align: CrossAxisAlignment.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Brainy docked at your\ntop screen notch',
            style: AppTypography.title(size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            'To float above Instagram, YouTube, TikTok and other reel apps, Scrola uses Android\'s "display over other apps" permission.',
            style: AppTypography.body(),
          ),
          const SizedBox(height: 8),
          Text(
            'Pinned cleanly to the top notch by default, or switch to Free mode anytime.',
            style: AppTypography.caption(color: AppColors.secondaryText),
          ),
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScrolaPrimaryButton(label: 'Continue', onPressed: _nextStep),
          const SizedBox(height: 6),
          ScrolaLinkButton(
            label: 'Skip for now',
            onPressed: () => _goToStep(6),
          ),
        ],
      ),
    );
  }

  // 08 - Overlay Permission Setup
  Widget _buildOverlaySetup() {
    final granted = _tracking.isOverlayGranted;
    return _stepScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Allow display over\nother apps', style: AppTypography.title(size: 28)),
          const SizedBox(height: 8),
          Text(
            'Open Scrola\'s page and switch the permission on so Brainy can dock at the top notch.',
            style: AppTypography.body(),
          ),
          const SizedBox(height: 20),

          ScrolaCard(
            backgroundColor: AppColors.cardSurface,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allow display over other apps',
                        style: AppTypography.subheading(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lets Brainy appear neatly at the top notch.',
                        style: AppTypography.caption(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ScrolaToggle(
                  value: granted,
                  showPulseRing: !granted,
                  onChanged: (_) => _tracking.requestOverlayPermission(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          _buildNumberStep(1, 'Tap Open Settings below'),
          const SizedBox(height: 12),
          _buildNumberStep(2, 'Tap Scrola in the apps list'),
          const SizedBox(height: 12),
          _buildNumberStep(3, 'Turn on Allow display over other apps'),
          const SizedBox(height: 24),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: granted
                    ? AppColors.successBackground
                    : AppColors.warningBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                granted ? 'Overlay permission granted!' : 'Waiting for permission',
                style: AppTypography.caption(
                  color: granted ? AppColors.success : AppColors.warning,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScrolaPrimaryButton(
            label: granted ? 'Continue' : 'Open Settings',
            onPressed: granted
                ? _nextStep
                : () => _tracking.requestOverlayPermission(),
          ),
          if (!granted) ...[
            const SizedBox(height: 6),
            ScrolaLinkButton(
              label: 'I\'ve turned it on',
              onPressed: _nextStep,
            ),
          ],
        ],
      ),
    );
  }

  // 09 - Notification Permission
  Widget _buildNotificationPermission() {
    return _stepScaffold(
      centerVertically: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMockNotification(
            '8 reels left today',
            'Plenty of time to finish your session cleanly.',
            'now',
            scale: 1.0,
            opacity: 1.0,
          ),
          const SizedBox(height: 10),
          _buildMockNotification(
            '4 day streak!',
            'You stayed under your limit again.',
            '9:00 pm',
            scale: 0.97,
            opacity: 0.85,
          ),
          const SizedBox(height: 10),
          _buildMockNotification(
            'Focus session done',
            'Nice work. Brainy is proud of you.',
            'Mon',
            scale: 0.94,
            opacity: 0.70,
          ),
          const SizedBox(height: 32),
          Text('Know before\nyou hit the limit', style: AppTypography.title(size: 28)),
          const SizedBox(height: 10),
          Text(
            'Gentle alerts at 80% and 100% of your daily goal, plus streak nudges. Customise any time.',
            style: AppTypography.body(),
          ),
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScrolaPrimaryButton(
            label: 'Allow notifications',
            onPressed: () async {
              if (_submitting) return;
              _submitting = true;
              try {
                await _tracking.requestNotificationPermission();
                if (mounted) _nextStep();
              } finally {
                if (mounted) _submitting = false;
              }
            },
          ),
          const SizedBox(height: 6),
          ScrolaLinkButton(label: 'Maybe later', onPressed: _nextStep),
        ],
      ),
    );
  }

  // 10 - Setup Complete
  Widget _buildSetupComplete() {
    final accessOk = _tracking.isAccessibilityGranted;
    final overlayOk = _tracking.isOverlayGranted;
    final allReady = accessOk && overlayOk;

    return _stepScaffold(
      centerVertically: true,
      body: Column(
        children: [
          Container(
            width: 204,
            height: 204,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (allReady ? AppColors.success : AppColors.primaryAccent)
                      .withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: BrainyMascot(
                mood: allReady ? BrainyMood.celebrating : BrainyMood.happy,
                size: 164,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            allReady ? 'Permissions ready' : 'Setup complete',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 30),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 310),
            child: Text(
              allReady
                  ? 'Scrola stays paused until you switch it on from the Home dashboard.'
                  : 'You can turn on any skipped Android permissions later from Settings.',
              style: AppTypography.body(),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ScrolaCard(
            child: Column(
              children: [
                _buildCheckRow(
                  accessOk
                      ? Icons.check_circle_rounded
                      : Icons.pause_circle_outline_rounded,
                  accessOk ? AppColors.success : AppColors.warning,
                  accessOk
                      ? 'Reel detection ready'
                      : 'Reel detection permission pending',
                ),
                const SizedBox(height: 12),
                _buildCheckRow(
                  overlayOk
                      ? Icons.check_circle_rounded
                      : Icons.layers_outlined,
                  overlayOk ? AppColors.success : AppColors.warning,
                  overlayOk
                      ? 'Top notch mascot ready'
                      : 'Floating mascot permission pending',
                ),
                const SizedBox(height: 12),
                _buildCheckRow(
                  Icons.power_settings_new_rounded,
                  AppColors.primaryAccent,
                  'Starts only when you turn Scrola ON',
                ),
              ],
            ),
          ),
        ],
      ),
      footer: ScrolaPrimaryButton(label: 'Choose my goal', onPressed: _nextStep),
    );
  }

  // 11 - Goal Selection
  Widget _buildGoalSelection() {
    final goals = [
      (
        title: 'Cut down slowly',
        sub: 'Lower my limit a little each week',
        icon: Icons.trending_down_rounded,
      ),
      (
        title: 'Stay under a daily limit',
        sub: 'Keep reels within a set number',
        icon: Icons.speed_rounded,
      ),
      (
        title: 'Stop mindless scrolling',
        sub: 'Break the habit with blocks and focus',
        icon: Icons.shield_outlined,
      ),
      (
        title: 'Just track for now',
        sub: 'See my numbers, no pressure',
        icon: Icons.bar_chart_rounded,
      ),
    ];

    return _stepScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepHeaderWithBrainy(
            title: 'What\'s your\ngoal?',
            subtitle: 'Pick one. Brainy will plan around it.',
            mood: BrainyMood.happy,
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < goals.length; i++) ...[
            Builder(builder: (context) {
              final g = goals[i];
              final selected = _selectedGoal == g.title;
              return ScrolaSelectableCard(
                isSelected: selected,
                onTap: () {
                  HapticService.subtle();
                  setState(() => _selectedGoal = g.title);
                },
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: (selected
                                ? AppColors.primaryAccent
                                : Colors.white)
                            .withValues(alpha: selected ? 0.18 : 0.06),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        g.icon,
                        size: 20,
                        color: selected
                            ? AppColors.primaryAccent
                            : AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.title,
                            style: AppTypography.subheading().copyWith(
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            g.sub,
                            style: AppTypography.caption(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (i < goals.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          // Daily Reel Limit Stepper
          ScrolaCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily reel limit', style: AppTypography.subheading()),
                      Text(
                        'Shared across selected apps',
                        style: AppTypography.caption(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStepperBtn(Icons.remove_rounded, () {
                  if (_dailyLimit > 5) {
                    HapticService.subtle();
                    setState(() => _dailyLimit -= 5);
                  }
                }),
                SizedBox(
                  width: 50,
                  child: Text(
                    '$_dailyLimit',
                    textAlign: TextAlign.center,
                    style: AppTypography.title(size: 22),
                  ),
                ),
                _buildStepperBtn(Icons.add_rounded, () {
                  if (_dailyLimit < 200) {
                    HapticService.subtle();
                    setState(() => _dailyLimit += 5);
                  }
                }),
              ],
            ),
          ),
        ],
      ),
      footer: ScrolaPrimaryButton(
        label: 'Finish setup',
        useMediumHaptic: true,
        onPressed: () async {
          if (_submitting) return;
          _submitting = true;
          try {
            await _tracking.completeOnboarding(
              goal: _selectedGoal,
              dailyLimit: _dailyLimit,
              platforms: _selectedPlatforms.toList(),
              preserveExistingSettings: widget.isReplay,
            );
            await HapticService.celebratory();
            if (!mounted) return;
            if (widget.isReplay) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainShell()),
                (_) => false,
              );
            }
          } finally {
            if (mounted) _submitting = false;
          }
        },
      ),
    );
  }

  Widget _buildStepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.elevatedSurface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.primaryText, size: 18),
      ),
    );
  }

  Widget _buildCheckRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: AppTypography.body(color: AppColors.primaryText)),
        ),
      ],
    );
  }

  Widget _buildNumberStep(int stepNum, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primaryAccent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNum',
              style: AppTypography.caption(
                color: AppColors.textOnAccent,
                weight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body(color: AppColors.primaryText),
          ),
        ),
      ],
    );
  }

  Widget _buildMockNotification(
    String title,
    String body,
    String time, {
    double scale = 1.0,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: ScrolaCard(
          padding: const EdgeInsets.all(14),
          radius: 20,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: BrainyMascot(
                    mood: BrainyMood.happy,
                    size: 24,
                    animate: false,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.subheading().copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(time, style: AppTypography.caption()),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillPointerLabel extends StatelessWidget {
  final String label;
  final Color color;
  final CrossAxisAlignment align;

  const _PillPointerLabel({
    required this.label,
    required this.color,
    this.align = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          width: 1.5,
          height: 14,
          color: color.withValues(alpha: 0.55),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption(color: color).copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

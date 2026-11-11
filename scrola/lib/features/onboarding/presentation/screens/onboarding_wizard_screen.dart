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
  const OnboardingWizardScreen({super.key});

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> with WidgetsBindingObserver {
  final TrackingService _tracking = TrackingService();
  int _step = 0; // 0 to 8 (maps to screens 03..11)
  int _howItWorksSlide = 0; // 0..2 inside screen 03

  // Screen 04 state
  final Set<String> _selectedPlatforms = {'instagram', 'youtube'};

  // Screen 11 state
  String _selectedGoal = 'Stay under a daily limit';
  int _dailyLimit = 40;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tracking.checkPermissions();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _nextStep() {
    HapticService.light();
    if (_step < 8) {
      setState(() => _step++);
      if (_step == 7) {
        // Screen 10 Tracking Setup Complete celebratory pulse!
        HapticService.celebratory();
      }
    }
  }

  void _prevStep() {
    HapticService.subtle();
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
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
    );
  }

  Widget _buildTopProgress() {
    final totalBars = 9;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prevStep,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceSolid,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.primaryText,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 6,
                color: AppColors.surfaceSolid,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_step + 1) / totalBars,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          if (_step == 0)
            GestureDetector(
              onTap: () {
                HapticService.subtle();
                setState(() => _step = 1);
              },
              child: Text(
                'Skip',
                style: AppTypography.body(color: AppColors.secondaryText, weight: FontWeight.w600, size: 14),
              ),
            )
          else
            Text(
              '${_step + 1} / $totalBars',
              style: AppTypography.caption(color: AppColors.secondaryText, weight: FontWeight.w600),
            ),
        ],
      ),
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
        title: 'See every reel,\nlive',
        desc: 'A floating counter shows what you\'ve watched and what\'s left, right over your apps.',
        mood: BrainyMood.happy,
      ),
      (
        title: 'Stay within\nyour daily limit',
        desc: 'Get gentle nudges as you approach your limit, then let Scrola block the feed.',
        mood: BrainyMood.focused,
      ),
      (
        title: 'Grow Brainy as\nyou scroll less',
        desc: 'Keep daily streaks, earn XP, and evolve Brainy through 5 distinct forms.',
        mood: BrainyMood.celebrating,
      ),
    ];

    final current = slides[_howItWorksSlide];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '${_howItWorksSlide + 1} / 3',
              style: AppTypography.label(color: AppColors.accentHighlight),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Notch Pill Preview Widget
                Container(
                  width: 240,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAccent.withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '24 reels',
                        style: AppTypography.body(color: AppColors.primaryText, weight: FontWeight.w700, size: 13),
                      ),
                      const BrainyMascot(mood: BrainyMood.happy, size: 28, animate: false),
                      Text(
                        '16 left',
                        style: AppTypography.body(color: AppColors.primaryAccent, weight: FontWeight.w700, size: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                BrainyMascot(mood: current.mood, size: 160),
              ],
            ),
          ),
          Text(
            current.title,
            style: AppTypography.title(size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            current.desc,
            style: AppTypography.body(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 28),
          ScrolaPrimaryButton(
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
        ],
      ),
    );
  }

  // 04 - Platform Selection
  Widget _buildPlatformSelection() {
    final platforms = [
      (id: 'instagram', name: 'Instagram Reels', platform: SocialPlatform.instagram),
      (id: 'youtube', name: 'YouTube Shorts', platform: SocialPlatform.youtube),
      (id: 'facebook', name: 'Facebook Reels', platform: SocialPlatform.facebook),
      (id: 'snapchat', name: 'Snapchat Spotlight', platform: SocialPlatform.snapchat),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where do you\nscroll most?', style: AppTypography.title(size: 30)),
          const SizedBox(height: 8),
          Text('Pick the apps to track. You can change this later.', style: AppTypography.body()),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: platforms.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = platforms[index];
                final isSelected = _selectedPlatforms.contains(item.id);
                return ScrolaSelectableCard(
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected && _selectedPlatforms.length > 1) {
                        _selectedPlatforms.remove(item.id);
                      } else {
                        _selectedPlatforms.add(item.id);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      PlatformIcon(platform: item.platform, size: 42),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTypography.subheading()),
                          Text('Track reels watched', style: AppTypography.caption(color: AppColors.secondaryText)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Center(
            child: Text(
              '${_selectedPlatforms.length} apps selected',
              style: AppTypography.caption(color: AppColors.accentHighlight, weight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          ScrolaPrimaryButton(label: 'Continue', onPressed: _nextStep),
        ],
      ),
    );
  }

  // 05 - Accessibility Explanation (Sees vs Never Reads)
  Widget _buildAccessibilityExplain() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Let Scrola count\nyour reels', style: AppTypography.title(size: 30)),
          const SizedBox(height: 10),
          Text(
            'Android only lets an app notice swipes in other apps through Accessibility access. Here is exactly what that covers.',
            style: AppTypography.body(),
          ),
          const SizedBox(height: 24),
          ScrolaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scrola sees', style: AppTypography.label(color: AppColors.success)),
                const SizedBox(height: 14),
                _buildCheckRow(Icons.check_circle_rounded, AppColors.success, 'Which app is open'),
                const SizedBox(height: 12),
                _buildCheckRow(Icons.check_circle_rounded, AppColors.success, 'When you swipe to the next reel'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ScrolaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scrola never reads', style: AppTypography.label(color: AppColors.error)),
                const SizedBox(height: 14),
                _buildCheckRow(Icons.cancel_rounded, AppColors.error, 'Messages or comments'),
                const SizedBox(height: 12),
                _buildCheckRow(Icons.cancel_rounded, AppColors.error, 'Passwords or photos'),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Everything is counted on your phone. You can switch access off any time in Android Settings.',
            style: AppTypography.caption(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ScrolaPrimaryButton(label: 'Continue to Settings', onPressed: _nextStep),
          const SizedBox(height: 6),
          ScrolaLinkButton(label: 'Not now', onPressed: () => setState(() => _step = 4)),
        ],
      ),
    );
  }

  // 06 - Accessibility Setup Guide (with live Android Settings bridge & pulsing ring!)
  Widget _buildAccessibilitySetup() {
    final granted = _tracking.isAccessibilityGranted;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Turn on\nAccessibility', style: AppTypography.title(size: 30)),
          const SizedBox(height: 8),
          Text('Do this once in Android Settings. It takes about 10 seconds.', style: AppTypography.body()),
          const SizedBox(height: 20),

          // Android Settings Mockup
          ScrolaCard(
            backgroundColor: AppColors.cardSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Downloaded apps', style: AppTypography.caption(color: AppColors.secondaryText)),
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
                      child: const Center(
                        child: BrainyMascot(mood: BrainyMood.happy, size: 28, animate: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scrola', style: AppTypography.subheading()),
                          Text('Counts reels while you scroll', style: AppTypography.caption(color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    ScrolaToggle(
                      value: granted,
                      showPulseRing: !granted,
                      onChanged: (_) => _tracking.requestAccessibilityPermission(),
                    ),
                  ],
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
          const Spacer(),

          // Status Pill
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: granted ? AppColors.successBackground : AppColors.warningBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    granted ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                    size: 16,
                    color: granted ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    granted ? 'Permission granted!' : 'Waiting for permission',
                    style: AppTypography.caption(
                      color: granted ? AppColors.success : AppColors.warning,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          ScrolaPrimaryButton(
            label: granted ? 'Continue' : 'Open Settings',
            onPressed: granted ? _nextStep : () => _tracking.requestAccessibilityPermission(),
          ),
          const SizedBox(height: 6),
          if (!granted) ScrolaLinkButton(label: 'I\'ve turned it on', onPressed: _nextStep),
        ],
      ),
    );
  }

  // 07 - Overlay Explanation
  Widget _buildOverlayExplain() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Labelled Notch Pill Diagram
                  Container(
                    width: 268,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(color: AppColors.primaryAccent, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAccent.withValues(alpha: 0.25),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('24 watched', style: AppTypography.body(color: Colors.white, weight: FontWeight.w700, size: 13)),
                        const BrainyMascot(mood: BrainyMood.happy, size: 30, animate: false),
                        Text('16 left', style: AppTypography.body(color: AppColors.primaryAccent, weight: FontWeight.w700, size: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('↑ Reels watched', style: AppTypography.caption(color: AppColors.secondaryText)),
                      Text('↑ Tap to open Scrola', style: AppTypography.caption(color: AppColors.accentHighlight)),
                      Text('↑ Reels left', style: AppTypography.caption(color: AppColors.secondaryText)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Text('A live counter at the\ntop of your screen', style: AppTypography.title(size: 28)),
          const SizedBox(height: 12),
          Text(
            'To sit on top of Instagram, YouTube and other apps, Scrola needs Android\'s "display over other apps" permission.',
            style: AppTypography.body(),
          ),
          const SizedBox(height: 8),
          Text(
            'It only ever shows your counts. Hide it any time from Counter settings.',
            style: AppTypography.caption(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 24),
          ScrolaPrimaryButton(label: 'Continue', onPressed: _nextStep),
          const SizedBox(height: 6),
          ScrolaLinkButton(label: 'Skip for now', onPressed: () => setState(() => _step = 6)),
        ],
      ),
    );
  }

  // 08 - Overlay Permission Setup
  Widget _buildOverlaySetup() {
    final granted = _tracking.isOverlayGranted;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Allow display over\nother apps', style: AppTypography.title(size: 30)),
          const SizedBox(height: 8),
          Text('Open Scrola\'s page and switch the permission on.', style: AppTypography.body()),
          const SizedBox(height: 20),

          ScrolaCard(
            backgroundColor: AppColors.cardSurface,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Allow display over other apps', style: AppTypography.subheading()),
                      const SizedBox(height: 4),
                      Text('Lets the counter appear on top of other apps.', style: AppTypography.caption(color: AppColors.secondaryText)),
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
          const Spacer(),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: granted ? AppColors.successBackground : AppColors.warningBackground,
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

          const SizedBox(height: 16),
          ScrolaPrimaryButton(
            label: granted ? 'Continue' : 'Open Settings',
            onPressed: granted
                ? () {
                    _tracking.toggleOverlay(true);
                    _nextStep();
                  }
                : () => _tracking.requestOverlayPermission(),
          ),
          const SizedBox(height: 6),
          if (!granted) ScrolaLinkButton(label: 'I\'ve turned it on', onPressed: _nextStep),
        ],
      ),
    );
  }

  // 09 - Notification Permission
  Widget _buildNotificationPermission() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildMockNotification('8 reels left today', 'Plenty of time to finish that show.', 'now'),
          const SizedBox(height: 10),
          _buildMockNotification('4 day streak!', 'You stayed under your limit again.', '9:00 pm'),
          const SizedBox(height: 10),
          _buildMockNotification('Focus session done', 'Nice work. Brainy is proud of you.', 'Mon'),
          const Spacer(),
          Text('Know before\nyou hit the limit', style: AppTypography.title(size: 30)),
          const SizedBox(height: 10),
          Text(
            'Alerts at 80% and 100% of your limit, plus streak reminders. Change them any time.',
            style: AppTypography.body(),
          ),
          const SizedBox(height: 24),
          ScrolaPrimaryButton(label: 'Allow notifications', onPressed: _nextStep),
          const SizedBox(height: 6),
          ScrolaLinkButton(label: 'Maybe later', onPressed: _nextStep),
        ],
      ),
    );
  }

  // 10 - Setup Complete
  Widget _buildSetupComplete() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          const BrainyMascot(mood: BrainyMood.celebrating, size: 170),
          const SizedBox(height: 24),
          Text('Tracking is live', style: AppTypography.title(size: 32)),
          const SizedBox(height: 8),
          Text(
            'Open Instagram or YouTube and the counter appears at the top.',
            style: AppTypography.body(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ScrolaCard(
            child: Column(
              children: [
                _buildCheckRow(Icons.check_circle_rounded, AppColors.success, 'Reel tracking is on'),
                const SizedBox(height: 12),
                _buildCheckRow(Icons.check_circle_rounded, AppColors.success, 'Floating counter is ready'),
                const SizedBox(height: 12),
                _buildCheckRow(Icons.check_circle_rounded, AppColors.success, 'Nudges are on'),
              ],
            ),
          ),
          const Spacer(),
          ScrolaPrimaryButton(label: 'Choose my goal', onPressed: _nextStep),
        ],
      ),
    );
  }

  // 11 - Goal Selection
  Widget _buildGoalSelection() {
    final goals = [
      (title: 'Cut down slowly', sub: 'Lower my limit a little each week'),
      (title: 'Stay under a daily limit', sub: 'Keep reels within a set number'),
      (title: 'Stop mindless scrolling', sub: 'Break the habit with blocks and focus'),
      (title: 'Just track for now', sub: 'See my numbers, no pressure'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What\'s your\ngoal?', style: AppTypography.title(size: 30)),
          const SizedBox(height: 6),
          Text('Pick one. Brainy will plan around it.', style: AppTypography.body()),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: goals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final g = goals[index];
                return ScrolaSelectableCard(
                  isSelected: _selectedGoal == g.title,
                  onTap: () => setState(() => _selectedGoal = g.title),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.title, style: AppTypography.subheading()),
                      Text(g.sub, style: AppTypography.caption(color: AppColors.secondaryText)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
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
                      Text('Change it any time', style: AppTypography.caption(color: AppColors.secondaryText)),
                    ],
                  ),
                ),
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
          const SizedBox(height: 18),
          ScrolaPrimaryButton(
            label: 'Start tracking',
            useMediumHaptic: true,
            onPressed: () async {
              await _tracking.completeOnboarding(
                goal: _selectedGoal,
                dailyLimit: _dailyLimit,
                platforms: _selectedPlatforms.toList(),
              );
              await HapticService.celebratory();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainShell()),
                (_) => false,
              );
            },
          ),
        ],
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
            color: AppColors.elevatedSurface,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNum',
              style: AppTypography.caption(color: AppColors.primaryAccent, weight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: AppTypography.body(color: AppColors.primaryText)),
        ),
      ],
    );
  }

  Widget _buildMockNotification(String title, String body, String time) {
    return ScrolaCard(
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
            child: const Center(child: BrainyMascot(mood: BrainyMood.happy, size: 24, animate: false)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTypography.subheading().copyWith(fontSize: 14)),
                    Text(time, style: AppTypography.caption()),
                  ],
                ),
                const SizedBox(height: 2),
                Text(body, style: AppTypography.caption(color: AppColors.secondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/services/focus_mode_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_toggle.dart';
import 'active_focus_session_screen.dart';

class FocusSessionSetupScreen extends StatefulWidget {
  const FocusSessionSetupScreen({super.key});

  @override
  State<FocusSessionSetupScreen> createState() =>
      _FocusSessionSetupScreenState();
}

class _FocusSessionSetupScreenState extends State<FocusSessionSetupScreen> {
  final FocusModeService _focus = FocusModeService();
  int _minutes = 25;
  bool _strictMode = false;
  final Map<SocialPlatform, bool> _blockedApps = {
    SocialPlatform.instagram: true,
    SocialPlatform.youtube: true,
    SocialPlatform.facebook: false,
    SocialPlatform.snapchat: false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: 'New session'),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScrolaCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'DURATION',
                              style: AppTypography.label(
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StepCircle(
                                  icon: Icons.remove_rounded,
                                  onTap: () {
                                    HapticService.subtle();
                                    setState(() => _minutes =
                                        (_minutes - 5).clamp(5, 120));
                                  },
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '$_minutes',
                                        style: AppTypography.display(),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'min',
                                        style: AppTypography.subheading(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _StepCircle(
                                  icon: Icons.add_rounded,
                                  onTap: () {
                                    HapticService.subtle();
                                    setState(() => _minutes =
                                        (_minutes + 5).clamp(5, 120));
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [15, 25, 45, 60].map((m) {
                                final selected = _minutes == m;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: GestureDetector(
                                      onTap: () {
                                        HapticService.subtle();
                                        setState(() => _minutes = m);
                                      },
                                      child: Container(
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppColors.primaryAccent
                                              : AppColors.elevatedSurface,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$m min',
                                            style: AppTypography.caption(
                                              color: selected
                                                  ? AppColors.textOnAccent
                                                  : AppColors.primaryText,
                                            ).copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'BLOCK WHILE FOCUSING',
                        style: AppTypography.label(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ScrolaCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            _AppRow(
                              platform: SocialPlatform.instagram,
                              name: 'Instagram Reels',
                              value: _blockedApps[SocialPlatform.instagram]!,
                              onChanged: (v) => setState(() =>
                                  _blockedApps[SocialPlatform.instagram] = v),
                            ),
                            const Divider(
                                color: AppColors.borderSubtle, height: 1),
                            _AppRow(
                              platform: SocialPlatform.youtube,
                              name: 'YouTube Shorts',
                              value: _blockedApps[SocialPlatform.youtube]!,
                              onChanged: (v) => setState(() =>
                                  _blockedApps[SocialPlatform.youtube] = v),
                            ),
                            const Divider(
                                color: AppColors.borderSubtle, height: 1),
                            _AppRow(
                              platform: SocialPlatform.facebook,
                              name: 'Facebook Reels',
                              value: _blockedApps[SocialPlatform.facebook]!,
                              onChanged: (v) => setState(() =>
                                  _blockedApps[SocialPlatform.facebook] = v),
                            ),
                            const Divider(
                                color: AppColors.borderSubtle, height: 1),
                            _AppRow(
                              platform: SocialPlatform.snapchat,
                              name: 'Snapchat Spotlight',
                              value: _blockedApps[SocialPlatform.snapchat]!,
                              onChanged: (v) => setState(() =>
                                  _blockedApps[SocialPlatform.snapchat] = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ScrolaCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Strict mode',
                                    style: AppTypography.subheading()
                                        .copyWith(fontSize: 15),
                                  ),
                                  Text(
                                    'No early exit once started',
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ScrolaToggle(
                              value: _strictMode,
                              onChanged: (v) =>
                                  setState(() => _strictMode = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ScrolaPrimaryButton(
                label: 'Start $_minutes min session',
                useMediumHaptic: true,
                onPressed: () {
                  _focus.startSession(minutes: _minutes);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const ActiveFocusSessionScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.elevatedSurface,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.primaryText),
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  final SocialPlatform platform;
  final String name;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AppRow({
    required this.platform,
    required this.name,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          PlatformIcon(platform: platform, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: AppTypography.subheading().copyWith(fontSize: 15)),
          ),
          ScrolaToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

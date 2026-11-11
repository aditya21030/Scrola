import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_toggle.dart';

class BlockingSettingsScreen extends StatefulWidget {
  const BlockingSettingsScreen({super.key});

  @override
  State<BlockingSettingsScreen> createState() => _BlockingSettingsScreenState();
}

class _BlockingSettingsScreenState extends State<BlockingSettingsScreen> {
  final TrackingService _tracking = TrackingService();
  bool _waitBeforeUnlock = true;
  bool _showBrainy = true;
  final Map<SocialPlatform, bool> _apps = {
    SocialPlatform.instagram: true,
    SocialPlatform.youtube: true,
    SocialPlatform.facebook: false,
    SocialPlatform.snapchat: false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final strict = _tracking.strictBlocking;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScrolaAppBar(title: 'Blocking settings'),
                  const SizedBox(height: 18),
                  Text(
                    'WHEN BLOCKED',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ScrolaSelectableCard(
                          isSelected: !strict,
                          onTap: () {
                            HapticService.subtle();
                            _tracking.updateBlockingConfig(strict: false);
                          },
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.spa_outlined,
                                color: AppColors.primaryAccent,
                              ),
                              const SizedBox(height: 12),
                              Text('Gentle',
                                  style: AppTypography.subheading()
                                      .copyWith(fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(
                                'Reminder first · Take a breath',
                                style: AppTypography.caption(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ScrolaSelectableCard(
                          isSelected: strict,
                          onTap: () {
                            HapticService.subtle();
                            _tracking.updateBlockingConfig(strict: true);
                          },
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.primaryAccent,
                              ),
                              const SizedBox(height: 12),
                              Text('Strict',
                                  style: AppTypography.subheading()
                                      .copyWith(fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(
                                'Blocked · No way in',
                                style: AppTypography.caption(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ScrolaCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Emergency unlock',
                              style: AppTypography.subheading()
                                  .copyWith(fontSize: 15),
                            ),
                            Text(
                              '5 minutes, 3 per day',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wait before unlocking',
                                    style: AppTypography.subheading()
                                        .copyWith(fontSize: 15),
                                  ),
                                  Text(
                                    'Pause for 30 seconds first',
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ScrolaToggle(
                              value: _waitBeforeUnlock,
                              onChanged: (v) =>
                                  setState(() => _waitBeforeUnlock = v),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Show Brainy',
                                    style: AppTypography.subheading()
                                        .copyWith(fontSize: 15),
                                  ),
                                  Text(
                                    'On the block screen',
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ScrolaToggle(
                              value: _showBrainy,
                              onChanged: (v) =>
                                  setState(() => _showBrainy = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'APPS TO BLOCK',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  ScrolaCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        _BlockAppToggle(
                          platform: SocialPlatform.instagram,
                          name: 'Instagram',
                          value: _apps[SocialPlatform.instagram]!,
                          onChanged: (v) => setState(
                              () => _apps[SocialPlatform.instagram] = v),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _BlockAppToggle(
                          platform: SocialPlatform.youtube,
                          name: 'YouTube',
                          value: _apps[SocialPlatform.youtube]!,
                          onChanged: (v) =>
                              setState(() => _apps[SocialPlatform.youtube] = v),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _BlockAppToggle(
                          platform: SocialPlatform.facebook,
                          name: 'Facebook',
                          value: _apps[SocialPlatform.facebook]!,
                          onChanged: (v) => setState(
                              () => _apps[SocialPlatform.facebook] = v),
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _BlockAppToggle(
                          platform: SocialPlatform.snapchat,
                          name: 'Snapchat',
                          value: _apps[SocialPlatform.snapchat]!,
                          onChanged: (v) => setState(
                              () => _apps[SocialPlatform.snapchat] = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Blocking covers the reels sections of the apps you choose, not the whole app. It uses the same Accessibility permission as tracking.',
                    style: AppTypography.caption(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlockAppToggle extends StatelessWidget {
  final SocialPlatform platform;
  final String name;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BlockAppToggle({
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

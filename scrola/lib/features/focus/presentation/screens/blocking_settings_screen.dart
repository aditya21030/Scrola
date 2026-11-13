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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final strict = _tracking.strictBlocking;

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: ScrolaAppBar(title: 'Blocking settings'),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'WHEN BLOCKED',
                          style: AppTypography.label(
                              color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 10),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ScrolaSelectableCard(
                                  isSelected: !strict,
                                  checkPosition: ScrolaCheckPosition.topRight,
                                  onTap: () {
                                    HapticService.subtle();
                                    _tracking.updateBlockingConfig(
                                        strict: false);
                                  },
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  checkPosition: ScrolaCheckPosition.topRight,
                                  onTap: () {
                                    HapticService.subtle();
                                    _tracking.updateBlockingConfig(
                                        strict: true);
                                  },
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                        ),
                        const SizedBox(height: 16),
                        ScrolaCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Emergency unlock',
                                          style: AppTypography.subheading()
                                              .copyWith(fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '5 min pass · ${_tracking.emergencyUnlocksLeft} left today',
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                  color: AppColors.borderSubtle, height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Wait before unlocking',
                                          style: AppTypography.subheading()
                                              .copyWith(fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Pause for 30 seconds first',
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ScrolaToggle(
                                    value: _tracking.waitBeforeUnlock,
                                    onChanged: (v) =>
                                        _tracking.updateBlockingConfig(
                                            waitBeforeUnlock: v),
                                  ),
                                ],
                              ),
                              const Divider(
                                  color: AppColors.borderSubtle, height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Show Brainy',
                                          style: AppTypography.subheading()
                                              .copyWith(fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'On the block screen',
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ScrolaToggle(
                                    value: _tracking.showBrainyOnBlock,
                                    onChanged: (v) =>
                                        _tracking.updateBlockingConfig(
                                            showBrainyOnBlock: v),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'APPS TO BLOCK',
                          style: AppTypography.label(
                              color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 10),
                        ScrolaCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < SocialPlatform.values.length;
                                  i++) ...[
                                if (i > 0)
                                  const Divider(
                                    color: AppColors.borderSubtle,
                                    height: 1,
                                  ),
                                _BlockAppToggle(
                                  platform: SocialPlatform.values[i],
                                  name: SocialPlatform.values[i].shortName,
                                  value: _tracking.selectedPlatforms
                                      .contains(SocialPlatform.values[i].id),
                                  onChanged: (v) {
                                    final next = Set<String>.from(
                                        _tracking.selectedPlatforms);
                                    final id = SocialPlatform.values[i].id;
                                    if (v) {
                                      next.add(id);
                                    } else if (next.length > 1) {
                                      next.remove(id);
                                    }
                                    _tracking.updateSelectedPlatforms(
                                        next.toList());
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Blocking covers the reels sections of the apps you choose, not the whole app. It uses the same Accessibility permission as tracking.',
                          style: AppTypography.caption(
                              color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

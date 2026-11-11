import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/platform_icon.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class PlatformLimitsScreen extends StatefulWidget {
  const PlatformLimitsScreen({super.key});

  @override
  State<PlatformLimitsScreen> createState() => _PlatformLimitsScreenState();
}

class _PlatformLimitsScreenState extends State<PlatformLimitsScreen> {
  final TrackingService _tracking = TrackingService();
  late final Map<SocialPlatform, int> _limits;
  late bool _enforcePerApp;

  @override
  void initState() {
    super.initState();
    _limits = {
      for (final platform in _tracking.activePlatforms)
        platform: _tracking.limitForId(platform.id),
    };
    _enforcePerApp = _tracking.platformLimitsEnabled;
  }

  int get _sum => _limits.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final total = _tracking.totalLimit;
    final matchesTotal = _sum == total;
    final diff = _sum - total;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: 'Platform limits'),
              const SizedBox(height: 16),
              ScrolaCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'ALLOCATED',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_sum / $total reels',
                          style: AppTypography.numeric(
                            color: matchesTotal
                                ? AppColors.success
                                : AppColors.primaryAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : (_sum / total).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          diff > 0 ? AppColors.warning : AppColors.primaryAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      matchesTotal
                          ? 'All of your daily limit is assigned.'
                          : diff > 0
                              ? '$diff reels above your daily limit.'
                              : '${-diff} reels left unassigned.',
                      style: AppTypography.caption(
                        color: matchesTotal
                            ? AppColors.success
                            : AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ScrolaCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enforce per-app limits',
                            style: AppTypography.subheading().copyWith(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _enforcePerApp
                                ? 'Each app stops at its individual cap.'
                                : 'Off — all apps share your $total-reel daily goal.',
                            style: AppTypography.caption(),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _enforcePerApp,
                      activeThumbColor: AppColors.primaryAccent,
                      activeTrackColor:
                          AppColors.primaryAccent.withValues(alpha: 0.4),
                      onChanged: (val) {
                        HapticService.light();
                        setState(() => _enforcePerApp = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _enforcePerApp ? 1.0 : 0.55,
                  child: ListView(
                    children: () {
                      final activePlatforms = _tracking.activePlatforms;
                      return [
                        for (int i = 0; i < activePlatforms.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          Builder(builder: (_) {
                            final platform = activePlatforms[i];
                            return _PlatformLimitTile(
                              platform: platform,
                              name: platform.reelsName,
                              value: _limits[platform]!,
                              onDelta: (d) => setState(() {
                                _enforcePerApp = true;
                                _limits[platform] =
                                    (_limits[platform]! + d).clamp(0, 150);
                              }),
                            );
                          }),
                        ],
                      ];
                    }(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ScrolaPrimaryButton(
                label: 'Save limits',
                useMediumHaptic: true,
                onPressed: () {
                  _tracking.updateLimits(
                    instagram: _limits[SocialPlatform.instagram],
                    youtube: _limits[SocialPlatform.youtube],
                    facebook: _limits[SocialPlatform.facebook],
                    snapchat: _limits[SocialPlatform.snapchat],
                    platformLimits: {
                      for (final entry in _limits.entries)
                        entry.key.id: entry.value,
                    },
                    platformLimitsEnabled: _enforcePerApp,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformLimitTile extends StatelessWidget {
  final SocialPlatform platform;
  final String name;
  final int value;
  final ValueChanged<int> onDelta;

  const _PlatformLimitTile({
    required this.platform,
    required this.name,
    required this.value,
    required this.onDelta,
  });

  @override
  Widget build(BuildContext context) {
    return ScrolaCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          PlatformIcon(platform: platform, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.subheading().copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  '$value reels',
                  style: AppTypography.numeric(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _MiniStepBtn(
            icon: Icons.remove_rounded,
            onTap: () {
              HapticService.subtle();
              onDelta(-1);
            },
          ),
          const SizedBox(width: 8),
          _MiniStepBtn(
            icon: Icons.add_rounded,
            onTap: () {
              HapticService.subtle();
              onDelta(1);
            },
          ),
        ],
      ),
    );
  }
}

class _MiniStepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniStepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.elevatedSurface,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.primaryText, size: 18),
      ),
    );
  }
}

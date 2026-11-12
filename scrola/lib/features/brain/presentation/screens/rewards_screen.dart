import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final TrackingService _tracking = TrackingService();

  static const String _chestRewardId = 'streak_chest_7d';
  static const String _boostRewardId = 'xp_boost_streak';
  static const String _emberRewardId = 'skin_ember';

  @override
  Widget build(BuildContext context) {
    final emberLevel = GamificationEngine.unlockLevelForSkin(BrainySkin.ember);
    final goldenLevel = GamificationEngine.unlockLevelForSkin(BrainySkin.golden);
    final frostLevel = GamificationEngine.unlockLevelForSkin(BrainySkin.frost);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final chestClaimed = _tracking.isRewardClaimed(_chestRewardId);
          final boostClaimed = _tracking.isRewardClaimed(_boostRewardId);
          final emberClaimed = _tracking.isRewardClaimed(_emberRewardId);

          final chestUnlocked = _tracking.streakDays >= 7;
          final boostUnlocked = _tracking.streakDays >= 7;
          final emberUnlocked = _tracking.currentLevel >= emberLevel;

          final readyCount = (!chestClaimed && chestUnlocked ? 1 : 0) +
              (!boostClaimed && boostUnlocked ? 1 : 0) +
              (!emberClaimed && emberUnlocked ? 1 : 0);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Rewards',
                    trailing: Text(
                      '$readyCount ready',
                      style: AppTypography.caption(color: AppColors.primaryAccent)
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ScrolaCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: chestClaimed || !chestUnlocked
                        ? AppColors.borderSubtle
                        : AppColors.primaryAccent.withValues(alpha: 0.5),
                    gradient: chestClaimed || !chestUnlocked
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryAccent.withValues(alpha: 0.22),
                              AppColors.surfaceSolid,
                            ],
                          ),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (chestClaimed
                                    ? AppColors.success
                                    : AppColors.primaryAccent)
                                .withValues(alpha: 0.16),
                          ),
                          child: Icon(
                            chestClaimed
                                ? Icons.check_circle_rounded
                                : Icons.card_giftcard_rounded,
                            color: chestClaimed
                                ? AppColors.success
                                : AppColors.primaryAccent,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Streak chest',
                          style: AppTypography.title().copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chestClaimed
                              ? 'Claimed +100 XP!'
                              : chestUnlocked
                                  ? '${_tracking.streakDays} days earned · Contains +100 XP.'
                                  : 'Reach a 7 day streak to unlock (+100 XP).',
                          style: AppTypography.caption(
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ScrolaPrimaryButton(
                          label: chestClaimed
                              ? 'Opened'
                              : chestUnlocked
                                  ? 'Open chest'
                                  : 'Locked',
                          onPressed: chestClaimed || !chestUnlocked
                              ? null
                              : () async {
                                  final ok = await _tracking.claimReward(
                                    _chestRewardId,
                                    xp: 100,
                                  );
                                  if (ok) {
                                    await HapticService.celebratory();
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'READY TO CLAIM',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  _RewardRow(
                    title: '+100 XP boost',
                    subtitle: 'From your ${_tracking.streakDays} day streak',
                    claimed: boostClaimed,
                    locked: !boostUnlocked,
                    lockLabel: '7d streak',
                    onClaim: () async {
                      final ok = await _tracking.claimReward(
                        _boostRewardId,
                        xp: 100,
                      );
                      if (ok) {
                        await HapticService.celebratory();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _RewardRow(
                    title: 'Ember Brainy skin',
                    subtitle: 'Level $emberLevel reward',
                    claimed: emberClaimed,
                    locked: !emberUnlocked,
                    lockLabel: 'Lv $emberLevel',
                    onClaim: () async {
                      final ok = await _tracking.claimReward(
                        _emberRewardId,
                        equipSkinOnClaim: BrainySkin.ember,
                      );
                      if (ok) {
                        await HapticService.celebratory();
                      }
                    },
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'COMING UP',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 10),
                  _UpcomingRow(
                    title: 'Golden skin',
                    subtitle: 'Collection',
                    level: 'Level $goldenLevel',
                  ),
                  const SizedBox(height: 10),
                  const _UpcomingRow(
                    title: 'Bright Mind form',
                    subtitle: 'Brain evolution',
                    level: 'Level 6',
                  ),
                  const SizedBox(height: 10),
                  _UpcomingRow(
                    title: 'Frost skin',
                    subtitle: 'Collection',
                    level: 'Level $frostLevel',
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

class _RewardRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool claimed;
  final bool locked;
  final String? lockLabel;
  final VoidCallback onClaim;

  const _RewardRow({
    required this.title,
    required this.subtitle,
    required this.claimed,
    this.locked = false,
    this.lockLabel,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = claimed || locked;
    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (claimed
                      ? AppColors.success
                      : locked
                          ? AppColors.elevatedSurface
                          : AppColors.primaryAccent)
                  .withValues(alpha: locked ? 1.0 : 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              claimed
                  ? Icons.check_rounded
                  : locked
                      ? Icons.lock_outline_rounded
                      : Icons.stars_rounded,
              color: claimed
                  ? AppColors.success
                  : locked
                      ? AppColors.secondaryText
                      : AppColors.primaryAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.subheading().copyWith(fontSize: 15)),
                Text(
                  subtitle,
                  style: AppTypography.caption(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: disabled ? null : onClaim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: claimed
                    ? AppColors.successBackground
                    : locked
                        ? AppColors.elevatedSurface
                        : AppColors.primaryAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                claimed
                    ? 'Claimed'
                    : locked
                        ? (lockLabel ?? 'Locked')
                        : 'Claim',
                style: AppTypography.caption(
                  color: claimed
                      ? AppColors.success
                      : locked
                          ? AppColors.secondaryText
                          : AppColors.textOnAccent,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String level;

  const _UpcomingRow({
    required this.title,
    required this.subtitle,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.secondaryText,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.subheading().copyWith(fontSize: 15)),
                Text(
                  subtitle,
                  style: AppTypography.caption(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          Text(
            level,
            style: AppTypography.caption(color: AppColors.secondaryText)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

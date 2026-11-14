import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import 'achievements_screen.dart';
import 'brain_collection_screen.dart';
import 'brain_details_screen.dart';
import 'brain_evolution_screen.dart';
import 'rewards_screen.dart';
import 'streak_calendar_screen.dart';
import 'level_rewards_roadmap_screen.dart';
import 'xp_progress_screen.dart';

class BrainOverviewScreen extends StatelessWidget {
  final bool showBack;

  const BrainOverviewScreen({super.key, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: tracking,
        builder: (context, _) {
          final levelInfo = GamificationEngine.getLevelForXP(tracking.xpTotal);
          final stage = GamificationEngine.getStageForLevel(levelInfo.level);
          final stageIdx =
              GamificationEngine.evolutionStages.indexOf(stage) + 1;
          final nextStage =
              stageIdx < GamificationEngine.evolutionStages.length
                  ? GamificationEngine.evolutionStages[stageIdx]
                  : null;
          final levelsToGo = nextStage == null
              ? 0
              : math.max(1, nextStage.minLevel - levelInfo.level);

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                showBack ? 28 : 112,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBack)
                    ScrolaAppBar(
                      title: 'Brain',
                      trailing: _LevelPill(level: levelInfo.level),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Brain', style: AppTypography.title()),
                          _LevelPill(level: levelInfo.level),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryAccent.withValues(alpha: 0.25),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticService.light();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BrainDetailsScreen(
                                initialSkin: tracking.equippedSkin,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Text(
                                'Feeling ${tracking.currentMood.name}',
                                style: AppTypography.caption(
                                  color: AppColors.primaryText,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 8),
                            BrainyMascot(
                              mood: tracking.currentMood,
                              skin: tracking.equippedSkin,
                              size: 168,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      stage.title,
                      style: AppTypography.title().copyWith(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      nextStage == null
                          ? 'Stage 5 of 5 · Max form'
                          : 'Stage $stageIdx of 5 · evolves at Level ${nextStage.minLevel}',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ScrolaCard(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _BrainMetricTap(
                            value: '${tracking.xpTotal}',
                            label: 'XP',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const XpProgressScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 36,
                          child: VerticalDivider(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        Expanded(
                          child: _BrainMetricTap(
                            value: '${tracking.streakDays}',
                            label: 'Day streak',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const StreakCalendarScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 36,
                          child: VerticalDivider(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        Expanded(
                          child: _BrainMetricTap(
                            value: '${tracking.unlockedBadgeCount}',
                            label: 'Badges',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AchievementsScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _BrainNavCard(
                          icon: Icons.auto_awesome_rounded,
                          title: 'Evolution',
                          subtitle: nextStage == null
                              ? 'Max stage reached'
                              : '$levelsToGo levels to go',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BrainEvolutionScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BrainNavCard(
                          icon: Icons.grid_view_rounded,
                          title: 'Collection',
                          subtitle:
                              '${GamificationEngine.unlockedSkinCount(tracking.currentLevel)} of ${BrainySkin.values.length} unlocked',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BrainCollectionScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final readyCount = [
                              !tracking.isDailyXpCollectedToday,
                              tracking.streakDays >= 7 &&
                                  !tracking.isRewardClaimed('streak_7_xp'),
                              tracking.currentLevel >= 2 &&
                                  !tracking.isRewardClaimed('ember_skin'),
                            ].where((e) => e).length;
                            return _BrainNavCard(
                              icon: Icons.card_giftcard_rounded,
                              title: 'Rewards',
                              subtitle: readyCount == 0
                                  ? 'All caught up'
                                  : '$readyCount ready to claim',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RewardsScreen(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BrainNavCard(
                          icon: Icons.mood_rounded,
                          title: 'Moods & Skins',
                          subtitle: '8 interactive states',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BrainDetailsScreen(
                                initialSkin: tracking.equippedSkin,
                                requiredLevel:
                                    GamificationEngine.unlockLevelForSkin(
                                  tracking.equippedSkin,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ScrolaCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    onTap: () {
                      HapticService.light();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LevelRewardsRoadmapScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.timeline_rounded,
                            color: AppColors.primaryAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Level Rewards Roadmap',
                                style: AppTypography.subheading(),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Explore all 30 stages and 40 skins from Lv 1 to 100',
                                style: AppTypography.caption(color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.secondaryText,
                          size: 16,
                        ),
                      ],
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
}

class _LevelPill extends StatelessWidget {
  final int level;
  const _LevelPill({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        'Level $level',
        style: AppTypography.caption(color: AppColors.primaryAccent)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BrainMetricTap extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback onTap;

  const _BrainMetricTap({
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticService.subtle();
        onTap();
      },
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.numeric(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _BrainNavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BrainNavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        HapticService.subtle();
        onTap();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryAccent, size: 20),
          ),
          const SizedBox(height: 14),
          Text(title, style: AppTypography.subheading().copyWith(fontSize: 15)),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

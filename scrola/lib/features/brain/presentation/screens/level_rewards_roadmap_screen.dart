import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';

class LevelRewardsRoadmapScreen extends StatelessWidget {
  const LevelRewardsRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();
    final currentLevel = tracking.currentLevel;
    final currentXP = tracking.xpTotal;
    final xpInCurrentLevel = currentXP % 200;
    final progress = (xpInCurrentLevel / 200).clamp(0.0, 1.0);

    // Build milestone list combining Evolution Stages and Skin unlocks
    final milestones = <_RoadmapMilestone>[];
    final allStages = GamificationEngine.evolutionStages;

    // Add all 30 stages
    for (int i = 1; i <= 30; i++) {
      final stage = allStages.firstWhere(
        (s) => s.stageNumber == i,
        orElse: () => allStages.first,
      );
      milestones.add(_RoadmapMilestone(
        level: stage.minLevel,
        title: '${stage.name} Form',
        subtitle: 'Evolution Stage $i',
        stageNumber: i,
        isStage: true,
      ));
    }

    // Add key skin unlocks
    for (final skin in BrainySkin.values) {
      if (skin == BrainySkin.classic) continue;
      final reqLevel = GamificationEngine.unlockLevelForSkin(skin);
      final label = skin.name[0].toUpperCase() + skin.name.substring(1);
      milestones.add(_RoadmapMilestone(
        level: reqLevel,
        title: '$label Brainy',
        subtitle: 'Custom Color Skin',
        skin: skin,
        isStage: false,
      ));
    }

    milestones.sort((a, b) => a.level.compareTo(b.level));

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: 'Level rewards'),
              const SizedBox(height: 10),

              // Current Level Header Card
              ScrolaCard(
                padding: const EdgeInsets.all(18),
                radius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Level $currentLevel',
                          style: AppTypography.heading(size: 22),
                        ),
                        Text(
                          '${200 - xpInCurrentLevel} XP to Level ${currentLevel + 1}',
                          style: AppTypography.caption(
                            color: AppColors.secondaryText,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.elevatedSurface,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                '30 FORMS · 40 SKINS · UP TO LEVEL 100',
                style: AppTypography.label(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: milestones.length,
                  itemBuilder: (context, index) {
                    final item = milestones[index];
                    final isUnlocked = currentLevel >= item.level;
                    final isCurrent = currentLevel == item.level;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left spine with circular node
                          SizedBox(
                            width: 44,
                            child: Column(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isUnlocked
                                        ? AppColors.primaryAccent
                                        : AppColors.cardSurface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isUnlocked
                                          ? AppColors.primaryAccent
                                          : AppColors.border,
                                      width: isCurrent ? 2 : 1,
                                    ),
                                    boxShadow: isCurrent
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryAccent
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${item.level}',
                                    style: AppTypography.caption(
                                      color: isUnlocked
                                          ? AppColors.primaryBackground
                                          : AppColors.secondaryText,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (index < milestones.length - 1)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: isUnlocked
                                          ? AppColors.primaryAccent
                                              .withValues(alpha: 0.4)
                                          : AppColors.border,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Right Reward Card
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ScrolaCard(
                                padding: const EdgeInsets.all(14),
                                radius: 18,
                                child: Row(
                                  children: [
                                    BrainyMascot(
                                      stageNumber: item.stageNumber,
                                      skin: item.skin ?? BrainySkin.classic,
                                      size: 44,
                                      animate: false,
                                      silhouette: !isUnlocked,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: AppTypography.body(
                                              color: isUnlocked
                                                  ? AppColors.primaryText
                                                  : AppColors.secondaryText,
                                              weight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.subtitle,
                                            style: AppTypography.caption(
                                              color: AppColors.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isUnlocked
                                            ? AppColors.primaryAccent
                                                .withValues(alpha: 0.16)
                                            : AppColors.elevatedSurface,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isUnlocked
                                              ? AppColors.primaryAccent
                                                  .withValues(alpha: 0.4)
                                              : AppColors.border,
                                        ),
                                      ),
                                      child: Text(
                                        isUnlocked ? 'Unlocked' : 'Lv ${item.level}',
                                        style: AppTypography.caption(
                                          color: isUnlocked
                                              ? AppColors.primaryAccent
                                              : AppColors.secondaryText,
                                          weight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadmapMilestone {
  final int level;
  final String title;
  final String subtitle;
  final int? stageNumber;
  final BrainySkin? skin;
  final bool isStage;

  const _RoadmapMilestone({
    required this.level,
    required this.title,
    required this.subtitle,
    this.stageNumber,
    this.skin,
    required this.isStage,
  });
}

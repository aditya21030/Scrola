import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class BrainEvolutionScreen extends StatefulWidget {
  const BrainEvolutionScreen({super.key});

  @override
  State<BrainEvolutionScreen> createState() => _BrainEvolutionScreenState();
}

class _BrainEvolutionScreenState extends State<BrainEvolutionScreen> {
  final TrackingService _tracking = TrackingService();
  bool _previewingNext = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final levelInfo = GamificationEngine.getLevelForXP(_tracking.xpTotal);
          final currentStage =
              GamificationEngine.getStageForLevel(levelInfo.level);
          final stages = GamificationEngine.evolutionStages;
          final currentIdx = stages.indexOf(currentStage);
          final nextStage =
              currentIdx + 1 < stages.length ? stages[currentIdx + 1] : null;
          final stageProgress =
              GamificationEngine.getStageProgress(_tracking.xpTotal);
          final displayedStage =
              (_previewingNext && nextStage != null) ? nextStage : currentStage;

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ScrolaAppBar(title: 'Evolution'),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 210,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (currentIdx > 0)
                                Positioned(
                                  left: 0,
                                  child: Opacity(
                                    opacity: 0.45,
                                    child: BrainyMascot(
                                      mood: BrainyMood.sleepy,
                                      size: 84,
                                      animate: false,
                                      silhouette: true,
                                    ),
                                  ),
                                ),
                              if (nextStage != null)
                                Positioned(
                                  right: 0,
                                  child: Opacity(
                                    opacity: 0.45,
                                    child: BrainyMascot(
                                      mood: BrainyMood.excited,
                                      size: 84,
                                      animate: false,
                                      silhouette: true,
                                    ),
                                  ),
                                ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: _previewingNext
                                        ? BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryAccent
                                                    .withValues(alpha: 0.28),
                                                blurRadius: 36,
                                                spreadRadius: 4,
                                              ),
                                            ],
                                          )
                                        : null,
                                    child: BrainyMascot(
                                      mood: _previewingNext
                                          ? BrainyMood.celebrating
                                          : BrainyMood.happy,
                                      skin: _tracking.equippedSkin,
                                      silhouette: _previewingNext,
                                      size: 148,
                                    ),
                                  ),
                                  Text(
                                    _previewingNext
                                        ? 'PREVIEW FORM · LV ${displayedStage.minLevel}+'
                                        : 'CURRENT FORM',
                                    style: AppTypography.label(
                                      color: AppColors.primaryAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    displayedStage.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.heading(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (int i = 0; i < stages.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 8),
                                  Builder(
                                    builder: (context) {
                                      final st = stages[i];
                                      final unlocked =
                                          levelInfo.level >= st.minLevel;
                                      final isCurrent = i == currentIdx;
                                      return Container(
                                        width: 118,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isCurrent
                                              ? AppColors.primaryAccent
                                                  .withValues(alpha: 0.14)
                                              : AppColors.surfaceSolid,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                            color: isCurrent
                                                ? AppColors.primaryAccent
                                                : AppColors.borderSubtle,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Lv ${st.minLevel}+',
                                              style: AppTypography.label(
                                                color: unlocked
                                                    ? AppColors.primaryAccent
                                                    : AppColors.mutedText,
                                              ).copyWith(fontSize: 10),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              st.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption(
                                                color: unlocked
                                                    ? AppColors.primaryText
                                                    : AppColors.secondaryText,
                                              ).copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (nextStage != null)
                          ScrolaCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Next: ${nextStage.title}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.subheading(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(stageProgress * 100).round()}%',
                                      style: AppTypography.numeric(
                                        color: AppColors.primaryAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: stageProgress,
                                    minHeight: 8,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.08),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Reach Level ${nextStage.minLevel} · Stay under daily limit to earn faster XP.',
                                  style: AppTypography.caption(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        if (nextStage != null) ...[
                          const SizedBox(height: 16),
                          ScrolaPrimaryButton(
                            label: _previewingNext
                                ? 'Back to ${currentStage.title}'
                                : 'Preview ${nextStage.title}',
                            onPressed: () {
                              HapticService.light();
                              setState(
                                  () => _previewingNext = !_previewingNext);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final TrackingService _tracking = TrackingService();
  String _category = 'All';

  static const _categories = ['All', 'Streaks', 'Limits', 'Focus'];

  IconData _iconForBadge(String id) {
    switch (id) {
      case 'streak_7':
        return Icons.local_fire_department_rounded;
      case 'under_limit':
        return Icons.shield_rounded;
      case 'first_count':
        return Icons.bolt_rounded;
      case 'focus_starter':
        return Icons.timer_rounded;
      case 'deep_focus_60':
        return Icons.wb_sunny_rounded;
      case 'streak_14':
        return Icons.whatshot_rounded;
      case 'night_owl':
        return Icons.nights_stay_rounded;
      case 'detox_day':
        return Icons.spa_rounded;
      case 'level_5':
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final allBadges = _tracking.badges;
          final unlockedCount = allBadges.where((b) => b.unlocked).length;
          final visible = _category == 'All'
              ? allBadges
              : allBadges.where((b) => b.category == _category).toList();
          final highlight = allBadges.firstWhere(
            (b) => b.unlocked,
            orElse: () => allBadges.first,
          );
          final highlightIcon = _iconForBadge(highlight.id);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Achievements',
                    trailing: Text(
                      '$unlockedCount / ${allBadges.length}',
                      style: AppTypography.numeric(
                        color: AppColors.primaryAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ScrolaCard(
                    padding: const EdgeInsets.all(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.22),
                        AppColors.surfaceSolid,
                      ],
                    ),
                    borderColor: AppColors.primaryAccent.withValues(alpha: 0.4),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: highlight.unlocked
                                ? AppColors.primaryAccent
                                : AppColors.elevatedSurface,
                          ),
                          child: Icon(
                            highlightIcon,
                            color: highlight.unlocked
                                ? AppColors.textOnAccent
                                : AppColors.secondaryText,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                highlight.unlocked
                                    ? 'UNLOCKED'
                                    : 'NEXT MILESTONE',
                                style: AppTypography.label(
                                  color: AppColors.primaryAccent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                highlight.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.subheading(),
                              ),
                              Text(
                                highlight.description,
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
                            color:
                                AppColors.primaryAccent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            highlight.xpLabel,
                            style: AppTypography.caption(
                              color: AppColors.primaryAccent,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final selected = _category == cat;
                        return GestureDetector(
                          onTap: () {
                            HapticService.subtle();
                            setState(() => _category = cat);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryAccent
                                  : AppColors.surfaceSolid,
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primaryAccent
                                    : AppColors.borderSubtle,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                cat,
                                style: AppTypography.caption(
                                  color: selected
                                      ? AppColors.textOnAccent
                                      : AppColors.secondaryText,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      itemCount: visible.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 152,
                      ),
                      itemBuilder: (context, idx) {
                        final AchievementBadge b = visible[idx];
                        return ScrolaCard(
                          padding: const EdgeInsets.all(12),
                          borderColor: b.unlocked
                              ? AppColors.primaryAccent.withValues(alpha: 0.4)
                              : AppColors.borderSubtle,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: b.unlocked
                                      ? AppColors.primaryAccent
                                          .withValues(alpha: 0.16)
                                      : AppColors.elevatedSurface,
                                ),
                                child: Icon(
                                  _iconForBadge(b.id),
                                  color: b.unlocked
                                      ? AppColors.primaryAccent
                                      : AppColors.mutedText,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                b.title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.subheading(
                                  color: b.unlocked
                                      ? AppColors.primaryText
                                      : AppColors.secondaryText,
                                ).copyWith(fontSize: 13.5),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                b.unlocked ? 'Unlocked · ${b.xpLabel}' : b.xpLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption(
                                  color: b.unlocked
                                      ? AppColors.primaryAccent
                                      : AppColors.mutedText,
                                ).copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
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
          );
        },
      ),
    );
  }
}

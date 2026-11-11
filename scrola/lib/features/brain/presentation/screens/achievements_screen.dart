import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';
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
  String _category = 'All';

  static const _categories = ['All', 'Streaks', 'Limits', 'Focus', 'Social'];

  static const _badges = [
    _BadgeItem('7 Day Streak', 'Streaks', '+50 XP', true,
        Icons.local_fire_department_rounded),
    _BadgeItem('Under Limit', 'Limits', '+25 XP', true, Icons.shield_rounded),
    _BadgeItem('First Count', 'Limits', '+15 XP', true, Icons.bolt_rounded),
    _BadgeItem('Focus Starter', 'Focus', '+30 XP', true, Icons.timer_rounded),
    _BadgeItem('Early Bird', 'Focus', '+40 XP', false, Icons.wb_sunny_rounded),
    _BadgeItem('14 Day Streak', 'Streaks', '+100 XP', false,
        Icons.whatshot_rounded),
    _BadgeItem('Night Owl', 'Limits', '+40 XP', false,
        Icons.nights_stay_rounded),
    _BadgeItem('Detox Day', 'Focus', '+75 XP', false, Icons.spa_rounded),
    _BadgeItem(
        'Battle Ready', 'Social', '+50 XP', false, Icons.emoji_events_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _category == 'All'
        ? _badges
        : _badges.where((b) => b.category == _category).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScrolaAppBar(
                title: 'Achievements',
                trailing: Text(
                  '12 / 40',
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
                        color: AppColors.primaryAccent,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.textOnAccent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UNLOCKED TODAY',
                            style: AppTypography.label(
                              color: AppColors.primaryAccent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('7 Day Streak', style: AppTypography.subheading()),
                          Text(
                            'Stayed under your limit a full week.',
                            style: AppTypography.caption(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+50 XP',
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, idx) {
                    final b = visible[idx];
                    return ScrolaCard(
                      padding: const EdgeInsets.all(14),
                      borderColor: b.unlocked
                          ? AppColors.primaryAccent.withValues(alpha: 0.4)
                          : AppColors.borderSubtle,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: b.unlocked
                                  ? AppColors.primaryAccent
                                      .withValues(alpha: 0.16)
                                  : AppColors.elevatedSurface,
                            ),
                            child: Icon(
                              b.icon,
                              color: b.unlocked
                                  ? AppColors.primaryAccent
                                  : AppColors.mutedText,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            b.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.subheading(
                              color: b.unlocked
                                  ? AppColors.primaryText
                                  : AppColors.secondaryText,
                            ).copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b.xpLabel,
                            style: AppTypography.caption(
                              color: b.unlocked
                                  ? AppColors.primaryAccent
                                  : AppColors.mutedText,
                            ).copyWith(fontWeight: FontWeight.w600),
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

class _BadgeItem {
  final String title;
  final String category;
  final String xpLabel;
  final bool unlocked;
  final IconData icon;

  const _BadgeItem(
    this.title,
    this.category,
    this.xpLabel,
    this.unlocked,
    this.icon,
  );
}

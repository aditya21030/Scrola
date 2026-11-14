import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/social_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import 'create_battle_screen.dart';

class FriendProfileScreen extends StatelessWidget {
  final FriendUser friend;

  const FriendProfileScreen({super.key, required this.friend});

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
              ScrolaAppBar(title: friend.name),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    children: [
                      // Avatar Hero
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primaryAccent.withValues(alpha: 0.25),
                                    AppColors.cardSurface,
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.primaryAccent,
                                  width: 2.4,
                                ),
                              ),
                              child: Center(
                                child: BrainyMascot(
                                  mood: friend.isUnderLimit ? BrainyMood.happy : BrainyMood.sad,
                                  skin: friend.skin,
                                  size: 78,
                                  animate: true,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Lv ${friend.level}',
                                style: AppTypography.caption(
                                  color: AppColors.textOnAccent,
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        friend.name,
                        style: AppTypography.title(size: 24),
                      ),
                      Text(
                        '@${friend.username}',
                        style: AppTypography.caption(
                          color: AppColors.secondaryText,
                          size: 14,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Streak Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              '${friend.streak} day streak',
                              style: AppTypography.caption(
                                color: AppColors.primaryAccent,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 3-Card Stats Grid
                      Row(
                        children: [
                          Expanded(
                            child: ScrolaCard(
                              padding: const EdgeInsets.all(16),
                              radius: 18,
                              child: Column(
                                children: [
                                  Text(
                                    '${friend.reelsToday}',
                                    style: AppTypography.heading(size: 24),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reels today',
                                    style: AppTypography.caption(color: AppColors.secondaryText, size: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ScrolaCard(
                              padding: const EdgeInsets.all(16),
                              radius: 18,
                              child: Column(
                                children: [
                                  Text(
                                    '${friend.dailyLimit}',
                                    style: AppTypography.heading(size: 24),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Daily limit',
                                    style: AppTypography.caption(color: AppColors.secondaryText, size: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ScrolaCard(
                              padding: const EdgeInsets.all(16),
                              radius: 18,
                              child: Column(
                                children: [
                                  Text(
                                    '${friend.battleWins}',
                                    style: AppTypography.heading(size: 24, color: AppColors.accentHighlight),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Battle wins',
                                    style: AppTypography.caption(color: AppColors.secondaryText, size: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ScrolaPrimaryButton(
                label: 'Challenge to Battle',
                leadingIcon: const Icon(
                  Icons.sports_martial_arts_rounded,
                  color: AppColors.primaryBackground,
                  size: 20,
                ),
                onPressed: () {
                  HapticService.medium();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateBattleScreen(initialFriend: friend),
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

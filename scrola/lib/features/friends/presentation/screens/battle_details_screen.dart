import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/social_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class BattleDetailsScreen extends StatelessWidget {
  final ScrollBattle battle;

  const BattleDetailsScreen({super.key, required this.battle});

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();
    final isHistory = battle.status == BattleStatus.won || battle.status == BattleStatus.lost;
    final userReels = isHistory ? battle.userReels : tracking.totalReelsToday;
    final opponentReels = battle.opponentReels;
    final diff = (userReels - opponentReels).abs();
    final isWinning = userReels < opponentReels;
    final isTied = userReels == opponentReels;

    final String statusText;
    final Color bannerColor;
    if (battle.status == BattleStatus.won) {
      statusText = 'Victory! You finished with fewer reels.';
      bannerColor = AppColors.success;
    } else if (battle.status == BattleStatus.lost) {
      statusText = 'Battle ended. ${battle.opponent.name} won this round.';
      bannerColor = AppColors.error;
    } else if (isTied) {
      statusText = 'You and ${battle.opponent.name} are tied at $userReels reels!';
      bannerColor = AppColors.accentHighlight;
    } else if (isWinning) {
      statusText = 'You are currently leading by $diff fewer reel${diff == 1 ? '' : 's'}!';
      bannerColor = AppColors.success;
    } else {
      statusText = 'You are trailing by $diff reel${diff == 1 ? '' : 's'}. Stay focused!';
      bannerColor = AppColors.error;
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScrolaAppBar(
                title: 'You vs ${battle.opponent.name}',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.elevatedSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    battle.durationLabel,
                    style: AppTypography.caption(
                      color: AppColors.accentHighlight,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    children: [
                      // VS Hero Arena Card
                      ScrolaCard(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        radius: 28,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Left player: User
                                Column(
                                  children: [
                                    BrainyMascot(
                                      mood: tracking.currentMood,
                                      skin: tracking.equippedSkin,
                                      size: 72,
                                      animate: true,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'You',
                                      style: AppTypography.heading(size: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$userReels reels',
                                      style: AppTypography.title(
                                        size: 32,
                                        color: AppColors.primaryAccent,
                                      ),
                                    ),
                                    Text(
                                      'Cap: ${battle.targetLimit}',
                                      style: AppTypography.caption(color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),

                                // VS divider badge
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.elevatedSurface,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'VS',
                                    style: AppTypography.caption(
                                      color: AppColors.warmText,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                ),

                                // Right player: Opponent
                                Column(
                                  children: [
                                    BrainyMascot(
                                      mood: battle.opponent.isUnderLimit
                                          ? BrainyMood.happy
                                          : BrainyMood.sad,
                                      skin: battle.opponent.skin,
                                      size: 72,
                                      animate: true,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      battle.opponent.name,
                                      style: AppTypography.heading(size: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${battle.opponentReels} reels',
                                      style: AppTypography.title(
                                        size: 32,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    Text(
                                      'Cap: ${battle.targetLimit}',
                                      style: AppTypography.caption(color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Status Banner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: bannerColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusText,
                                textAlign: TextAlign.center,
                                style: AppTypography.caption(
                                  color: bannerColor,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Battle Rules Card
                      ScrolaCard(
                        padding: const EdgeInsets.all(20),
                        radius: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BATTLE RULES',
                              style: AppTypography.label(color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '1. The player who watches fewer vertical video reels (Instagram, YouTube, TikTok) before the timer ends wins.',
                              style: AppTypography.body(size: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '2. If both players stay under the ${battle.targetLimit} reel limit, both keep their streak intact.',
                              style: AppTypography.body(size: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '3. Winner earns +${battle.xpStakes} XP towards their Brainy evolution form.',
                              style: AppTypography.body(
                                size: 14,
                                color: AppColors.accentHighlight,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ScrolaSecondaryButton(
                label: 'Back to Battles',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

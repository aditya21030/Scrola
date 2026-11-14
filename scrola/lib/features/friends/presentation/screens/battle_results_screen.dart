import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/social_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class BattleResultsScreen extends StatelessWidget {
  final ScrollBattle battle;

  const BattleResultsScreen({super.key, required this.battle});

  @override
  Widget build(BuildContext context) {
    final isWon = battle.status == BattleStatus.won;
    final tracking = TrackingService();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: 'Battle Results'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 24, bottom: 20),
                  child: Column(
                    children: [
                      // Mascot Hero
                      BrainyMascot(
                        mood: isWon ? BrainyMood.celebrating : BrainyMood.sad,
                        skin: tracking.equippedSkin,
                        size: 110,
                        animate: true,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isWon ? 'VICTORY!' : 'DEFEAT',
                        style: AppTypography.title(
                          size: 38,
                          color: isWon ? AppColors.accentHighlight : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isWon
                            ? 'You out-focused ${battle.opponent.name} and claimed +${battle.xpStakes} XP!'
                            : '${battle.opponent.name} watched fewer reels this round. Better focus next time!',
                        textAlign: TextAlign.center,
                        style: AppTypography.body(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 28),

                      // Score Card
                      ScrolaCard(
                        padding: const EdgeInsets.all(22),
                        radius: 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${battle.userReels}',
                                  style: AppTypography.title(
                                    size: 36,
                                    color: isWon ? AppColors.success : AppColors.error,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your reels',
                                  style: AppTypography.caption(color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 48,
                              color: AppColors.border,
                            ),
                            Column(
                              children: [
                                Text(
                                  '${battle.opponentReels}',
                                  style: AppTypography.title(
                                    size: 36,
                                    color: isWon ? AppColors.error : AppColors.success,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${battle.opponent.name}'s reels",
                                  style: AppTypography.caption(color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ScrolaPrimaryButton(
                label: isWon ? 'Collect +${battle.xpStakes} XP' : 'Done',
                leadingIcon: Icon(
                  isWon ? Icons.stars_rounded : Icons.check_rounded,
                  color: AppColors.primaryBackground,
                  size: 20,
                ),
                onPressed: () async {
                  if (isWon) {
                    await tracking.addXP(battle.xpStakes);
                    await HapticService.celebratory();
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

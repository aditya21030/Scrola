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
import 'battle_details_screen.dart';
import 'battle_results_screen.dart';
import 'create_battle_screen.dart';

class ScrollBattlesScreen extends StatefulWidget {
  const ScrollBattlesScreen({super.key});

  @override
  State<ScrollBattlesScreen> createState() => _ScrollBattlesScreenState();
}

class _ScrollBattlesScreenState extends State<ScrollBattlesScreen> {
  final SocialService _social = SocialService();
  int _selectedTabIndex = 0; // 0 = Active, 1 = History

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _social,
        builder: (context, _) {
          final activeList = _social.activeBattles;
          final historyList = _social.battleHistory;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Battles',
                    trailing: GestureDetector(
                      onTap: () {
                        HapticService.light();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateBattleScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '+ New',
                          style: AppTypography.caption(
                            color: AppColors.primaryAccent,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Segmented Tabs: Active vs History
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticService.subtle();
                              setState(() => _selectedTabIndex = 0);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 0
                                    ? AppColors.primaryAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Active (${activeList.length})',
                                style: AppTypography.body(
                                  color: _selectedTabIndex == 0
                                      ? AppColors.textOnAccent
                                      : AppColors.secondaryText,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticService.subtle();
                              setState(() => _selectedTabIndex = 1);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 1
                                    ? AppColors.primaryAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'History (${historyList.length})',
                                style: AppTypography.body(
                                  color: _selectedTabIndex == 1
                                      ? AppColors.textOnAccent
                                      : AppColors.secondaryText,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Expanded(
                    child: _selectedTabIndex == 0
                        ? (activeList.isEmpty
                            ? _buildEmptyActiveState()
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: activeList.length,
                                separatorBuilder: (_, index) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final battle = activeList[index];
                                  return _buildActiveBattleCard(battle);
                                },
                              ))
                        : (historyList.isEmpty
                            ? _buildEmptyHistoryState()
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: historyList.length,
                                separatorBuilder: (_, index) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final battle = historyList[index];
                                  return _buildHistoryBattleCard(battle);
                                },
                              )),
                  ),
                  const SizedBox(height: 12),
                  ScrolaPrimaryButton(
                    label: 'Create a Battle',
                    leadingIcon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.primaryBackground,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticService.medium();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateBattleScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveBattleCard(ScrollBattle battle) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BattleDetailsScreen(battle: battle),
          ),
        );
      },
      child: ScrolaCard(
        padding: const EdgeInsets.all(18),
        radius: 20,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    BrainyMascot(
                      mood: BrainyMood.focused,
                      skin: battle.opponent.skin,
                      size: 30,
                      animate: false,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'You vs ${battle.opponent.name}',
                      style: AppTypography.body(weight: FontWeight.w700),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.elevatedSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    battle.durationLabel,
                    style: AppTypography.caption(
                      color: AppColors.secondaryText,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${battle.userReels} reels',
                      style: AppTypography.heading(size: 20),
                    ),
                    Text(
                      'You',
                      style: AppTypography.caption(color: AppColors.secondaryText),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: battle.isUserWinning
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    battle.isUserWinning ? 'Winning' : 'Trailing',
                    style: AppTypography.caption(
                      color: battle.isUserWinning ? AppColors.success : AppColors.error,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${battle.opponentReels} reels',
                      style: AppTypography.heading(size: 20),
                    ),
                    Text(
                      battle.opponent.name,
                      style: AppTypography.caption(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: battle.userReels / (battle.userReels + battle.opponentReels).clamp(1, 999),
                backgroundColor: AppColors.elevatedSurface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryBattleCard(ScrollBattle battle) {
    final isWon = battle.status == BattleStatus.won;
    return GestureDetector(
      onTap: () {
        HapticService.light();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BattleResultsScreen(battle: battle),
          ),
        );
      },
      child: ScrolaCard(
        padding: const EdgeInsets.all(16),
        radius: 20,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isWon
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWon ? Icons.emoji_events_rounded : Icons.close_rounded,
                color: isWon ? AppColors.success : AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You vs ${battle.opponent.name}',
                    style: AppTypography.body(weight: FontWeight.w600),
                  ),
                  Text(
                    '${battle.userReels} - ${battle.opponentReels} reels',
                    style: AppTypography.caption(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isWon ? '+${battle.xpStakes} XP' : '0 XP',
                  style: AppTypography.caption(
                    color: isWon ? AppColors.accentHighlight : AppColors.secondaryText,
                    weight: FontWeight.w700,
                  ),
                ),
                Text(
                  isWon ? 'Won' : 'Lost',
                  style: AppTypography.caption(
                    color: isWon ? AppColors.success : AppColors.error,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActiveState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BrainyMascot(mood: BrainyMood.neutral, size: 90, animate: false),
          const SizedBox(height: 16),
          Text('No active battles', style: AppTypography.heading()),
          const SizedBox(height: 6),
          Text(
            'Challenge a friend to see who can scroll less reels today.',
            textAlign: TextAlign.center,
            style: AppTypography.body(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BrainyMascot(mood: BrainyMood.happy, size: 90, animate: false),
          const SizedBox(height: 16),
          Text('No completed battles yet', style: AppTypography.heading()),
        ],
      ),
    );
  }
}

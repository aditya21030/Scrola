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

class CreateBattleScreen extends StatefulWidget {
  final FriendUser? initialFriend;

  const CreateBattleScreen({super.key, this.initialFriend});

  @override
  State<CreateBattleScreen> createState() => _CreateBattleScreenState();
}

class _CreateBattleScreenState extends State<CreateBattleScreen> {
  final SocialService _social = SocialService();
  late FriendUser _selectedFriend;
  int _selectedDurationDays = 1;
  int _targetLimit = 25;
  int _selectedXpStake = 150;

  @override
  void initState() {
    super.initState();
    _selectedFriend = widget.initialFriend ??
        (_social.friends.isNotEmpty
            ? _social.friends.first
            : const FriendUser(
                id: 'f1',
                name: 'Zoe',
                username: 'zoe.mind',
                skin: BrainySkin.aqua,
                level: 14,
                streak: 12,
                reelsToday: 16,
                dailyLimit: 25,
              ));
  }

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
              const ScrolaAppBar(title: 'Create battle'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section 1: Choose Opponent
                      Text(
                        'CHOOSE OPPONENT',
                        style: AppTypography.label(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 94,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _social.friends.length,
                          separatorBuilder: (_, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final friend = _social.friends[index];
                            final isSelected = friend.id == _selectedFriend.id;
                            return GestureDetector(
                              onTap: () {
                                HapticService.subtle();
                                setState(() => _selectedFriend = friend);
                              },
                              child: Container(
                                width: 76,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.cardSurface : AppColors.primaryBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryAccent : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    BrainyMascot(
                                      mood: BrainyMood.happy,
                                      skin: friend.skin,
                                      size: 36,
                                      animate: false,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      friend.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption(
                                        color: isSelected ? AppColors.primaryAccent : AppColors.primaryText,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Duration
                      Text(
                        'BATTLE DURATION',
                        style: AppTypography.label(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          for (final d in [
                            {'days': 1, 'label': '24 Hours'},
                            {'days': 3, 'label': '3 Days'},
                            {'days': 7, 'label': '7 Days'},
                          ]) ...[
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticService.subtle();
                                  setState(() => _selectedDurationDays = d['days'] as int);
                                },
                                child: Container(
                                  height: 48,
                                  margin: EdgeInsets.only(
                                    right: d['days'] != 7 ? 8 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedDurationDays == d['days']
                                        ? AppColors.primaryAccent
                                        : AppColors.cardSurface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _selectedDurationDays == d['days']
                                          ? AppColors.primaryAccent
                                          : AppColors.border,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    d['label'] as String,
                                    style: AppTypography.body(
                                      color: _selectedDurationDays == d['days']
                                          ? AppColors.textOnAccent
                                          : AppColors.primaryText,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Daily Limit Target
                      Text(
                        'DAILY TARGET LIMIT',
                        style: AppTypography.label(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 10),
                      ScrolaCard(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        radius: 20,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Daily Limit per player',
                                  style: AppTypography.body(color: AppColors.secondaryText),
                                ),
                                Text(
                                  '$_targetLimit reels',
                                  style: AppTypography.heading(color: AppColors.primaryAccent),
                                ),
                              ],
                            ),
                            Slider(
                              value: _targetLimit.toDouble(),
                              min: 10,
                              max: 60,
                              divisions: 10,
                              activeColor: AppColors.primaryAccent,
                              inactiveColor: AppColors.elevatedSurface,
                              onChanged: (val) {
                                setState(() => _targetLimit = val.round());
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 4: XP Stakes
                      Text(
                        'XP STAKES',
                        style: AppTypography.label(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          for (final xp in [100, 150, 300]) ...[
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticService.subtle();
                                  setState(() => _selectedXpStake = xp);
                                },
                                child: Container(
                                  height: 52,
                                  margin: EdgeInsets.only(
                                    right: xp != 300 ? 8 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedXpStake == xp
                                        ? AppColors.accentHighlight.withValues(alpha: 0.2)
                                        : AppColors.cardSurface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _selectedXpStake == xp
                                          ? AppColors.accentHighlight
                                          : AppColors.border,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+$xp XP',
                                        style: AppTypography.body(
                                          color: _selectedXpStake == xp
                                              ? AppColors.accentHighlight
                                              : AppColors.primaryText,
                                          weight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ScrolaPrimaryButton(
                label: 'Send Battle Invite',
                leadingIcon: const Icon(
                  Icons.send_rounded,
                  color: AppColors.primaryBackground,
                  size: 18,
                ),
                onPressed: () async {
                  await _social.createBattle(
                    opponent: _selectedFriend,
                    targetLimit: _targetLimit,
                    durationLabel: '$_selectedDurationDays d left',
                    xpStakes: _selectedXpStake,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Battle invitation sent to ${_selectedFriend.name}!'),
                      ),
                    );
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

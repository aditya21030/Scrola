import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/social_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';
import 'battle_details_screen.dart';
import 'create_battle_screen.dart';
import 'find_friends_screen.dart';
import 'friend_profile_screen.dart';
import 'friends_leaderboard_screen.dart';
import 'group_challenges_screen.dart';
import 'scroll_battles_screen.dart';

class FriendsDashboardScreen extends StatefulWidget {
  final bool showBack;

  const FriendsDashboardScreen({super.key, this.showBack = false});

  @override
  State<FriendsDashboardScreen> createState() => _FriendsDashboardScreenState();
}

class _FriendsDashboardScreenState extends State<FriendsDashboardScreen> {
  final SocialService _social = SocialService();
  final TrackingService _tracking = TrackingService();

  @override
  void initState() {
    super.initState();
    _social.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: Listenable.merge([_social, _tracking]),
        builder: (context, _) {
          final liveBattle = _social.activeBattles.isNotEmpty
              ? _social.activeBattles.first
              : null;

          return Stack(
            children: [
              // Radial glow
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 380,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.4),
                      radius: 0.85,
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.showBack)
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 44,
                                height: 44,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                          Text(
                            'Friends',
                            style: AppTypography.title(size: 28),
                          ),
                          const Spacer(),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticService.light();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const FindFriendsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 20,
                                color: AppColors.accentHighlight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Horizontal Friends Avatar Strip
                      SizedBox(
                        height: 92,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _social.friends.length + 1,
                          separatorBuilder: (_, index) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // User's own avatar
                              return Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        padding: const EdgeInsets.all(2.5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primaryAccent,
                                            width: 2.2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: AppColors.cardSurface,
                                          child: BrainyMascot(
                                            mood: BrainyMood.happy,
                                            skin: _tracking.equippedSkin,
                                            size: 38,
                                            animate: false,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 2,
                                        bottom: 2,
                                        child: Container(
                                          width: 13,
                                          height: 13,
                                          decoration: BoxDecoration(
                                            color: AppColors.success,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.primaryBackground,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'You',
                                    style: AppTypography.caption(
                                      color: AppColors.primaryText,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            }

                            final friend = _social.friends[index - 1];
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticService.light();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => FriendProfileScreen(friend: friend),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        padding: const EdgeInsets.all(2.5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: friend.streak > 7
                                                ? AppColors.primaryAccent
                                                : AppColors.border,
                                            width: 1.8,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: AppColors.cardSurface,
                                          child: BrainyMascot(
                                            mood: friend.isUnderLimit
                                                ? BrainyMood.happy
                                                : BrainyMood.sad,
                                            skin: friend.skin,
                                            size: 38,
                                            animate: false,
                                          ),
                                        ),
                                      ),
                                      if (friend.isOnline)
                                        Positioned(
                                          right: 2,
                                          bottom: 2,
                                          child: Container(
                                            width: 13,
                                            height: 13,
                                            decoration: BoxDecoration(
                                              color: AppColors.success,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.primaryBackground,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    friend.name,
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Live Battle Banner Card
                      if (liveBattle != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LIVE BATTLE',
                              style: AppTypography.label(color: AppColors.secondaryText),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticService.subtle();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ScrollBattlesScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'All battles',
                                style: AppTypography.caption(
                                  color: AppColors.accentHighlight,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            HapticService.light();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BattleDetailsScreen(battle: liveBattle),
                              ),
                            );
                          },
                          child: ScrolaCard(
                            padding: const EdgeInsets.all(20),
                            radius: 24,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryAccent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.primaryAccent.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primaryAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            'VS ${liveBattle.opponent.name.toUpperCase()}',
                                            style: AppTypography.caption(
                                              color: AppColors.primaryAccent,
                                              weight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      liveBattle.durationLabel,
                                      style: AppTypography.caption(
                                        color: AppColors.secondaryText,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    // User side
                                    Column(
                                      children: [
                                        Text(
                                          '${_tracking.totalReelsToday}',
                                          style: AppTypography.title(
                                            size: 36,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'You',
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                            weight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // VS Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.elevatedSurface,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Text(
                                        'VS',
                                        style: AppTypography.caption(
                                          color: AppColors.warmText,
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    // Opponent side
                                    Column(
                                      children: [
                                        Text(
                                          '${liveBattle.opponentReels}',
                                          style: AppTypography.title(
                                            size: 36,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          liveBattle.opponent.name,
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                            weight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _tracking.totalReelsToday /
                                        ((_tracking.totalReelsToday + liveBattle.opponentReels)
                                            .clamp(1, 999)),
                                    backgroundColor: AppColors.elevatedSurface,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Fewest reels watched wins +${liveBattle.xpStakes} XP',
                                  style: AppTypography.caption(
                                    color: AppColors.secondaryText,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Leaderboard Card Preview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LEADERBOARD',
                            style: AppTypography.label(color: AppColors.secondaryText),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticService.subtle();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const FriendsLeaderboardScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'View all',
                              style: AppTypography.caption(
                                color: AppColors.accentHighlight,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ScrolaCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        radius: 20,
                        child: Column(
                          children: [
                            for (int i = 0; i < _social.friends.take(3).length; i++) ...[
                              if (i > 0)
                                const Divider(color: AppColors.border, height: 16),
                              Row(
                                children: [
                                  Text(
                                    '#${i + 1}',
                                    style: AppTypography.caption(
                                      color: i == 0 ? AppColors.accentHighlight : AppColors.secondaryText,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  BrainyMascot(
                                    mood: BrainyMood.happy,
                                    skin: _social.friends[i].skin,
                                    size: 32,
                                    animate: false,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _social.friends[i].name,
                                          style: AppTypography.body(weight: FontWeight.w600),
                                        ),
                                        Text(
                                          '${_social.friends[i].streak}d streak · Lv ${_social.friends[i].level}',
                                          style: AppTypography.caption(
                                            color: AppColors.secondaryText,
                                            size: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _social.friends[i].isUnderLimit
                                          ? AppColors.success.withValues(alpha: 0.15)
                                          : AppColors.error.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_social.friends[i].reelsToday} reels',
                                      style: AppTypography.caption(
                                        color: _social.friends[i].isUnderLimit
                                            ? AppColors.success
                                            : AppColors.error,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Community Challenges Card Preview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GROUP CHALLENGES',
                            style: AppTypography.label(color: AppColors.secondaryText),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticService.subtle();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const GroupChallengesScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Explore',
                              style: AppTypography.caption(
                                color: AppColors.accentHighlight,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_social.challenges.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            HapticService.light();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GroupChallengesScreen(),
                              ),
                            );
                          },
                          child: ScrolaCard(
                            padding: const EdgeInsets.all(18),
                            radius: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.accentHighlight),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _social.challenges.first.title,
                                        style: AppTypography.body(weight: FontWeight.w700),
                                      ),
                                    ),
                                    Text(
                                      '${_social.challenges.first.daysLeft}d left',
                                      style: AppTypography.caption(color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _social.challenges.first.description,
                                  style: AppTypography.caption(color: AppColors.warmText, size: 12.5),
                                ),
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: _social.challenges.first.progress,
                                    backgroundColor: AppColors.elevatedSurface,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_social.challenges.first.currentReels} / ${_social.challenges.first.targetLimit} reels',
                                      style: AppTypography.caption(
                                        color: AppColors.primaryAccent,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${_social.challenges.first.participantsCount} participants',
                                      style: AppTypography.caption(color: AppColors.secondaryText, size: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Start Battle Button
                      ScrolaPrimaryButton(
                        label: 'Challenge a Friend',
                        leadingIcon: const Icon(
                          Icons.sports_martial_arts_rounded,
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
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/social_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';

class FriendsLeaderboardScreen extends StatefulWidget {
  const FriendsLeaderboardScreen({super.key});

  @override
  State<FriendsLeaderboardScreen> createState() =>
      _FriendsLeaderboardScreenState();
}

class _FriendsLeaderboardScreenState extends State<FriendsLeaderboardScreen> {
  final SocialService _social = SocialService();
  final TrackingService _tracking = TrackingService();
  int _selectedFilter = 1; // 0 = Today, 1 = Week, 2 = All time

  @override
  Widget build(BuildContext context) {
    final friends = _social.friends;
    // Construct leaderboard entries: You + friends sorted by XP / low reels
    final allEntries = <_LeaderboardItem>[
      _LeaderboardItem(
        id: 'me',
        name: 'You',
        username: _tracking.username,
        skin: _tracking.equippedSkin,
        xp: _tracking.xpTotal,
        reels: _tracking.totalReelsToday,
        dailyLimit: _tracking.totalLimit,
        isMe: true,
      ),
      for (final f in friends)
        _LeaderboardItem(
          id: f.id,
          name: f.name,
          username: f.username,
          skin: f.skin,
          xp: f.level * 180 + f.streak * 45,
          reels: f.reelsToday,
          dailyLimit: f.dailyLimit,
          isMe: false,
        ),
    ];

    allEntries.sort((a, b) => b.xp.compareTo(a.xp));

    final top3 = allEntries.take(3).toList();
    final remaining = allEntries.skip(3).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: 'Leaderboard'),
              const SizedBox(height: 10),

              // Segmented Tab: Today / Week / All time
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _buildSegment('Today', 0),
                    _buildSegment('Week', 1),
                    _buildSegment('All time', 2),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top 3 Podium
                      if (top3.length >= 3)
                        _buildPodium(top3[0], top3[1], top3[2])
                      else if (top3.isNotEmpty)
                        _buildSimpleHeader(top3),

                      const SizedBox(height: 16),

                      // Ranks 4+ List
                      if (remaining.isNotEmpty) ...[
                        ScrolaCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          radius: 24,
                          child: Column(
                            children: [
                              for (int i = 0; i < remaining.length; i++) ...[
                                if (i > 0)
                                  Divider(
                                    height: 1,
                                    color: AppColors.border.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                _buildRankRow(remaining[i], i + 4),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      Text(
                        'Ranked by how little of your reel limit you consumed.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegment(String title, int index) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.subtle();
          setState(() => _selectedFilter = index);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.caption(
              color: isSelected
                  ? AppColors.primaryBackground
                  : AppColors.secondaryText,
              weight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(
    _LeaderboardItem first,
    _LeaderboardItem second,
    _LeaderboardItem third,
  ) {
    return SizedBox(
      height: 230,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2: Silver Pedestal
          Expanded(
            child: _buildPodiumColumn(
              item: second,
              rank: 2,
              pedestalHeight: 86,
              color: const Color(0xFFC9C9C9),
            ),
          ),
          const SizedBox(width: 10),
          // Rank 1: Gold / Orange Pedestal
          Expanded(
            child: _buildPodiumColumn(
              item: first,
              rank: 1,
              pedestalHeight: 120,
              color: AppColors.primaryAccent,
            ),
          ),
          const SizedBox(width: 10),
          // Rank 3: Bronze Pedestal
          Expanded(
            child: _buildPodiumColumn(
              item: third,
              rank: 3,
              pedestalHeight: 64,
              color: const Color(0xFFC98A52),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required _LeaderboardItem item,
    required int rank,
    required double pedestalHeight,
    required Color color,
  }) {
    final avatarSize = rank == 1 ? 58.0 : 48.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BrainyMascot(
          mood: BrainyMood.happy,
          skin: item.skin,
          size: avatarSize,
          animate: false,
        ),
        const SizedBox(height: 6),
        Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body(
            color: item.isMe ? AppColors.primaryAccent : AppColors.primaryText,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: pedestalHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '$rank',
            style: AppTypography.title(
              color: AppColors.primaryBackground,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleHeader(List<_LeaderboardItem> items) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) _buildRankRow(items[i], i + 1),
      ],
    );
  }

  Widget _buildRankRow(_LeaderboardItem item, int rank) {
    final pct = (item.reels / (item.dailyLimit > 0 ? item.dailyLimit : 40))
        .clamp(0.0, 1.0);
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: item.isMe
            ? AppColors.primaryAccent.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$rank',
              style: AppTypography.heading(
                color: AppColors.secondaryText,
                size: 16,
              ),
            ),
          ),
          BrainyMascot(
            mood: BrainyMood.happy,
            skin: item.skin,
            size: 36,
            animate: false,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.body(
                    color: item.isMe
                        ? AppColors.primaryAccent
                        : AppColors.primaryText,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: AppColors.elevatedSurface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct > 0.85 ? AppColors.error : AppColors.primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '${item.xp} XP',
            style: AppTypography.caption(
              color: AppColors.secondaryText,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem {
  final String id;
  final String name;
  final String username;
  final BrainySkin skin;
  final int xp;
  final int reels;
  final int dailyLimit;
  final bool isMe;

  const _LeaderboardItem({
    required this.id,
    required this.name,
    required this.username,
    required this.skin,
    required this.xp,
    required this.reels,
    required this.dailyLimit,
    required this.isMe,
  });
}

import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/social_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';

class GroupChallengesScreen extends StatefulWidget {
  const GroupChallengesScreen({super.key});

  @override
  State<GroupChallengesScreen> createState() => _GroupChallengesScreenState();
}

class _GroupChallengesScreenState extends State<GroupChallengesScreen> {
  final SocialService _social = SocialService();
  final TrackingService _tracking = TrackingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: 'Challenges'),
              const SizedBox(height: 12),
              Expanded(
                child: ListenableBuilder(
                  listenable: _social,
                  builder: (context, _) {
                    final challenges = _social.challenges;
                    final activeTeamChallenge = challenges.firstWhere(
                      (c) => c.isJoined,
                      orElse: () => challenges.first,
                    );

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Hero Team Goal Card
                          _buildHeroChallengeCard(activeTeamChallenge),
                          const SizedBox(height: 24),

                          // Section: Join a Challenge
                          Text(
                            'JOIN A CHALLENGE',
                            style: AppTypography.label(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 12),

                          for (final challenge in challenges)
                            if (challenge.id != activeTeamChallenge.id) ...[
                              _buildChallengeItem(challenge),
                              const SizedBox(height: 12),
                            ],
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

  Widget _buildHeroChallengeCard(GroupChallenge challenge) {
    final pct = (challenge.currentReels / challenge.targetLimit).clamp(
      0.0,
      1.0,
    );

    return ScrolaCard(
      padding: const EdgeInsets.all(20),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TEAM GOAL · 2 DAYS LEFT',
                    style: AppTypography.label(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    challenge.title,
                    style: AppTypography.heading(size: 20),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${challenge.participantsCount} members',
                  style: AppTypography.caption(
                    color: AppColors.warmText,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Big Progress Numbers
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${challenge.currentReels}',
                style: AppTypography.title(
                  size: 48,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'of ${challenge.targetLimit} reels together',
                style: AppTypography.body(
                  color: AppColors.secondaryText,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Thick Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 12,
              backgroundColor: AppColors.elevatedSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryAccent,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Divider(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),

          // Contributor Members
          _buildMemberRow('Mira', BrainySkin.aqua, 22, 50),
          _buildMemberRow('Zoe', BrainySkin.rose, 18, 50),
          _buildMemberRow('Kai', BrainySkin.golden, 14, 50),
          _buildMemberRow(
            'You',
            _tracking.equippedSkin,
            _tracking.totalReelsToday,
            _tracking.totalLimit,
            isMe: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberRow(
    String name,
    BrainySkin skin,
    int reels,
    int limit, {
    bool isMe = false,
  }) {
    final pct = (reels / (limit > 0 ? limit : 40)).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          BrainyMascot(
            mood: BrainyMood.happy,
            skin: skin,
            size: 30,
            animate: false,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 48,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                color: isMe ? AppColors.primaryAccent : AppColors.primaryText,
                weight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: AppColors.elevatedSurface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isMe ? AppColors.primaryAccent : AppColors.secondaryText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text(
              '$reels',
              textAlign: TextAlign.right,
              style: AppTypography.caption(
                color: AppColors.secondaryText,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(GroupChallenge challenge) {
    return ScrolaCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 20,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: AppColors.warmText,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: AppTypography.body(weight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${challenge.daysLeft} days left · ${challenge.participantsCount} people',
                  style: AppTypography.caption(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              await _social.toggleJoinChallenge(challenge.id);
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: challenge.isJoined
                    ? AppColors.elevatedSurface
                    : AppColors.primaryAccent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: challenge.isJoined
                      ? AppColors.border
                      : AppColors.primaryAccent,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                challenge.isJoined ? 'Joined' : 'Join',
                style: AppTypography.caption(
                  color: challenge.isJoined
                      ? AppColors.secondaryText
                      : AppColors.primaryBackground,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

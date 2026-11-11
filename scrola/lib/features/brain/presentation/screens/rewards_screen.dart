import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final TrackingService _tracking = TrackingService();
  bool _chestOpened = false;
  bool _xpBoostClaimed = false;
  bool _emberClaimed = false;

  int get _readyCount =>
      (_chestOpened ? 0 : 1) +
      (_xpBoostClaimed ? 0 : 1) +
      (_emberClaimed ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScrolaAppBar(
                title: 'Rewards',
                trailing: Text(
                  '$_readyCount ready',
                  style: AppTypography.caption(color: AppColors.primaryAccent)
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              const SizedBox(height: 18),
              ScrolaCard(
                padding: const EdgeInsets.all(20),
                borderColor: _chestOpened
                    ? AppColors.borderSubtle
                    : AppColors.primaryAccent.withValues(alpha: 0.5),
                gradient: _chestOpened
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryAccent.withValues(alpha: 0.22),
                          AppColors.surfaceSolid,
                        ],
                      ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (_chestOpened
                                ? AppColors.success
                                : AppColors.primaryAccent)
                            .withValues(alpha: 0.16),
                      ),
                      child: Icon(
                        _chestOpened
                            ? Icons.check_circle_rounded
                            : Icons.card_giftcard_rounded,
                        color: _chestOpened
                            ? AppColors.success
                            : AppColors.primaryAccent,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Streak chest',
                      style: AppTypography.title().copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _chestOpened
                          ? 'Claimed +100 XP!'
                          : '7 days earned · Contains +100 XP.',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ScrolaPrimaryButton(
                      label: _chestOpened ? 'Opened' : 'Open chest',
                      onPressed: _chestOpened
                          ? null
                          : () {
                              HapticService.celebratory();
                              _tracking.addXP(100);
                              setState(() => _chestOpened = true);
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'READY TO CLAIM',
                style: AppTypography.label(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 10),
              _RewardRow(
                title: '+100 XP boost',
                subtitle: 'From your 7 day streak',
                claimed: _xpBoostClaimed,
                onClaim: () {
                  HapticService.celebratory();
                  _tracking.addXP(100);
                  setState(() => _xpBoostClaimed = true);
                },
              ),
              const SizedBox(height: 10),
              _RewardRow(
                title: 'Ember Brainy skin',
                subtitle: 'Level 4 reward',
                claimed: _emberClaimed,
                onClaim: () {
                  HapticService.celebratory();
                  _tracking.equipSkin(BrainySkin.ember);
                  setState(() => _emberClaimed = true);
                },
              ),
              const SizedBox(height: 22),
              Text(
                'COMING UP',
                style: AppTypography.label(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 10),
              const _UpcomingRow(
                title: 'Golden glow',
                subtitle: 'New counter theme',
                level: 'Level 5',
              ),
              const SizedBox(height: 10),
              const _UpcomingRow(
                title: 'Bright Mind form',
                subtitle: 'Brain evolution',
                level: 'Level 6',
              ),
              const SizedBox(height: 10),
              const _UpcomingRow(
                title: 'Frost skin',
                subtitle: 'Collection',
                level: 'Level 8',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool claimed;
  final VoidCallback onClaim;

  const _RewardRow({
    required this.title,
    required this.subtitle,
    required this.claimed,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (claimed ? AppColors.success : AppColors.primaryAccent)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              claimed ? Icons.check_rounded : Icons.stars_rounded,
              color: claimed ? AppColors.success : AppColors.primaryAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.subheading().copyWith(fontSize: 15)),
                Text(
                  subtitle,
                  style: AppTypography.caption(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: claimed ? null : onClaim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: claimed
                    ? AppColors.successBackground
                    : AppColors.primaryAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                claimed ? 'Claimed' : 'Claim',
                style: AppTypography.caption(
                  color: claimed ? AppColors.success : AppColors.textOnAccent,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String level;

  const _UpcomingRow({
    required this.title,
    required this.subtitle,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.secondaryText,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.subheading().copyWith(fontSize: 15)),
                Text(
                  subtitle,
                  style: AppTypography.caption(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          Text(
            level,
            style: AppTypography.caption(color: AppColors.secondaryText)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

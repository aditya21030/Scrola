import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import 'edit_profile_screen.dart';
import 'notifications_settings_screen.dart';
import 'settings_screen.dart';
import 'subscription_pro_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool showBack;

  const ProfileScreen({super.key, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final tracking = TrackingService();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: tracking,
        builder: (context, _) {
          final info = GamificationEngine.getLevelForXP(tracking.xpTotal);
          final stage = GamificationEngine.getStageForLevel(info.level);

          return SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: ScrolaAppBar(
                    title: 'Profile',
                    showBack: showBack,
                    trailing: _SettingsBtn(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      showBack ? 28 : 112,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ScrolaCard(
                          padding: const EdgeInsets.all(20),
                          onTap: () {
                            HapticService.subtle();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppColors.primaryAccent
                                              .withValues(alpha: 0.28),
                                          AppColors.elevatedSurface,
                                        ],
                                      ),
                                      border: Border.all(
                                        color: AppColors.primaryAccent
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Center(
                                      child: BrainyMascot(
                                        mood: tracking.currentMood,
                                        skin: tracking.equippedSkin,
                                        size: 72,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryAccent,
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      size: 15,
                                      color: AppColors.textOnAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tracking.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style:
                                    AppTypography.title().copyWith(fontSize: 22),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${tracking.username} · joined Sep 2026',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: AppTypography.caption(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  'Level ${info.level} · ${stage.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption(
                                    color: AppColors.primaryAccent,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ScrolaCard(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ProfileMetric(
                                    value: '${tracking.xpTotal}',
                                    label: 'XP',
                                  ),
                                ),
                                const VerticalDivider(
                                  color: AppColors.borderSubtle,
                                  width: 1,
                                ),
                                Expanded(
                                  child: _ProfileMetric(
                                    value: '${tracking.streakDays}',
                                    label: 'Day streak',
                                  ),
                                ),
                                const VerticalDivider(
                                  color: AppColors.borderSubtle,
                                  width: 1,
                                ),
                                const Expanded(
                                  child: _ProfileMetric(
                                    value: '12',
                                    label: 'Badges',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ScrolaCard(
                          padding: const EdgeInsets.all(18),
                          borderColor:
                              AppColors.primaryAccent.withValues(alpha: 0.45),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryAccent.withValues(alpha: 0.22),
                              AppColors.surfaceSolid,
                            ],
                          ),
                          onTap: () {
                            HapticService.light();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SubscriptionProScreen(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: AppColors.textOnAccent,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scrola Pro',
                                      style: AppTypography.subheading()
                                          .copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Monthly reports and more skins',
                                      style: AppTypography.caption(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'See plans',
                                  style: AppTypography.caption(
                                    color: AppColors.textOnAccent,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ScrolaCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          child: Column(
                            children: [
                              _MenuRow(
                                icon: Icons.notifications_none_rounded,
                                title: 'Notifications',
                                trailing: 'On',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const NotificationsSettingsScreen(),
                                  ),
                                ),
                              ),
                              const Divider(
                                  color: AppColors.borderSubtle, height: 1),
                              _MenuRow(
                                icon: Icons.settings_outlined,
                                title: 'Settings',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                ),
                              ),
                              const Divider(
                                  color: AppColors.borderSubtle, height: 1),
                              _MenuRow(
                                icon: Icons.help_outline_rounded,
                                title: 'Help and feedback',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Support: hello@scrola.app'),
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                  color: AppColors.borderSubtle, height: 1),
                              _MenuRow(
                                icon: Icons.info_outline_rounded,
                                title: 'About Scrola',
                                trailing: 'v0.2',
                                onTap: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: AppColors.cardSurface,
                                      title: const Text('Scrola v0.2'),
                                      content: const Text(
                                        'Mindful short-video counter and Brainy companion.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _SettingsBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.subtle();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceSolid,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Icon(
          Icons.settings_outlined,
          color: AppColors.primaryText,
          size: 20,
        ),
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: AppTypography.numeric(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.caption(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticService.subtle();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryAccent, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTypography.subheading().copyWith(fontSize: 15),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              Text(
                trailing!,
                style: AppTypography.caption(color: AppColors.secondaryText),
              ),
            ],
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

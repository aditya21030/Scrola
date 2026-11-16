import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import 'privacy_controls_screen.dart';
import 'terms_of_service_screen.dart';

class AboutScrolaScreen extends StatelessWidget {
  const AboutScrolaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: 'About Scrola'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 14, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero Mascot Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSolid,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.primaryAccent.withValues(alpha: 0.35),
                          ),
                          gradient: RadialGradient(
                            center: const Alignment(0, -0.4),
                            radius: 1.1,
                            colors: [
                              AppColors.primaryAccent.withValues(alpha: 0.18),
                              AppColors.surfaceSolid,
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cardSurface,
                                border: Border.all(
                                  color: AppColors.primaryAccent,
                                  width: 2.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryAccent.withValues(alpha: 0.3),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: BrainyMascot(
                                  mood: BrainyMood.happy,
                                  skin: BrainySkin.classic,
                                  size: 64,
                                  animate: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Scrola',
                              style: AppTypography.title().copyWith(fontSize: 26),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mindful Short-Video Counter & Focus Guard',
                              textAlign: TextAlign.center,
                              style: AppTypography.subheading().copyWith(
                                color: AppColors.primaryAccent,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryAccent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                'Version 1.0.0 (Build 3)',
                                style: AppTypography.caption(
                                  color: AppColors.primaryAccent,
                                ).copyWith(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Mission Statement
                      ScrolaCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: AppColors.primaryAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Our Mission',
                                  style: AppTypography.subheading().copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Infinite feeds on Instagram Reels, YouTube Shorts, and TikTok are engineered to hijack human attention. Scrola exists to restore conscious control without shame, restrictive guilt, or cold-turkey lockouts.\n\n'
                              'By keeping your daily consumption visible right at your screen notch and turning mindful restraint into an evolving Brainy companion, Scrola helps you stay present in real life.',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ).copyWith(height: 1.45),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Core Pillars
                      ScrolaCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.primaryAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'How Scrola Works',
                                  style: AppTypography.subheading().copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildFeatureRow(
                              icon: Icons.swipe_vertical_rounded,
                              title: 'Intelligent Reel Detection',
                              description:
                                  'Uses Android Accessibility to detect short-video players and vertical swipe actions in real time.',
                            ),
                            const Divider(color: AppColors.borderSubtle, height: 20),
                            _buildFeatureRow(
                              icon: Icons.nature_people_rounded,
                              title: 'Brainy Mascot Companion',
                              description:
                                  'Brainy reacts to your habits, gains XP when you stay under your daily target, and unlocks 40+ unique skins.',
                            ),
                            const Divider(color: AppColors.borderSubtle, height: 20),
                            _buildFeatureRow(
                              icon: Icons.shield_rounded,
                              title: '100% On-Device Privacy',
                              description:
                                  'Reel counts and swipes are calculated strictly in device RAM. No private messages, keystrokes, or screen recordings are ever accessed.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Legal & Links Card
                      ScrolaCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Column(
                          children: [
                            _buildNavRow(
                              icon: Icons.shield_outlined,
                              title: 'Privacy & Data Controls',
                              subtitle: 'Manage local data & review disclosures',
                              onTap: () {
                                HapticService.light();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PrivacyControlsScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(color: AppColors.borderSubtle, height: 1),
                            _buildNavRow(
                              icon: Icons.gavel_rounded,
                              title: 'Terms of Service',
                              subtitle: 'Read our full terms and conditions',
                              onTap: () {
                                HapticService.light();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const TermsOfServiceScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(color: AppColors.borderSubtle, height: 1),
                            _buildNavRow(
                              icon: Icons.email_outlined,
                              title: 'Contact Support',
                              subtitle: 'yousfulstudio@gmail.com',
                              onTap: () {
                                HapticService.subtle();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Support email: yousfulstudio@gmail.com'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Down Center Version & Publisher info
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Scrola v1.0.0 (Build 3)',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText.withValues(alpha: 0.8),
                              ).copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Designed & Crafted with ❤️ by Yousful Studio',
                              style: AppTypography.caption(
                                color: AppColors.mutedText.withValues(alpha: 0.7),
                              ).copyWith(fontSize: 11.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '© 2026 Yousful Studio · All rights reserved',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText.withValues(alpha: 0.4),
                              ).copyWith(fontSize: 10.5),
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
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryAccent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.subheading().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.caption(
                  color: AppColors.secondaryText,
                ).copyWith(height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.subheading().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
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

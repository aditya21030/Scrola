import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const String termsUrl = 'https://scrola.app/terms';

  void _copyTermsLink(BuildContext context) {
    HapticService.light();
    Clipboard.setData(const ClipboardData(text: termsUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms of Service URL copied to clipboard.'),
      ),
    );
  }

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
              ScrolaAppBar(
                title: 'Terms of Service',
                trailing: GestureDetector(
                  onTap: () => _copyTermsLink(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link_rounded,
                          color: AppColors.primaryAccent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Copy Link',
                        style: AppTypography.caption(
                          color: AppColors.primaryAccent,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSolid,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.gavel_rounded,
                                color: AppColors.primaryAccent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scrola Terms & Conditions',
                                    style: AppTypography.subheading().copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Last updated: November 16, 2026 · Version 1.0.0 (Build 4)',
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Section 1
                      _buildSectionCard(
                        number: '1',
                        title: 'Acceptance of Terms',
                        body:
                            'By downloading, installing, or using the Scrola mobile application ("Scrola", "the App"), provided by Yousful Studio ("we", "us", or "our"), you agree to be bound by these Terms of Service. If you do not agree with any portion of these terms, please discontinue using and uninstall the App immediately.',
                      ),
                      const SizedBox(height: 14),

                      // Section 2
                      _buildSectionCard(
                        number: '2',
                        title: 'Permitted Use & Purpose',
                        body:
                            'Scrola is a personal digital wellbeing and mindful screen time companion. The App provides automated on-device short-form video tracking, focus sessions, and limit enforcement. You agree to use Scrola only for lawful, personal purposes and in compliance with all applicable local, national, and international laws.',
                      ),
                      const SizedBox(height: 14),

                      // Section 3
                      _buildSectionCard(
                        number: '3',
                        title: 'Accessibility Service & Device Permissions',
                        body:
                            'Scrola uses Android Accessibility APIs strictly to detect when supported short-form video viewers (e.g. Instagram Reels, YouTube Shorts, TikTok) enter the foreground and count vertical swipes. We do not access, monitor, log, or transmit personal messages, banking information, passwords, photos, or browsing history. You may enable or revoke this permission at any time in Android Settings > Accessibility.',
                      ),
                      const SizedBox(height: 14),

                      // Section 4
                      _buildSectionCard(
                        number: '4',
                        title: 'Subscriptions & Google Play Billing',
                        body:
                            'Scrola offers optional premium features ("Scrola Pro") including unlimited floating notch sessions, advanced analytics, and custom Brainy skins. All subscription fees and lifetime purchases are processed securely through Google Play In-App Billing.\n\n'
                            '• Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current billing cycle in your Google Play Store Account Settings.\n'
                            '• Refunds are handled exclusively under Google Play standard refund policies.\n'
                            '• Price changes will be communicated in advance in accordance with Google Play rules.',
                      ),
                      const SizedBox(height: 14),

                      // Section 5
                      _buildSectionCard(
                        number: '5',
                        title: 'Intellectual Property',
                        body:
                            'All software code, visual designs, Brainy mascot artwork, animations, sounds, trademarks, and documentation related to Scrola are the exclusive intellectual property of Yousful Studio. You may not decompile, reverse-engineer, redistribute, sell, or create derivative works from the application without prior written permission.',
                      ),
                      const SizedBox(height: 14),

                      // Section 6
                      _buildSectionCard(
                        number: '6',
                        title: 'Not Medical or Psychological Advice',
                        body:
                            'Scrola is a self-management productivity tool designed to help you become more mindful of screen time habits. Scrola is not a medical device and does not provide clinical diagnosis, psychiatric therapy, or treatment for digital addiction disorders. If you experience severe distress related to device usage, please consult a qualified healthcare professional.',
                      ),
                      const SizedBox(height: 14),

                      // Section 7
                      _buildSectionCard(
                        number: '7',
                        title: 'Disclaimer of Warranties & Limitation of Liability',
                        body:
                            'Scrola is provided on an "AS IS" and "AS AVAILABLE" basis without warranties of any kind, either express or implied. To the maximum extent permitted by law, Yousful Studio shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your access to or inability to use the App.',
                      ),
                      const SizedBox(height: 14),

                      // Section 8
                      _buildSectionCard(
                        number: '8',
                        title: 'Termination & Account Deletion',
                        body:
                            'You may stop using Scrola at any time. You can purge all local statistics or permanently delete your account and all associated cloud data directly within Settings > Privacy & Data Controls > Delete Account. We reserve the right to suspend or terminate accounts that violate these Terms.',
                      ),
                      const SizedBox(height: 14),

                      // Section 9
                      _buildSectionCard(
                        number: '9',
                        title: 'Contact Information',
                        body:
                            'If you have questions, feedback, or concerns regarding these Terms of Service, please reach out to us:\n\n'
                            '• Email: yousfulstudio@gmail.com\n'
                            '• Subject Line: Scrola App Terms\n'
                            '• Publisher: Yousful Studio',
                      ),
                      const SizedBox(height: 24),

                      // Bottom center version info
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Scrola v1.0.0 (Build 4)',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText.withValues(alpha: 0.7),
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '© 2026 Yousful Studio · All rights reserved',
                              style: AppTypography.caption(
                                color: AppColors.mutedText.withValues(alpha: 0.6),
                              ).copyWith(fontSize: 11),
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

  Widget _buildSectionCard({
    required String number,
    required String title,
    required String body,
  }) {
    return ScrolaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: AppTypography.caption(
                    color: AppColors.primaryAccent,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.subheading().copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: AppTypography.caption(
              color: AppColors.secondaryText,
            ).copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../screens/create_account_screen.dart';
import '../screens/login_screen.dart';

class RegistrationPromptModal extends StatelessWidget {
  const RegistrationPromptModal({super.key});

  static Future<void> show(BuildContext context) {
    HapticService.subtle();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RegistrationPromptModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.secondaryText.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Glowing Brainy Mascot
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryAccent.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                BrainyMascot(
                  mood: BrainyMood.excited,
                  size: 88,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Titles
          Text(
            'Save your streak & progress',
            textAlign: TextAlign.center,
            style: AppTypography.title().copyWith(
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a free account to back up your Brainy evolutions, unlock skins across devices, and join friend battles.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              color: AppColors.secondaryText,
            ).copyWith(height: 1.4),
          ),
          const SizedBox(height: 24),

          // Primary: Create Account
          ScrolaPrimaryButton(
            label: 'Create free account',
            useMediumHaptic: true,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateAccountScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Secondary: Log in
          ScrolaSecondaryButton(
            label: 'Already have an account? Log in',
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Guest mode bypass
          Center(
            child: TextButton(
              onPressed: () {
                HapticService.light();
                AuthService().signInAsGuest();
                Navigator.of(context).pop();
              },
              child: Text(
                'Continue as Guest',
                style: AppTypography.caption(
                  color: AppColors.secondaryText,
                ).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

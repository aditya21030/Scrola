import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_text_field.dart';
import '../../../../core/services/gamification_engine.dart';
import 'check_your_email_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _auth = AuthService();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email or username');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      HapticService.light();
      await _auth.sendPasswordReset(email);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CheckYourEmailScreen(email: email),
          ),
        );
      }
    } catch (e) {
      // In offline / preview fallback:
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CheckYourEmailScreen(email: email),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Forgot your password?',
                          style: AppTypography.title().copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter your email or username. We'll send a reset link to the email on that account.",
                          style: AppTypography.body(
                            color: AppColors.secondaryText,
                          ).copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const BrainyMascot(
                    mood: BrainyMood.neutral,
                    skin: BrainySkin.classic,
                    size: 80,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ScrolaTextField(
                controller: _emailController,
                label: 'Email or username',
                hintText: 'alex.scrolls or name@email.com',
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.secondaryText,
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                errorText: _error,
              ),
              const SizedBox(height: 20),
              ScrolaPrimaryButton(
                label: _isLoading ? 'Sending...' : 'Send reset link',
                onTap: _isLoading ? null : _handleSendResetLink,
              ),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: () {
                    HapticService.subtle();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Back to log in',
                    style: AppTypography.subheading(color: AppColors.primaryAccent)
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "If an account exists, you'll get an email within a minute.",
                textAlign: TextAlign.center,
                style: AppTypography.caption(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

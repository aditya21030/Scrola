import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_text_field.dart';
import 'password_updated_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_newPasswordController.text);
  bool get _hasSymbol =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_newPasswordController.text);

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasNumber) score++;
    if (_hasSymbol) score++;
    if (_newPasswordController.text.length >= 12) score++;
    return score;
  }

  String get _strengthLabel {
    final s = _strengthScore;
    if (s <= 1) return 'Weak';
    if (s <= 2) return 'Fair';
    if (s <= 3) return 'Good';
    return 'Strong';
  }

  Color get _strengthColor {
    final s = _strengthScore;
    if (s <= 1) return AppColors.error;
    if (s <= 2) return AppColors.warning;
    return AppColors.success;
  }

  bool get _passwordsMatch =>
      _newPasswordController.text.isNotEmpty &&
      _newPasswordController.text == _confirmPasswordController.text;

  Future<void> _handleUpdatePassword() async {
    if (!_hasMinLength || !_hasNumber || !_hasSymbol) {
      setState(() => _error = 'Please satisfy all password requirements');
      return;
    }

    if (!_passwordsMatch) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    HapticService.medium();
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PasswordUpdatedScreen()),
        (route) => false,
      );
    }
  }

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
                          'Set a new password',
                          style: AppTypography.title().copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Make it one you haven't used before.",
                          style: AppTypography.body(
                            color: AppColors.secondaryText,
                          ).copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const BrainyMascot(
                    mood: BrainyMood.focused,
                    skin: BrainySkin.classic,
                    size: 80,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ScrolaTextField(
                controller: _newPasswordController,
                label: 'New password',
                hintText: '••••••••',
                obscureText: _obscureNew,
                onChanged: (_) => setState(() {}),
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.secondaryText,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              if (_newPasswordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(4, (index) {
                          final active = index < _strengthScore;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 4,
                              decoration: BoxDecoration(
                                color: active
                                    ? _strengthColor
                                    : const Color(0xFF333333),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _strengthLabel,
                      style: AppTypography.caption(color: _strengthColor)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              ScrolaTextField(
                controller: _confirmPasswordController,
                label: 'Confirm password',
                hintText: '••••••••',
                obscureText: _obscureConfirm,
                onChanged: (_) => setState(() {}),
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.secondaryText,
                ),
                suffixIcon: _passwordsMatch
                    ? Container(
                        margin: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 14, color: Color(0xFF101010)),
                      )
                    : IconButton(
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.secondaryText,
                        ),
                      ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: AppTypography.caption(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReqItem(
                    satisfied: _hasMinLength,
                    label: 'At least 8 characters',
                  ),
                  const SizedBox(height: 8),
                  _ReqItem(
                    satisfied: _hasNumber,
                    label: 'At least one number',
                  ),
                  const SizedBox(height: 8),
                  _ReqItem(
                    satisfied: _hasSymbol,
                    label: 'At least one special symbol',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ScrolaPrimaryButton(
                label: _isLoading ? 'Updating...' : 'Update password',
                onTap: _isLoading ? null : _handleUpdatePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReqItem extends StatelessWidget {
  final bool satisfied;
  final String label;

  const _ReqItem({required this.satisfied, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: satisfied ? AppColors.success : const Color(0xFF2E2E2E),
            shape: BoxShape.circle,
          ),
          child: Icon(
            satisfied ? Icons.check : Icons.circle,
            size: satisfied ? 12 : 5,
            color: satisfied
                ? AppColors.primaryBackground
                : AppColors.secondaryText,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.body(
            color: satisfied ? Colors.white : AppColors.secondaryText,
          ).copyWith(fontSize: 13.5),
        ),
      ],
    );
  }
}

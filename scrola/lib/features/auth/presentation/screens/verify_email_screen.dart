import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 45;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCountdown = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendCountdown <= 1) {
        t.cancel();
        setState(() => _resendCountdown = 0);
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2) return widget.email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 1) return '$name•••••@$domain';
    return '${name[0]}•••••@$domain';
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    final code = _code;
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits');
      await HapticService.warning();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // For test or standard verification
    if (code == '123456' || code == '482910') {
      await HapticService.celebratory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      // Wrong code state (Screen 103)
      setState(() {
        _isLoading = false;
        _errorMessage = 'That code is incorrect or expired. Try again.';
      });
      await HapticService.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCodeComplete = _code.length == 6;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScrolaAppBar(title: ''),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enter the\n6 digit code',
                                  style: AppTypography.title().copyWith(
                                    fontSize: 32,
                                    height: 1.18,
                                    letterSpacing: -0.7,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    text: 'We sent it to ',
                                    style: AppTypography.body(
                                      color: AppColors.secondaryText,
                                      size: 15,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _maskedEmail,
                                        style: AppTypography.body(
                                          color: AppColors.primaryText,
                                          size: 15,
                                        ).copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BrainyMascot(
                            mood: _errorMessage != null
                                ? BrainyMood.tired
                                : BrainyMood.happy,
                            size: 88,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // 6 digit code inputs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          final isFocused = _focusNodes[index].hasFocus;
                          final hasValue = _controllers[index].text.isNotEmpty;
                          final isErr = _errorMessage != null;

                          return Container(
                            width: 48,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSolid,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isErr
                                    ? AppColors.error
                                    : isFocused
                                        ? AppColors.primaryAccent
                                        : hasValue
                                            ? AppColors.borderSubtle
                                            : AppColors.borderSubtle,
                                width: isFocused ? 2 : 1,
                              ),
                              boxShadow: isFocused
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryAccent
                                            .withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: AppTypography.title().copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isErr
                                    ? AppColors.error
                                    : AppColors.primaryText,
                              ),
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) {
                                if (val.isNotEmpty) {
                                  HapticService.subtle();
                                  if (index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else {
                                    _focusNodes[index].unfocus();
                                  }
                                } else {
                                  if (index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                }
                                setState(() {
                                  _errorMessage = null;
                                });
                              },
                            ),
                          );
                        }),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.caption(
                                  color: AppColors.error,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_resendCountdown > 0)
                            Text(
                              'Resend code in 0:${_resendCountdown.toString().padLeft(2, '0')}',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () {
                                HapticService.light();
                                _startCountdown();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Verification code resent.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Text(
                                'Resend code now',
                                style: AppTypography.caption(
                                  color: AppColors.primaryAccent,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          GestureDetector(
                            onTap: () {
                              HapticService.subtle();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Wrong email?',
                              style: AppTypography.caption(
                                color: AppColors.primaryAccent,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ScrolaPrimaryButton(
                label: _isLoading ? 'Verifying...' : 'Verify',
                onPressed:
                    isCodeComplete && !_isLoading ? _handleVerify : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

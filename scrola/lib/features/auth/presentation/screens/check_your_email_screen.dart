import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import 'reset_password_screen.dart';

class CheckYourEmailScreen extends StatefulWidget {
  final String email;

  const CheckYourEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<CheckYourEmailScreen> createState() => _CheckYourEmailScreenState();
}

class _CheckYourEmailScreenState extends State<CheckYourEmailScreen> {
  int _secondsRemaining = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 45;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '$name••••@$domain';
    return '${name[0]}••••${name[name.length - 1]}@$domain';
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
              const SizedBox(height: 36),
              Center(
                child: SizedBox(
                  width: 220,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Brainy peeking out of envelope
                      const Positioned(
                        top: 0,
                        child: BrainyMascot(
                          mood: BrainyMood.happy,
                          skin: BrainySkin.classic,
                          size: 110,
                        ),
                      ),
                      // Envelope
                      Container(
                        width: 210,
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFF242424),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF3A3A3A),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _EnvelopePainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Check your inbox',
                textAlign: TextAlign.center,
                style: AppTypography.title().copyWith(fontSize: 30),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTypography.body(color: AppColors.secondaryText)
                      .copyWith(fontSize: 14.5, height: 1.4),
                  children: [
                    const TextSpan(text: 'We sent a reset link to '),
                    TextSpan(
                      text: _formatEmail(widget.email),
                      style: AppTypography.body(color: Colors.white)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: '. It works for 30 minutes.'),
                  ],
                ),
              ),
              const Spacer(),
              ScrolaPrimaryButton(
                label: 'Open email app',
                onTap: () {
                  HapticService.medium();
                  // Simulate link click / deep link by offering direct password reset
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResetPasswordScreen(email: widget.email),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secondsRemaining > 0
                        ? 'Resend link in '
                        : 'Didn\'t get it? ',
                    style: AppTypography.caption(color: AppColors.secondaryText)
                        .copyWith(fontSize: 13.5),
                  ),
                  if (_secondsRemaining > 0)
                    Text(
                      '0:${_secondsRemaining.toString().padLeft(2, '0')}',
                      style: AppTypography.numeric(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        HapticService.light();
                        _startTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reset link resent!')),
                        );
                      },
                      child: Text(
                        'Resend now',
                        style: AppTypography.caption(
                          color: AppColors.primaryAccent,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.caption(color: AppColors.secondaryText),
                      children: [
                        const TextSpan(text: 'Nothing there? Check spam, or '),
                        TextSpan(
                          text: 'use another email',
                          style: AppTypography.caption(
                            color: AppColors.primaryAccent,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3A3A3A)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(6, 12)
      ..lineTo(size.width / 2, size.height * 0.65)
      ..lineTo(size.width - 6, 12);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

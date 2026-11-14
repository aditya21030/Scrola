import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../../shared/widgets/scrola_card.dart';

class GoogleSignInUsernameScreen extends StatefulWidget {
  final String email;
  final String? initialDisplayName;

  const GoogleSignInUsernameScreen({
    super.key,
    required this.email,
    this.initialDisplayName,
  });

  @override
  State<GoogleSignInUsernameScreen> createState() =>
      _GoogleSignInUsernameScreenState();
}

class _GoogleSignInUsernameScreenState
    extends State<GoogleSignInUsernameScreen> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TrackingService _tracking = TrackingService();

  late final List<String> _suggestions;
  bool _isChecking = false;
  bool _isAvailable = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final base = widget.email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9._]'), '');
    _usernameCtrl.text = base;
    _suggestions = [
      '$base.less',
      '${base}_${DateTime.now().year}',
      '$base.scrola',
    ];
    _usernameCtrl.addListener(_onUsernameChanged);
  }

  void _onUsernameChanged() {
    final text = _usernameCtrl.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isAvailable = false;
        _error = 'Username cannot be empty';
      });
      return;
    }
    if (text.length < 3 || text.length > 20) {
      setState(() {
        _isAvailable = false;
        _error = 'Username must be 3 to 20 characters';
      });
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(text)) {
      setState(() {
        _isAvailable = false;
        _error = 'Letters, numbers, dots and underscores only';
      });
      return;
    }

    setState(() {
      _isAvailable = true;
      _error = null;
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final username = _usernameCtrl.text.trim().replaceAll('@', '');
    if (!_isAvailable || username.isEmpty) {
      await HapticService.warning();
      return;
    }

    setState(() => _isChecking = true);
    await HapticService.celebratory();
    await _tracking.updateProfile(
      username: username,
      displayName: widget.initialDisplayName ?? username,
      email: widget.email,
    );

    if (!mounted) return;
    Navigator.of(context).pop(username);
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
              const ScrolaAppBar(title: ''),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Google Account Badge Card
                      ScrolaCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4285F4),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                widget.email.isNotEmpty
                                    ? widget.email[0].toUpperCase()
                                    : 'G',
                                style: AppTypography.title().copyWith(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.email,
                                    style: AppTypography.caption(
                                      color: AppColors.primaryText,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 13,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Signed in with Google',
                                        style: AppTypography.caption(
                                          color: AppColors.secondaryText,
                                          size: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Header with Mascot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'One last thing',
                                  style: AppTypography.title().copyWith(
                                    fontSize: 32,
                                    letterSpacing: -0.7,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Choose your Scrola username. Friends find you with it.',
                                  style: AppTypography.body(
                                    color: AppColors.secondaryText,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const BrainyMascot(
                            mood: BrainyMood.happy,
                            size: 88,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Username field
                      Text(
                        'USERNAME',
                        style: AppTypography.caption(
                          color: AppColors.secondaryText,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSolid,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _error != null
                                ? AppColors.error
                                : _isAvailable
                                    ? AppColors.success
                                    : AppColors.borderSubtle,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.alternate_email_rounded,
                              size: 18,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _usernameCtrl,
                                style: AppTypography.body(
                                  color: AppColors.primaryText,
                                  size: 15,
                                ).copyWith(fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: 'alex.scrolls',
                                  hintStyle: TextStyle(
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ),
                            ),
                            if (_isAvailable && _error == null)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: AppColors.primaryBackground,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (_error != null)
                        Text(
                          _error!,
                          style: AppTypography.caption(
                            color: AppColors.error,
                            size: 12,
                          ),
                        )
                      else if (_isAvailable)
                        Text(
                          '${_usernameCtrl.text} is available',
                          style: AppTypography.caption(
                            color: AppColors.success,
                            size: 12,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        '3 to 20 characters. Letters, numbers, dots and underscores.',
                        style: AppTypography.caption(
                          color: AppColors.secondaryText,
                          size: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _suggestions.map((sug) {
                          return GestureDetector(
                            onTap: () {
                              HapticService.subtle();
                              _usernameCtrl.text = sug;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primaryAccent
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                sug,
                                style: AppTypography.caption(
                                  color: AppColors.accentHighlight,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              ScrolaPrimaryButton(
                label: _isChecking ? 'Saving...' : 'Continue',
                onPressed:
                    _isAvailable && !_isChecking ? _handleContinue : null,
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'You can change it later in Edit profile.',
                  style: AppTypography.caption(
                    color: AppColors.mutedText,
                    size: 12,
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

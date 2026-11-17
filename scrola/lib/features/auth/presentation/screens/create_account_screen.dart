import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_buttons.dart';
import '../../../profile/presentation/screens/privacy_controls_screen.dart';
import 'login_screen.dart';

enum UsernameStatus {
  idle,
  checking,
  available,
  taken,
  tooShort,
  invalid,
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  Timer? _debounceTimer;
  UsernameStatus _usernameStatus = UsernameStatus.idle;
  String? _usernameFeedback;
  List<String> _suggestions = const [];
  bool _userEditedUsernameManually = false;

  bool _obscurePassword = true;
  bool _agreedToTerms = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onNameOrEmailChanged);
    _emailCtrl.addListener(_onNameOrEmailChanged);
    _usernameCtrl.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameCtrl.removeListener(_onNameOrEmailChanged);
    _emailCtrl.removeListener(_onNameOrEmailChanged);
    _usernameCtrl.removeListener(_onUsernameChanged);
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onNameOrEmailChanged() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    String base = '';
    if (name.isNotEmpty) {
      base = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    } else if (email.isNotEmpty && email.contains('@')) {
      base = email.split('@').first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    }

    if (base.isEmpty) {
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = const []);
      }
      return;
    }

    final year = DateTime.now().year.toString().substring(2);
    final candidates = [
      if (base.length >= 3) base,
      if (base.length < 3) '${base}01',
      '${base}_$year',
      '$base.scrolls',
      if (base.length >= 3) '${base}01' else '${base}_app',
    ];

    final unique = candidates.toSet().where((s) => s.length >= 3).take(4).toList();

    setState(() {
      _suggestions = unique;
      if (!_userEditedUsernameManually && _usernameCtrl.text.isEmpty && unique.isNotEmpty) {
        _usernameCtrl.text = unique.first;
        _checkUsernameAvailability(unique.first);
      }
    });
  }

  void _onUsernameChanged() {
    final text = _usernameCtrl.text.trim();
    final clean = text.replaceAll('@', '').replaceAll(' ', '').toLowerCase();

    _debounceTimer?.cancel();

    if (clean.isEmpty) {
      setState(() {
        _usernameStatus = UsernameStatus.idle;
        _usernameFeedback = null;
      });
      return;
    }

    if (clean.length < 3) {
      setState(() {
        _usernameStatus = UsernameStatus.tooShort;
        _usernameFeedback = 'Username must have at least 3 letters';
      });
      return;
    }

    if (clean.length > 20) {
      setState(() {
        _usernameStatus = UsernameStatus.invalid;
        _usernameFeedback = 'Username cannot exceed 20 characters';
      });
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(clean)) {
      setState(() {
        _usernameStatus = UsernameStatus.invalid;
        _usernameFeedback = 'Letters, numbers, dots and underscores only';
      });
      return;
    }

    setState(() {
      _usernameStatus = UsernameStatus.checking;
      _usernameFeedback = 'Checking availability...';
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _checkUsernameAvailability(clean);
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    final clean = username.trim().toLowerCase().replaceAll('@', '').replaceAll(' ', '');
    if (clean.length < 3) return;

    try {
      final isTaken = await _auth.isUsernameTaken(clean);
      if (!mounted) return;
      final current = _usernameCtrl.text.trim().toLowerCase().replaceAll('@', '').replaceAll(' ', '');
      if (current != clean) return;

      setState(() {
        if (isTaken) {
          _usernameStatus = UsernameStatus.taken;
          _usernameFeedback = '@$clean is already taken';
        } else {
          _usernameStatus = UsernameStatus.available;
          _usernameFeedback = '@$clean is available';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _usernameStatus = UsernameStatus.available;
        _usernameFeedback = '@$clean is available';
      });
    }
  }

  void _selectSuggestion(String sug) {
    HapticService.subtle();
    _userEditedUsernameManually = true;
    _usernameCtrl.text = sug;
    _checkUsernameAvailability(sug);
  }

  Future<void> _handleRegister() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final name = _nameCtrl.text.trim();
    final username =
        _usernameCtrl.text.trim().replaceAll('@', '').replaceAll(' ', '').toLowerCase();

    if (username.isEmpty) {
      setState(() => _error = 'Please enter a username');
      await HapticService.warning();
      return;
    }
    if (username.length < 3) {
      setState(() => _error = 'Username must have at least 3 letters');
      await HapticService.warning();
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
      setState(() => _error = 'Letters, numbers, dots and underscores only');
      await HapticService.warning();
      return;
    }
    if (_usernameStatus == UsernameStatus.taken) {
      setState(() => _error = 'Username @$username is already taken. Please choose another.');
      await HapticService.warning();
      return;
    }
    if (_usernameStatus == UsernameStatus.checking) {
      setState(() => _error = 'Checking username availability, please wait...');
      await HapticService.warning();
      return;
    }

    if (email.isEmpty) {
      setState(() => _error = 'Please enter an email address');
      await HapticService.warning();
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      await HapticService.warning();
      return;
    }
    if (!_agreedToTerms) {
      setState(() => _error = 'Please agree to the Terms & Privacy Policy');
      await HapticService.warning();
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final err = await _auth.createAccountWithEmail(
        email: email,
        password: pass,
        displayName: name.isNotEmpty ? name : null,
        username: username,
      );

      if (!mounted) return;

      if (err != null) {
        setState(() {
          _error = err;
        });
        await HapticService.error();
      } else {
        await HapticService.celebratory();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Welcome to Scrola.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Registration error: $e');
        await HapticService.error();
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleSaveLocally() async {
    final name = _nameCtrl.text.trim();
    final username =
        _usernameCtrl.text.trim().replaceAll('@', '').replaceAll(' ', '').toLowerCase();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.isNotEmpty ? _passCtrl.text : 'scrola123';

    if (username.isEmpty) {
      setState(() => _error = 'Please enter a username');
      await HapticService.warning();
      return;
    }
    if (username.length < 3) {
      setState(() => _error = 'Username must have at least 3 letters');
      await HapticService.warning();
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
      setState(() => _error = 'Letters, numbers, dots and underscores only');
      await HapticService.warning();
      return;
    }
    if (_usernameStatus == UsernameStatus.taken) {
      setState(() => _error = 'Username @$username is already taken. Please choose another.');
      await HapticService.warning();
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final storage = await StorageService.getInstance();
      await storage.saveLocalAccount(
        email: email.isNotEmpty ? email : '$username@scrola.local',
        password: pass,
        displayName: name.isNotEmpty ? name : 'Scrola User',
        username: username,
      );
      await _auth.initialize();
      await HapticService.celebratory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account saved! Welcome to Scrola.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Error saving account: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleContinueAsGuest() async {
    HapticService.light();
    await _auth.signInAsGuest();
    if (!mounted) return;
    Navigator.of(context).pop(true);
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with Mascot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create your account',
                                  style: AppTypography.title().copyWith(
                                    fontSize: 26,
                                    letterSpacing: -0.6,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Pick a username friends can find. Save your streak forever.',
                                  style: AppTypography.body(
                                    color: AppColors.secondaryText,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          BrainyMascot(
                            mood: BrainyMood.excited,
                            size: 84,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: AppTypography.caption(
                                        color: AppColors.error,
                                      ).copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_error!.contains('Firebase') ||
                                  _error!.contains('CONFIGURATION_NOT_FOUND') ||
                                  _error!.contains('Guest') ||
                                  _error!.contains('locally')) ...[
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: _handleSaveLocally,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 11),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAccent
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primaryAccent
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 17,
                                          color: AppColors.primaryAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Save Details Locally as Guest',
                                          style: AppTypography.caption(
                                            color: AppColors.primaryAccent,
                                            weight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Display name input
                      Text(
                        'DISPLAY NAME',
                        style: AppTypography.label(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.next,
                          style: AppTypography.body(color: AppColors.primaryText)
                              .copyWith(fontWeight: FontWeight.w600),
                          cursorColor: AppColors.primaryAccent,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: 'e.g. Alex Scrolls',
                            hintStyle: TextStyle(color: AppColors.secondaryText),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Username input
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'USERNAME',
                            style: AppTypography.label(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          if (_usernameStatus == UsernameStatus.available)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Available',
                                  style: AppTypography.caption(
                                    color: AppColors.success,
                                  ).copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          else if (_usernameStatus == UsernameStatus.taken)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cancel_rounded,
                                  size: 14,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Taken',
                                  style: AppTypography.caption(
                                    color: AppColors.error,
                                  ).copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          else if (_usernameStatus == UsernameStatus.checking)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: AppColors.primaryAccent,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Checking...',
                                  style: AppTypography.caption(
                                    color: AppColors.primaryAccent,
                                  ).copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _usernameStatus == UsernameStatus.available
                                ? AppColors.success
                                : (_usernameStatus == UsernameStatus.taken ||
                                        _usernameStatus == UsernameStatus.tooShort ||
                                        _usernameStatus == UsernameStatus.invalid)
                                    ? AppColors.error
                                    : _usernameStatus == UsernameStatus.checking
                                        ? AppColors.primaryAccent
                                        : AppColors.border,
                            width: (_usernameStatus == UsernameStatus.available ||
                                    _usernameStatus == UsernameStatus.taken)
                                ? 1.5
                                : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Text(
                              '@',
                              style: AppTypography.body(
                                color: _usernameStatus == UsernameStatus.available
                                    ? AppColors.success
                                    : AppColors.secondaryText,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: TextField(
                                controller: _usernameCtrl,
                                textInputAction: TextInputAction.next,
                                onChanged: (_) => _userEditedUsernameManually = true,
                                style: AppTypography.body(
                                  color: AppColors.primaryText,
                                ).copyWith(fontWeight: FontWeight.w600),
                                cursorColor: AppColors.primaryAccent,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: 'your_username',
                                  hintStyle:
                                      TextStyle(color: AppColors.secondaryText),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_usernameStatus == UsernameStatus.checking)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryAccent,
                                ),
                              )
                            else if (_usernameStatus == UsernameStatus.available)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 20,
                              )
                            else if (_usernameStatus == UsernameStatus.taken ||
                                _usernameStatus == UsernameStatus.tooShort ||
                                _usernameStatus == UsernameStatus.invalid)
                              const Icon(
                                Icons.cancel_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Feedback / requirements line
                      if (_usernameFeedback != null)
                        Text(
                          _usernameFeedback!,
                          style: AppTypography.caption(
                            color: _usernameStatus == UsernameStatus.available
                                ? AppColors.success
                                : _usernameStatus == UsernameStatus.checking
                                    ? AppColors.secondaryText
                                    : AppColors.error,
                          ).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          'At least 3 letters (letters, numbers, dots and underscores)',
                          style: AppTypography.caption(
                            color: AppColors.secondaryText,
                          ).copyWith(fontSize: 11.5),
                        ),

                      // Smart suggestions chips
                      if (_suggestions.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: AppColors.primaryAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Suggested for you:',
                              style: AppTypography.caption(
                                color: AppColors.secondaryText,
                              ).copyWith(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _suggestions.map((sug) {
                            final isCurrent =
                                _usernameCtrl.text.trim().toLowerCase() ==
                                    sug.toLowerCase();
                            return GestureDetector(
                              onTap: () => _selectSuggestion(sug),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppColors.primaryAccent
                                          .withValues(alpha: 0.22)
                                      : AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCurrent
                                        ? AppColors.primaryAccent
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  '@$sug',
                                  style: AppTypography.caption(
                                    color: isCurrent
                                        ? AppColors.primaryAccent
                                        : AppColors.primaryText,
                                  ).copyWith(
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Email input
                      Text(
                        'EMAIL',
                        style: AppTypography.label(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: AppTypography.body(color: AppColors.primaryText)
                              .copyWith(fontWeight: FontWeight.w600),
                          cursorColor: AppColors.primaryAccent,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: 'alex@example.com',
                            hintStyle: TextStyle(color: AppColors.secondaryText),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password input
                      Text(
                        'PASSWORD',
                        style: AppTypography.label(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passCtrl,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleRegister(),
                                style: AppTypography.body(
                                  color: AppColors.primaryText,
                                ).copyWith(fontWeight: FontWeight.w600),
                                cursorColor: AppColors.primaryAccent,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: 'At least 6 characters',
                                  hintStyle:
                                      TextStyle(color: AppColors.secondaryText),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.secondaryText,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Terms agreement checkbox
                      GestureDetector(
                        onTap: () {
                          HapticService.subtle();
                          setState(() => _agreedToTerms = !_agreedToTerms);
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _agreedToTerms
                                    ? AppColors.primaryAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _agreedToTerms
                                      ? AppColors.primaryAccent
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: _agreedToTerms
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 15,
                                      color: AppColors.textOnAccent,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticService.subtle();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PrivacyControlsScreen(),
                                    ),
                                  );
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: AppTypography.caption(
                                          color: AppColors.primaryAccent,
                                        ).copyWith(
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: ' & '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: AppTypography.caption(
                                          color: AppColors.primaryAccent,
                                        ).copyWith(
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      ScrolaPrimaryButton(
                        label: _loading ? 'Creating...' : 'Create account',
                        useMediumHaptic: true,
                        onPressed: _loading ? null : _handleRegister,
                      ),
                      const SizedBox(height: 18),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            HapticService.subtle();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: AppTypography.body(
                                color: AppColors.secondaryText,
                              ).copyWith(fontSize: 14.5),
                              children: const [
                                TextSpan(
                                  text: 'Log in',
                                  style: TextStyle(
                                    color: AppColors.primaryAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: GestureDetector(
                          onTap: _handleContinueAsGuest,
                          child: Text(
                            'Continue as Guest (Skip)',
                            style: AppTypography.caption(
                              color: AppColors.secondaryText,
                            ).copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.secondaryText,
                            ),
                          ),
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
}

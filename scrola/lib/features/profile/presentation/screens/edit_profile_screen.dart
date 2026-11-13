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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TrackingService _tracking = TrackingService();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late BrainySkin _selectedSkin;
  String? _nameError;
  String? _usernameError;
  String? _emailError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _tracking.displayName);
    _usernameCtrl = TextEditingController(text: _tracking.username);
    _emailCtrl = TextEditingController(text: _tracking.email);
    final currentSkin = _tracking.equippedSkin;
    final reqLevel = GamificationEngine.unlockLevelForSkin(currentSkin);
    _selectedSkin =
        _tracking.currentLevel >= reqLevel ? currentSkin : BrainySkin.classic;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    final name = _nameCtrl.text.trim();
    final username =
        _usernameCtrl.text.trim().replaceAll('@', '').replaceAll(' ', '');
    final email = _emailCtrl.text.trim();

    String? nameErr;
    String? usernameErr;
    String? emailErr;

    if (name.isEmpty) {
      nameErr = 'Display name cannot be empty';
    }
    if (username.isEmpty) {
      usernameErr = 'Username cannot be empty';
    }
    if (email.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      emailErr = 'Enter a valid email address';
    }

    if (nameErr != null || usernameErr != null || emailErr != null) {
      setState(() {
        _nameError = nameErr;
        _usernameError = usernameErr;
        _emailError = emailErr;
      });
      await HapticService.error();
      return;
    }

    _saving = true;
    try {
      await _tracking.updateProfile(
        displayName: name,
        username: username,
        email: email,
      );
      final skinReq = GamificationEngine.unlockLevelForSkin(_selectedSkin);
      if (_tracking.currentLevel >= skinReq &&
          _selectedSkin != _tracking.equippedSkin) {
        await _tracking.equipSkin(_selectedSkin);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      _saving = false;
    }
  }

  Widget _buildSkinCard(BuildContext context, BrainySkin skin) {
    final reqLevel = GamificationEngine.unlockLevelForSkin(skin);
    final isUnlocked = _tracking.currentLevel >= reqLevel;
    final selected = isUnlocked && _selectedSkin == skin;
    final label = skin.name[0].toUpperCase() + skin.name.substring(1);
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.72,
      child: ScrolaSelectableCard(
        isSelected: selected,
        checkPosition: ScrolaCheckPosition.topRight,
        checkBadgeSize: 15,
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        onTap: () {
          if (!isUnlocked) {
            HapticService.warning();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    'Unlock $label Brainy at Level $reqLevel.',
                  ),
                ),
              );
            return;
          }
          HapticService.subtle();
          setState(() => _selectedSkin = skin);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: BrainyMascot(
                  mood: BrainyMood.happy,
                  skin: skin,
                  size: 36,
                  animate: false,
                  silhouette: !isUnlocked,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: AppTypography.caption(
                  color: selected
                      ? AppColors.primaryText
                      : AppColors.secondaryText,
                ).copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isUnlocked ? 'Unlocked' : 'Lv $reqLevel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption(
                color: isUnlocked
                    ? AppColors.primaryAccent
                    : AppColors.secondaryText,
              ).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Edit profile',
                    trailing: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticService.medium();
                        _save();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Text(
                          'Save',
                          style: AppTypography.caption(
                                  color: AppColors.primaryAccent)
                              .copyWith(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          Center(
                            child: Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primaryAccent
                                        .withValues(alpha: 0.25),
                                    AppColors.surfaceSolid,
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.primaryAccent
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Center(
                                child: BrainyMascot(
                                  mood: BrainyMood.happy,
                                  skin: _selectedSkin,
                                  size: 84,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'BRAINY SKIN',
                            style: AppTypography.label(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.82,
                            children: [
                              for (final skin in BrainySkin.values)
                                _buildSkinCard(context, skin),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _FieldBlock(
                            label: 'DISPLAY NAME',
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            errorText: _nameError,
                            onChanged: (_) {
                              if (_nameError != null) {
                                setState(() => _nameError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _FieldBlock(
                            label: 'USERNAME',
                            controller: _usernameCtrl,
                            prefixText: '@',
                            textInputAction: TextInputAction.next,
                            errorText: _usernameError,
                            onChanged: (_) {
                              if (_usernameError != null) {
                                setState(() => _usernameError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _FieldBlock(
                            label: 'EMAIL',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            errorText: _emailError,
                            onChanged: (_) {
                              if (_emailError != null) {
                                setState(() => _emailError = null);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ScrolaPrimaryButton(
                    label: 'Save changes',
                    useMediumHaptic: true,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? prefixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _FieldBlock({
    required this.label,
    required this.controller,
    this.prefixText,
    this.keyboardType,
    this.textInputAction,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.label(color: AppColors.secondaryText)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          style: AppTypography.body(color: AppColors.primaryText),
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixStyle:
                AppTypography.body(color: AppColors.secondaryText),
            errorText: errorText,
            errorStyle: AppTypography.caption(color: AppColors.error),
            filled: true,
            fillColor: AppColors.surfaceSolid,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.primaryAccent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

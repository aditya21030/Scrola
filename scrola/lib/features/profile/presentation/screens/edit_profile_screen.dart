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

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _tracking.displayName);
    _usernameCtrl = TextEditingController(text: _tracking.username);
    _emailCtrl = TextEditingController(text: _tracking.email);
    _selectedSkin = _tracking.equippedSkin;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    _tracking.updateProfile(
      displayName: _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim().replaceAll('@', ''),
      email: _emailCtrl.text.trim(),
    );
    _tracking.equipSkin(_selectedSkin);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const skins = [
      BrainySkin.classic,
      BrainySkin.ember,
      BrainySkin.golden,
      BrainySkin.frost,
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
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
                      style: AppTypography.caption(color: AppColors.primaryAccent)
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 15),
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
                                AppColors.primaryAccent.withValues(alpha: 0.25),
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
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0; i < skins.length; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    final skin = skins[i];
                                    final selected = _selectedSkin == skin;
                                    final label = skin.name[0].toUpperCase() +
                                        skin.name.substring(1);
                                    return ScrolaSelectableCard(
                                      isSelected: selected,
                                      checkPosition:
                                          ScrolaCheckPosition.topRight,
                                      checkBadgeSize: 16,
                                      radius: 18,
                                      padding: const EdgeInsets.fromLTRB(
                                        6,
                                        12,
                                        6,
                                        10,
                                      ),
                                      onTap: () {
                                        HapticService.subtle();
                                        setState(() => _selectedSkin = skin);
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          BrainyMascot(
                                            mood: BrainyMood.happy,
                                            skin: skin,
                                            size: 40,
                                            animate: false,
                                          ),
                                          const SizedBox(height: 6),
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
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _FieldBlock(
                        label: 'DISPLAY NAME',
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _FieldBlock(
                        label: 'USERNAME',
                        controller: _usernameCtrl,
                        prefixText: '@',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _FieldBlock(
                        label: 'EMAIL',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
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

  const _FieldBlock({
    required this.label,
    required this.controller,
    this.prefixText,
    this.keyboardType,
    this.textInputAction,
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
          style: AppTypography.body(color: AppColors.primaryText),
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixStyle:
                AppTypography.body(color: AppColors.secondaryText),
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
          ),
        ),
      ],
    );
  }
}

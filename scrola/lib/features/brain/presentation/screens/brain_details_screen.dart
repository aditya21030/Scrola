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

class BrainDetailsScreen extends StatefulWidget {
  final BrainySkin initialSkin;
  final int? requiredLevel;

  const BrainDetailsScreen({
    super.key,
    this.initialSkin = BrainySkin.classic,
    this.requiredLevel,
  });

  @override
  State<BrainDetailsScreen> createState() => _BrainDetailsScreenState();
}

class _BrainDetailsScreenState extends State<BrainDetailsScreen> {
  final TrackingService _tracking = TrackingService();
  late BrainyMood _selectedMood;

  int get _effectiveRequiredLevel =>
      widget.requiredLevel ??
      GamificationEngine.unlockLevelForSkin(widget.initialSkin);

  @override
  void initState() {
    super.initState();
    _selectedMood = _tracking.currentMood;
  }

  String _moodLabel(BrainyMood mood) =>
      mood.name[0].toUpperCase() + mood.name.substring(1);

  @override
  Widget build(BuildContext context) {
    final skinName = widget.initialSkin.name[0].toUpperCase() +
        widget.initialSkin.name.substring(1);
    final reqLevel = _effectiveRequiredLevel;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final isOwned = _tracking.currentLevel >= reqLevel;
          final isEquipped = _tracking.equippedSkin == widget.initialSkin;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(title: '$skinName Brainy'),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 210,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.primaryAccent
                                            .withValues(alpha: 0.24),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                BrainyMascot(
                                  mood: _selectedMood,
                                  skin: widget.initialSkin,
                                  size: 168,
                                  silhouette: !isOwned,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              '$skinName Brainy',
                              style: AppTypography.title().copyWith(fontSize: 24),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSolid,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderSubtle,
                                  ),
                                ),
                                child: Text(
                                  reqLevel <= 1
                                      ? 'Starter'
                                      : 'Level $reqLevel',
                                  style: AppTypography.caption(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                              if (isEquipped) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Equipped',
                                    style: AppTypography.caption(
                                      color: AppColors.success,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'MOODS',
                            style: AppTypography.label(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.78,
                            children: BrainyMood.values.map((m) {
                              final selected = _selectedMood == m;
                              return ScrolaSelectableCard(
                                isSelected: selected,
                                checkPosition: ScrolaCheckPosition.topRight,
                                checkBadgeSize: 14,
                                radius: 16,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                onTap: () {
                                  HapticService.subtle();
                                  setState(() => _selectedMood = m);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: BrainyMascot(
                                          mood: m,
                                          skin: widget.initialSkin,
                                          size: 36,
                                          animate: false,
                                          silhouette: !isOwned,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _moodLabel(m),
                                        maxLines: 1,
                                        softWrap: false,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.caption(
                                          color: selected
                                              ? AppColors.primaryText
                                              : AppColors.secondaryText,
                                        ).copyWith(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          ScrolaCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _moodLabel(_selectedMood),
                                  style: AppTypography.subheading()
                                      .copyWith(fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  GamificationEngine.moodDescription(
                                      _selectedMood),
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
                  ),
                  const SizedBox(height: 14),
                  ScrolaPrimaryButton(
                    label: isEquipped
                        ? 'Equipped'
                        : isOwned
                            ? 'Equip $skinName'
                            : 'Unlock at Level $reqLevel',
                    onPressed: !isOwned || isEquipped
                        ? null
                        : () async {
                            await HapticService.celebratory();
                            await _tracking.equipSkin(widget.initialSkin);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
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

import 'package:flutter/material.dart';
import '../../../../core/services/gamification_engine.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brainy_mascot.dart';
import '../../../../shared/widgets/scrola_app_bar.dart';
import '../../../../shared/widgets/scrola_card.dart';
import '../../../../shared/widgets/scrola_segmented_control.dart';
import 'brain_details_screen.dart';

enum _CollectionFilter { all, owned, locked }

class BrainCollectionScreen extends StatefulWidget {
  const BrainCollectionScreen({super.key});

  @override
  State<BrainCollectionScreen> createState() => _BrainCollectionScreenState();
}

class _BrainCollectionScreenState extends State<BrainCollectionScreen> {
  final TrackingService _tracking = TrackingService();
  _CollectionFilter _filter = _CollectionFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: ListenableBuilder(
        listenable: _tracking,
        builder: (context, _) {
          final currentLevel = _tracking.currentLevel;
          final skins = BrainySkin.values;
          final ownedCount = skins
              .where((s) =>
                  currentLevel >= GamificationEngine.unlockLevelForSkin(s))
              .length;

          final visible = skins.where((s) {
            final isOwned =
                currentLevel >= GamificationEngine.unlockLevelForSkin(s);
            return switch (_filter) {
              _CollectionFilter.all => true,
              _CollectionFilter.owned => isOwned,
              _CollectionFilter.locked => !isOwned,
            };
          }).toList();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScrolaAppBar(
                    title: 'Collection',
                    trailing: Text(
                      '$ownedCount / ${skins.length}',
                      style: AppTypography.numeric(
                        color: AppColors.primaryAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ScrolaSegmentedControl<_CollectionFilter>(
                    items: _CollectionFilter.values,
                    selectedItem: _filter,
                    labelBuilder: (f) => switch (f) {
                      _CollectionFilter.all => 'All',
                      _CollectionFilter.owned => 'Owned',
                      _CollectionFilter.locked => 'Locked',
                    },
                    onChanged: (f) => setState(() => _filter = f),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: visible.isEmpty
                        ? Center(
                            child: ScrolaCard(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.emoji_events_rounded,
                                    color: AppColors.primaryAccent,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _filter == _CollectionFilter.locked
                                        ? 'All Brainy skins unlocked!'
                                        : 'No skins in this filter yet.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.subheading(),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _filter == _CollectionFilter.locked
                                        ? 'Every style is ready to equip in your collection.'
                                        : 'Level up Brainy to unlock more styles.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.caption(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            itemCount: visible.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.88,
                            ),
                            itemBuilder: (context, idx) {
                              final skin = visible[idx];
                              final reqLv =
                                  GamificationEngine.unlockLevelForSkin(skin);
                              final isOwned = currentLevel >= reqLv;
                        final isEquipped = _tracking.equippedSkin == skin;
                        final name = skin.name[0].toUpperCase() +
                            skin.name.substring(1);

                        return ScrolaSelectableCard(
                          isSelected: isEquipped,
                          checkPosition: ScrolaCheckPosition.topRight,
                          onTap: () {
                            HapticService.subtle();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BrainDetailsScreen(
                                  initialSkin: skin,
                                  requiredLevel: reqLv,
                                ),
                              ),
                            );
                          },
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BrainyMascot(
                                mood: BrainyMood.happy,
                                skin: skin,
                                size: 92,
                                animate: false,
                                silhouette: !isOwned,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                name,
                                style: AppTypography.subheading()
                                    .copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isEquipped
                                      ? AppColors.primaryAccent
                                          .withValues(alpha: 0.18)
                                      : isOwned
                                          ? AppColors.successBackground
                                          : AppColors.elevatedSurface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isEquipped
                                      ? 'Equipped'
                                      : isOwned
                                          ? 'Owned'
                                          : 'Level $reqLv',
                                  style: AppTypography.caption(
                                    color: isEquipped
                                        ? AppColors.primaryAccent
                                        : isOwned
                                            ? AppColors.success
                                            : AppColors.secondaryText,
                                  ).copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
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
              ),
            ),
          );
        },
      ),
    );
  }
}

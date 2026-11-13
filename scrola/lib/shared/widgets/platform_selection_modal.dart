import 'package:flutter/material.dart';
import '../../core/services/gamification_engine.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/tracking_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'brainy_mascot.dart';
import 'platform_icon.dart';
import 'scrola_buttons.dart';
import 'scrola_card.dart';

Future<void> showPlatformSelectionModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const PlatformSelectionModal(),
  );
}

class PlatformSelectionModal extends StatefulWidget {
  const PlatformSelectionModal({super.key});

  @override
  State<PlatformSelectionModal> createState() => _PlatformSelectionModalState();
}

class _PlatformSelectionModalState extends State<PlatformSelectionModal> {
  final TrackingService _tracking = TrackingService();
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(_tracking.selectedPlatforms);
  }

  void _toggle(String id) {
    HapticService.subtle();
    setState(() {
      if (_selected.contains(id)) {
        if (_selected.length > 1) {
          _selected.remove(id);
        } else {
          HapticService.warning();
        }
      } else {
        _selected.add(id);
      }
    });
  }

  void _selectAll() {
    HapticService.light();
    setState(() {
      _selected.addAll(SocialPlatform.values.map((p) => p.id));
    });
  }

  Future<void> _save() async {
    await HapticService.celebratory();
    await _tracking.updateSelectedPlatforms(_selected.toList());
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxHeight = mq.size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tracked platforms',
                          style: AppTypography.title().copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose which short-video apps Scrola tracks & limits.',
                          style: AppTypography.caption(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  BrainyMascot(
                    mood: BrainyMood.happy,
                    size: 54,
                  ),
                ],
              ),
            ),

            // Subheader Controls (counter + select all button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.elevatedSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      '${_selected.length} of ${SocialPlatform.values.length} active',
                      style: AppTypography.caption(
                        color: AppColors.primaryAccent,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Select all',
                      style: AppTypography.caption(
                        color: AppColors.secondaryText,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Scrollable platform list
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                shrinkWrap: true,
                itemCount: SocialPlatform.values.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final platform = SocialPlatform.values[index];
                  final isSelected = _selected.contains(platform.id);

                  return ScrolaSelectableCard(
                    isSelected: isSelected,
                    onTap: () => _toggle(platform.id),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        PlatformIcon(platform: platform, size: 44),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                platform.reelsName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.subheading(),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Shorts & reels feed tracking',
                                style: AppTypography.caption(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primaryAccent
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryAccent
                                  : AppColors.border,
                              width: 1.6,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: AppColors.textOnAccent,
                                )
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Save Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: ScrolaPrimaryButton(
                label: 'Save tracked apps',
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/services/haptic_service.dart';

class ScrolaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const ScrolaBottomNav({
    super.key,
    this.currentIndex = 0,
    required this.onTabSelected,
  });

  static const _navPaths = [
    // 0: Home
    '<path d="M4 11l8-7 8 7v9a1 1 0 0 1-1 1h-4v-6h-6v6H5a1 1 0 0 1-1-1z"/>',
    // 1: Analytics / Insights
    '<path d="M5 20V11M12 20V4M19 20v-7"/>',
    // 2: Focus & Control
    '<path d="M8 4h8v5a4 4 0 0 1-8 0zM12 13v4M8 20h8M4 5h4M16 5h4"/>',
    // 3: Brain
    '<path d="M9 7a3 3 0 0 0-3 3 3 3 0 0 0 1 5 3 3 0 0 0 5 2V7a3 3 0 0 0-3 0zM15 7a3 3 0 0 1 3 3 3 3 0 0 1-1 5 3 3 0 0 1-5 2"/>',
    // 4: Profile
    '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottomInset + 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xEB1C1C1C),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navPaths.length,
                (index) => _buildNavItem(index: index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index}) {
    final isSelected = currentIndex == index;
    final strokeHex = isSelected ? '#101010' : '#A3A3A3';
    final svg = '<svg viewBox="0 0 24 24" width="24" height="24" fill="none" '
        'stroke="$strokeHex" stroke-width="2.2" stroke-linecap="round" '
        'stroke-linejoin="round">${_navPaths[index]}</svg>';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!isSelected) {
          HapticService.subtle();
          onTabSelected(index);
        } else {
          HapticService.subtle();
        }
      },
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.easeOut,
        width: isSelected ? 48 : 44,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accentHighlight, AppColors.primaryAccent],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: SvgPicture.string(
            svg,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}

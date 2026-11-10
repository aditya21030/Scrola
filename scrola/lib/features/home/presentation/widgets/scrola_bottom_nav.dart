import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/haptic_service.dart';

class ScrolaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const ScrolaBottomNav({
    super.key,
    this.currentIndex = 0,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.cardSurface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  isHome: true,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.bar_chart_rounded,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.emoji_events_outlined,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.code_rounded,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    bool isHome = false,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticService.subtle();
        onTabSelected(index);
      },
      child: SizedBox(
        width: 52,
        height: 52,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: isSelected ? 44 : 38,
            height: isSelected ? 44 : 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primaryAccent : Colors.transparent,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryAccent.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.textOnAccent : AppColors.mutedText,
            ),
          ),
        ),
      ),
    );
  }
}

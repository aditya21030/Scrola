import 'package:flutter/material.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

/// Standard solid card matching design.md Section 6:
/// Solid surface.solid (#1A1A1A) or card (#242424) with 1px border, no shadows.
class ScrolaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const ScrolaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.surfaceSolid) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? AppColors.borderSubtle,
          width: borderWidth,
        ),
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap == null) return container;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticService.light();
        onTap?.call();
      },
      child: container,
    );
  }
}

/// Selectable card matching design.md Section 6:
/// Selected state: 1.5-2px orange border, faint orange glow, check badge on right.
class ScrolaSelectableCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  const ScrolaSelectableCard({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticService.light();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.easeOut,
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withValues(alpha: 0.08)
              : AppColors.surfaceSolid,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.borderSubtle,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAccent.withValues(alpha: 0.14),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(child: child),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: AppMotion.standard,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryAccent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryAccent : AppColors.border,
                  width: 1.8,
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
      ),
    );
  }
}

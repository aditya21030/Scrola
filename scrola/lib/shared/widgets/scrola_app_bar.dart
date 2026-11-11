import 'package:flutter/material.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ScrolaAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBack;
  final EdgeInsetsGeometry padding;

  const ScrolaAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.showBack = true,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (showBack) ...[
            GestureDetector(
              onTap: () {
                HapticService.subtle();
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSolid,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTypography.title(
                color: AppColors.primaryText,
                size: 24,
                weight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

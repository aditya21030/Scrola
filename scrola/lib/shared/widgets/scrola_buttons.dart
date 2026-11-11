import 'package:flutter/material.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_typography.dart';

class ScrolaPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final bool useMediumHaptic;
  final Widget? leadingIcon;

  const ScrolaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.useMediumHaptic = false,
    this.leadingIcon,
  });

  @override
  State<ScrolaPrimaryButton> createState() => _ScrolaPrimaryButtonState();
}

class _ScrolaPrimaryButtonState extends State<ScrolaPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      onTap: enabled
          ? () {
              if (widget.useMediumHaptic) {
                HapticService.medium();
              } else {
                HapticService.light();
              }
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: AppMotion.pressFeedback,
        curve: AppMotion.easeOut,
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primaryAccent : AppColors.elevatedSurface,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leadingIcon != null) ...[
                widget.leadingIcon!,
                const SizedBox(width: 10),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    style: AppTypography.subheading(
                      color: enabled ? AppColors.textOnAccent : AppColors.mutedText,
                    ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
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

class ScrolaSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final Widget? leadingIcon;

  const ScrolaSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.leadingIcon,
  });

  @override
  State<ScrolaSecondaryButton> createState() => _ScrolaSecondaryButtonState();
}

class _ScrolaSecondaryButtonState extends State<ScrolaSecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      onTap: enabled
          ? () {
              HapticService.light();
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: AppMotion.pressFeedback,
        curve: AppMotion.easeOut,
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leadingIcon != null) ...[
                widget.leadingIcon!,
                const SizedBox(width: 10),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    style: AppTypography.subheading(
                      color: enabled ? AppColors.primaryText : AppColors.mutedText,
                    ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
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

class ScrolaLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ScrolaLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticService.subtle();
        onPressed();
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          label,
          style: AppTypography.body(
            color: AppColors.secondaryText,
            weight: FontWeight.w600,
          ).copyWith(
            decoration: TextDecoration.underline,
            decorationColor: AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

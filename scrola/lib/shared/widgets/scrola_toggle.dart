import 'package:flutter/material.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

/// Toggle matching design.md Section 6:
/// 52 x 32, orange when on, dark knob. Optional pulsing orange ring for permission setup guides.
class ScrolaToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showPulseRing;

  const ScrolaToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.showPulseRing = false,
  });

  @override
  State<ScrolaToggle> createState() => _ScrolaToggleState();
}

class _ScrolaToggleState extends State<ScrolaToggle> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.showPulseRing) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ScrolaToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulseRing && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!widget.showPulseRing && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticService.light();
        widget.onChanged(!widget.value);
      },
      child: SizedBox(
        width: 52,
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (widget.showPulseRing)
              Positioned.fromRect(
                rect: const Rect.fromLTWH(-7, -7, 66, 46),
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) {
                      final val = _pulseController.value;
                      return Center(
                        child: Container(
                          width: 52 + (val * 14),
                          height: 32 + (val * 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primaryAccent
                                  .withValues(alpha: (1 - val) * 0.8),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.easeOut,
            width: 52,
            height: 32,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: widget.value ? AppColors.primaryAccent : AppColors.elevatedSurface,
              border: Border.all(
                color: widget.value ? AppColors.primaryAccent : AppColors.border,
                width: 1,
              ),
            ),
            child: AnimatedAlign(
              duration: AppMotion.standard,
              curve: AppMotion.easeOut,
              alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.value ? AppColors.textOnAccent : AppColors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

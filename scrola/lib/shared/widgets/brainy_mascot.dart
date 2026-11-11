import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/services/gamification_engine.dart';
import '../../core/theme/app_motion.dart';

class BrainyMascot extends StatefulWidget {
  final BrainyMood mood;
  final BrainySkin skin;
  final double size;
  final bool animate;
  final bool silhouette;

  const BrainyMascot({
    super.key,
    this.mood = BrainyMood.happy,
    this.skin = BrainySkin.classic,
    this.size = 140,
    this.animate = true,
    this.silhouette = false,
  });

  @override
  State<BrainyMascot> createState() => _BrainyMascotState();
}

class _BrainyMascotState extends State<BrainyMascot> with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathScale;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: AppMotion.breathing,
    );

    _breathScale = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.animate) {
      _breathController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BrainyMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_breathController.isAnimating) {
      _breathController.repeat(reverse: true);
    } else if (!widget.animate && _breathController.isAnimating) {
      _breathController.stop();
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  ColorFilter? _getSkinColorFilter() {
    if (widget.silhouette) {
      return const ColorFilter.mode(Colors.black, BlendMode.srcIn);
    }
    switch (widget.skin) {
      case BrainySkin.classic:
        return null;
      case BrainySkin.ember:
        // Shift orange body toward deep coral-red while preserving whites/blacks/alpha.
        return const ColorFilter.matrix(<double>[
          1.00, 0.00, 0.00, 0, 0,
          0.10, 0.45, 0.45, 0, 0,
          0.02, 0.28, 0.70, 0, 0,
          0.00, 0.00, 0.00, 1, 0,
        ]);
      case BrainySkin.golden:
        // Shift orange body to warm golden amber while keeping catchlights white.
        return const ColorFilter.matrix(<double>[
          1.00, 0.00, 0.00, 0, 0,
          0.46, 0.54, 0.00, 0, 0,
         -0.08, 0.12, 0.96, 0, 0,
          0.00, 0.00, 0.00, 1, 0,
        ]);
      case BrainySkin.frost:
        // Matrix avoids BlendMode.hue leaking across parent canvas layers.
        return const ColorFilter.matrix(<double>[
          0.04, 0.20, 0.76, 0, 0,
          0.38, 0.62, 0.00, 0, 0,
          0.88, 0.06, 0.06, 0, 0,
          0.00, 0.00, 0.00, 1, 0,
        ]);
      case BrainySkin.mint:
        return const ColorFilter.matrix(<double>[
          0.06, 0.36, 0.58, 0, 0,
          0.64, 0.36, 0.00, 0, 0,
          0.28, 0.26, 0.46, 0, 0,
          0.00, 0.00, 0.00, 1, 0,
        ]);
      case BrainySkin.midnight:
        return const ColorFilter.matrix(<double>[
          0.12, 0.24, 0.64, 0, 0,
          0.12, 0.28, 0.60, 0, 0,
          0.20, 0.24, 0.56, 0, 0,
          0.00, 0.00, 0.00, 1, 0,
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = AppMotion.isReducedMotion(context);
    final asset = GamificationEngine.moodAssetPath(widget.mood);

    Widget svgWidget = SvgPicture.asset(
      asset,
      width: widget.size,
      height: widget.size * (130 / 140),
      fit: BoxFit.contain,
    );

    final filter = _getSkinColorFilter();
    if (filter != null) {
      svgWidget = ColorFiltered(
        colorFilter: filter,
        child: svgWidget,
      );
    }

    if (widget.silhouette) {
      svgWidget = Opacity(opacity: 0.45, child: svgWidget);
    }

    if (!widget.animate || reducedMotion || widget.silhouette) {
      return svgWidget;
    }

    return AnimatedBuilder(
      animation: _breathScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathScale.value,
          alignment: const Alignment(0, 0.85),
          child: child,
        );
      },
      child: svgWidget,
    );
  }
}

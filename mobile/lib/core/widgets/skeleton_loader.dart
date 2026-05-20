import 'package:flutter/material.dart';

import 'package:ventureiq_app/core/theme/app_colors.dart';
import 'package:ventureiq_app/core/theme/app_spacing.dart';

/// Animated shimmer loading skeleton widget.
///
/// Displays a placeholder UI element with an animated shimmer gradient sweep
/// on `surface100` base with `surface150` highlight. Respects system
/// Reduce Motion preference and includes screen reader semantics.
///
/// Usage:
/// ```dart
/// SkeletonLoader(width: 200, height: 48)
/// SkeletonLoader.text(width: 150)
/// SkeletonLoader.card()
/// ```
class SkeletonLoader extends StatefulWidget {
  /// Creates a skeleton loader with custom dimensions.
  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isText = false,
  });

  /// Convenience factory for text-line skeletons.
  ///
  /// Fixed height of 14dp with variable width.
  factory SkeletonLoader.text({
    Key? key,
    double? width,
  }) {
    return SkeletonLoader(
      key: key,
      width: width,
      height: 14,
      borderRadius: AppSpacing.radiusSm,
      isText: true,
    );
  }

  /// Convenience factory for full-card skeletons.
  ///
  /// 120dp height, full width by default.
  factory SkeletonLoader.card({
    Key? key,
    double? width,
  }) {
    return SkeletonLoader(
      key: key,
      width: width,
      height: 120,
      borderRadius: AppSpacing.radiusMd,
    );
  }

  /// Width of the skeleton. Defaults to `double.infinity` (full width).
  final double? width;

  /// Height of the skeleton.
  final double? height;

  /// Border radius of the skeleton. Defaults to [AppSpacing.radiusMd].
  final double? borderRadius;

  /// Whether this skeleton represents a text line placeholder.
  final bool isText;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!reduceMotion) {
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius = widget.borderRadius ?? AppSpacing.radiusMd;
    
    double? finalHeight = widget.height;
    if (widget.isText && finalHeight != null) {
      finalHeight = MediaQuery.textScalerOf(context).scale(finalHeight);
    }

    return Semantics(
      label: 'Loading content',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: finalHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: reduceMotion ? AppColors.surface100 : null,
              gradient: reduceMotion
                  ? null
                  : LinearGradient(
                      begin: Alignment(-2.0 + _animationController.value * 4.0, 0.0),
                      end: Alignment(0.0 + _animationController.value * 4.0, 0.0),
                      colors: const [
                        AppColors.surface100,
                        AppColors.surface150,
                        AppColors.surface100,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
            ),
          );
        },
      ),
    );
  }
}

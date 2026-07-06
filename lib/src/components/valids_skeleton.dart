import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// A placeholder shown while content is loading.
///
/// Mirrors the design system's Skeleton (`.ds-skeleton`): a
/// `background-color-soft` block with `radius-sm` corners that pulses its
/// opacity between 1 and 0.5 (the 1.5s `heartbeat` animation).
class ValidsSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ValidsSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = ValidsSpacing.md,
    this.borderRadius = ValidsRadius.sm,
  });

  @override
  State<ValidsSkeleton> createState() => _ValidsSkeletonState();
}

class _ValidsSkeletonState extends State<ValidsSkeleton>
    with SingleTickerProviderStateMixin {
  /// DS: `animation: 1.5s infinite heartbeat`.
  static const Duration _heartbeatDuration = Duration(milliseconds: 1500);

  /// DS `heartbeat` keyframes: opacity 1 → 0.5 → 1.
  static const double _minOpacity = 0.5;

  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _heartbeatDuration,
    )..repeat();
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: _minOpacity)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: _minOpacity, end: 1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: ValidsColors.backgroundSoft, // DS: background-color-soft
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

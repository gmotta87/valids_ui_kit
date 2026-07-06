import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// Semantic color of a [ValidsSpinner], matching the ValiDS design system:
/// `brand` (`text-brand-secondary-default`), `invert` (`text-invert`),
/// `neutral` (`text-soft`) and `inherit`.
///
/// `inherit` uses the ambient text/icon color so the spinner blends into its
/// surroundings (e.g. inside a button).
enum ValidsSpinnerKind { brand, invert, neutral, inherit }

/// Size of a [ValidsSpinner], matching the DS: `sm` (`size-lg` = 24),
/// `md` (`size-3xl` = 48) or `lg` (`size-5xl` = 64).
enum ValidsSpinnerSize { sm, md, lg }

/// A loading spinner: a partial arc rotating at a constant speed, matching the
/// design system's `animate-spin` (1s linear infinite).
class ValidsSpinner extends StatefulWidget {
  final ValidsSpinnerKind kind;
  final ValidsSpinnerSize size;

  const ValidsSpinner({
    super.key,
    this.kind = ValidsSpinnerKind.brand,
    this.size = ValidsSpinnerSize.sm,
  });

  @override
  State<ValidsSpinner> createState() => _ValidsSpinnerState();
}

class _ValidsSpinnerState extends State<ValidsSpinner>
    with SingleTickerProviderStateMixin {
  /// DS: `--animate-spin: spin 1s linear infinite`.
  static const Duration _spinDuration = Duration(seconds: 1);

  /// Stroke thickness as a fraction of the spinner diameter.
  static const double _strokeRatio = 0.1;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _spinDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _dimension {
    switch (widget.size) {
      case ValidsSpinnerSize.sm:
        return ValidsSpacing.lg; // DS: size-lg (24)
      case ValidsSpinnerSize.md:
        return ValidsSpacing.xl3; // DS: size-3xl (48)
      case ValidsSpinnerSize.lg:
        return ValidsSpacing.xl5; // DS: size-5xl (64)
    }
  }

  double get _strokeWidth =>
      math.max(ValidsBorderWidth.md, _dimension * _strokeRatio);

  Color _color(BuildContext context) {
    switch (widget.kind) {
      case ValidsSpinnerKind.brand:
        return ValidsColors.primary; // DS: text-brand-secondary-default
      case ValidsSpinnerKind.invert:
        return ValidsColors.textInvert; // DS: text-invert
      case ValidsSpinnerKind.neutral:
        return ValidsColors.textSoft; // DS: text-soft
      case ValidsSpinnerKind.inherit:
        return DefaultTextStyle.of(context).style.color ??
            IconTheme.of(context).color ??
            ValidsColors.textDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size.square(_dimension),
        painter: _SpinnerPainter(
          color: _color(context),
          strokeWidth: _strokeWidth,
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _SpinnerPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius =
        (math.min(size.width, size.height) - strokeWidth) / 2;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // A 270° arc with a gap, rotated continuously by the RotationTransition.
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

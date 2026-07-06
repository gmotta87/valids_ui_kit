import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// State of a [ValidsStep], matching the ValiDS design system.
enum ValidsStepState { done, active, todo }

class ValidsStep {
  final String label;
  final String? description;

  /// Custom content for the indicator circle (DS `indicator` prop; defaults
  /// to the step number).
  final Widget? indicator;

  /// Overrides the state that would otherwise be derived from `activeStep`
  /// (DS `state` prop).
  final ValidsStepState? state;

  const ValidsStep({
    required this.label,
    this.description,
    this.indicator,
    this.state,
  });
}

/// A progress indicator across a sequence of [steps], matching the ValiDS
/// design system (`ds-stepper`).
///
/// Each step shows a 24px numbered circle flanked by 1px connector lines:
/// `done` is solid success, `active` is a brand chip (solid line before,
/// dashed after) and `todo` is an outlined circle with dashed inactive
/// lines. Labels are `text-default` (bold when current) and descriptions
/// `text-soft`. The horizontal variant scrolls when the steps overflow.
class ValidsStepper extends StatelessWidget {
  final List<ValidsStep> steps;
  final int activeStep;
  final Axis orientation;

  /// Accessibility label for the stepper as a whole (DS `aria-label`).
  final String? label;

  /// Accessibility labels for each state (DS `stateLabels`; defaults:
  /// concluída/atual/pendente).
  final Map<ValidsStepState, String> stateLabels;

  const ValidsStepper({
    super.key,
    required this.steps,
    this.activeStep = 0,
    this.orientation = Axis.horizontal,
    this.label,
    this.stateLabels = const {
      ValidsStepState.done: 'concluída',
      ValidsStepState.active: 'atual',
      ValidsStepState.todo: 'pendente',
    },
  });

  /// DS indicator circle: `size-lg` (24px).
  static const double _indicatorSize = ValidsSpacing.lg;

  /// DS horizontal item: `min-w-20` (20 × 4px = 80px).
  static const double _itemMinWidth = 80;

  ValidsStepState _stateOf(int index) {
    final ValidsStepState? state = steps[index].state;
    if (state != null) return state;
    if (index < activeStep) return ValidsStepState.done;
    if (index == activeStep) return ValidsStepState.active;
    return ValidsStepState.todo;
  }

  @override
  Widget build(BuildContext context) {
    final Widget stepper = orientation == Axis.vertical
        ? _buildVertical()
        : _buildHorizontal();
    if (label == null) return stepper;
    return Semantics(label: label, container: true, child: stepper);
  }

  Widget _buildIndicator(int index) {
    final ValidsStep step = steps[index];
    final ValidsStepState state = _stateOf(index);

    // DS indicator: done `border-feedback-success bg-feedback-success-bold
    // text-invert`; active `border-brand bg-brand-softer text-brand`;
    // todo `border-inactive bg-default text-soft`.
    late final Color background;
    late final Color border;
    late final Color foreground;
    switch (state) {
      case ValidsStepState.done:
        background = ValidsColors.successDark;
        border = ValidsColors.successDark;
        foreground = ValidsColors.textInvert;
        break;
      case ValidsStepState.active:
        background = ValidsColors.primarySofter;
        border = ValidsColors.primary;
        foreground = ValidsColors.primary;
        break;
      case ValidsStepState.todo:
        background = ValidsColors.backgroundDefault;
        border = ValidsColors.borderInactive;
        foreground = ValidsColors.textSoft;
        break;
    }

    // DS default indicator content is the step number (`ts-body-sm`,
    // highlight when active), for every state.
    final Widget content = step.indicator ??
        Text(
          '${index + 1}',
          style: (state == ValidsStepState.active
                  ? ValidsTypography.bodyHighlightSm
                  : ValidsTypography.bodySm)
              .copyWith(
            color: foreground,
            // Tight line-height so the number centers in the 24px circle.
            height: 1.0,
          ),
        );

    return Semantics(
      label: stateLabels[state],
      child: Container(
        width: _indicatorSize,
        height: _indicatorSize,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: ValidsBorderWidth.md),
        ),
        child: Center(child: content),
      ),
    );
  }

  TextStyle _labelStyle(int index) {
    final bool isCurrent = _stateOf(index) == ValidsStepState.active;
    // DS label: always `text-default`; horizontal `ts-body-xs`
    // (`ts-body-highlight-xs` when current), vertical `ts-body-sm`
    // (`ts-body-highlight-sm` when current).
    final TextStyle base = orientation == Axis.horizontal
        ? (isCurrent
            ? ValidsTypography.bodyHighlightXs
            : ValidsTypography.bodyXs)
        : (isCurrent
            ? ValidsTypography.bodyHighlightSm
            : ValidsTypography.bodySm);
    return base.copyWith(color: ValidsColors.textDefault);
  }

  TextStyle get _descriptionStyle {
    // DS description: `text-soft`; `ts-body-xs` (horizontal) /
    // `ts-body-sm` (vertical).
    final TextStyle base = orientation == Axis.horizontal
        ? ValidsTypography.bodyXs
        : ValidsTypography.bodySm;
    return base.copyWith(color: ValidsColors.textSoft);
  }

  /// Connector line (`border-t-sm`/`border-l-sm`, 1px): solid success after
  /// a done step, solid brand before / dashed brand after the active step,
  /// dashed inactive for todo.
  Widget _line(
    ValidsStepState state, {
    required Axis axis,
    required bool before,
  }) {
    late final Color color;
    late final bool solid;
    switch (state) {
      case ValidsStepState.done:
        color = ValidsColors.successDark;
        solid = true;
        break;
      case ValidsStepState.active:
        color = ValidsColors.primary;
        solid = before;
        break;
      case ValidsStepState.todo:
        color = ValidsColors.borderInactive;
        solid = false;
        break;
    }

    final Widget line = solid
        ? Container(color: color)
        : CustomPaint(painter: _DashedLinePainter(axis, color));
    return axis == Axis.horizontal
        ? SizedBox(height: ValidsBorderWidth.sm, child: line)
        : SizedBox(width: ValidsBorderWidth.sm, child: line);
  }

  Widget _buildHorizontal() {
    // DS root: `py-md`; items are `flex-1` with `min-w-20`, so they share
    // the width equally and the list scrolls when it overflows.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ValidsSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double available = constraints.maxWidth;
          final bool bounded = available.isFinite;
          final double itemWidth = bounded
              ? math.max(_itemMinWidth, available / steps.length)
              : _itemMinWidth;

          final Widget row = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < steps.length; i++)
                bounded
                    ? SizedBox(width: itemWidth, child: _buildHorizontalItem(i))
                    : ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: _itemMinWidth),
                        child: _buildHorizontalItem(i),
                      ),
            ],
          );

          final bool overflows =
              bounded && itemWidth * steps.length > available;
          return overflows || !bounded
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: row,
                )
              : row;
        },
      ),
    );
  }

  Widget _buildHorizontalItem(int index) {
    final ValidsStep step = steps[index];
    final ValidsStepState state = _stateOf(index);

    // DS item: column with `gap-xs`; the counter row spans the item width
    // with connector lines flanking the indicator on both sides.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _line(state, axis: Axis.horizontal, before: true),
            ),
            _buildIndicator(index),
            Expanded(
              child: _line(state, axis: Axis.horizontal, before: false),
            ),
          ],
        ),
        const SizedBox(height: ValidsSpacing.xs),
        Padding(
          // DS label wrapper: `px-xs text-center`.
          padding: const EdgeInsets.symmetric(horizontal: ValidsSpacing.xs),
          child: Column(
            children: [
              Text(
                step.label,
                style: _labelStyle(index),
                textAlign: TextAlign.center,
              ),
              if (step.description != null)
                Text(
                  step.description!,
                  style: _descriptionStyle,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVertical() {
    // DS root (vertical): `px-lg`.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ValidsSpacing.lg),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++) _buildVerticalItem(i),
        ],
      ),
    );
  }

  Widget _buildVerticalItem(int index) {
    final ValidsStep step = steps[index];
    final ValidsStepState state = _stateOf(index);
    final bool isLast = index == steps.length - 1;

    // DS item: row with `gap-xs`; the counter column holds the indicator
    // and, when not last, the connector line below it.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              _buildIndicator(index),
              if (!isLast)
                Expanded(
                  child: _line(state, axis: Axis.vertical, before: false),
                ),
            ],
          ),
          const SizedBox(width: ValidsSpacing.xs),
          Expanded(
            child: Padding(
              // DS label wrapper: `pb-md` between items.
              padding: EdgeInsets.only(
                bottom: isLast ? ValidsSpacing.none : ValidsSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.label, style: _labelStyle(index)),
                  if (step.description != null)
                    Text(step.description!, style: _descriptionStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Axis axis;
  final Color color;

  _DashedLinePainter(this.axis, this.color);

  /// Dash pattern approximating a CSS `border-style: dashed` 1px line.
  static const double _dash = ValidsSpacing.xs2;
  static const double _gap = ValidsSpacing.xs2;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = ValidsBorderWidth.sm
      ..strokeCap = StrokeCap.butt;

    if (axis == Axis.horizontal) {
      final double y = size.height / 2;
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + _dash, size.width), y),
          paint,
        );
        x += _dash + _gap;
      }
    } else {
      final double x = size.width / 2;
      double y = 0;
      while (y < size.height) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, math.min(y + _dash, size.height)),
          paint,
        );
        y += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.axis != axis;
}

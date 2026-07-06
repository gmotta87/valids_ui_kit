import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/palette.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// DS `focus-ring` color: `--color-info-400`.
Color get _focusRingColor =>
    ValidsPalette.info.tones.firstWhere((t) => t.shade == 400).color;

/// DS hover overlays use the Tailwind `/10` (10% alpha) modifier.
const double _hoverAlpha = 0.10;

/// A radio button with optional label and description, mirroring `ds-radio`.
///
/// Visuals follow the design system:
/// - the control is a `size-lg` (24px) icon on a `rounded-full` hover halo;
/// - unchecked icon is `icon-soft`; checked uses the brand default tone;
///   disabled uses `icon-inactive` and shows a not-allowed cursor;
/// - hover: `brand-primary-default/10` (unchecked) or
///   `brand-primary-bold/10` (checked);
/// - keyboard focus draws the DS focus ring (2px, info-400, no offset —
///   `focus-ring` + `ring-offset-0`);
/// - label is `ts-body-md` (`text-default`) and description `ts-body-sm`
///   (`text-soft`); both become inactive when disabled.
///
/// Extras beyond the DS: [labelChild] for a rich label (e.g. inline links)
/// and the Flutter-idiomatic [groupValue] pairing for standalone usage.
class ValidsRadio<T> extends StatefulWidget {
  final T value;
  final T? groupValue;

  /// Called with [value] when the radio is selected. `null` makes the
  /// control inert (combine with [disabled] for the disabled visuals).
  final ValueChanged<T?>? onCheckedChange;
  final String? label;
  final Widget? labelChild;
  final String? description;
  final bool disabled;

  const ValidsRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onCheckedChange,
    this.label,
    this.labelChild,
    this.description,
    this.disabled = false,
  });

  @override
  State<ValidsRadio<T>> createState() => _ValidsRadioState<T>();
}

class _ValidsRadioState<T> extends State<ValidsRadio<T>> {
  bool _hovered = false;
  bool _focused = false;

  /// `size-lg` — the DS radio circle/icon size.
  static const double _boxSize = ValidsSpacing.lg;

  /// Top inset that centers the circle on the first `ts-body-md` label line
  /// (`leading-xl`), mirroring the DS grid `self-center` placement.
  static const double _labelTopOffset =
      (ValidsTypography.leadingXl - _boxSize) / 2;

  bool get _interactive => !widget.disabled && widget.onCheckedChange != null;

  bool get _selected => widget.value == widget.groupValue;

  void _select() => widget.onCheckedChange?.call(widget.value);

  /// `radio-icon`: soft → brand (checked) → inactive (disabled).
  Color get _iconColor {
    if (widget.disabled) return ValidsColors.textInactive;
    if (_selected) return ValidsColors.primary;
    return ValidsColors.textSoft;
  }

  Color get _hoverColor {
    final Color base =
        _selected ? ValidsColors.primaryDark : ValidsColors.primary;
    return base.withValues(alpha: _hoverAlpha);
  }

  /// `field-label ts-body-md text-default` (+ disabled override).
  Color get _labelColor =>
      widget.disabled ? ValidsColors.textInactive : ValidsColors.textDefault;

  /// `field-description ts-body-sm text-soft` (+ disabled override).
  Color get _descriptionColor =>
      widget.disabled ? ValidsColors.textInactive : ValidsColors.textSoft;

  Widget _buildControl() {
    final Widget circle = Container(
      width: _boxSize,
      height: _boxSize,
      decoration: BoxDecoration(
        color: _hovered && _interactive ? _hoverColor : null,
        shape: BoxShape.circle,
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: _focusRingColor,
                  spreadRadius: ValidsBorderWidth.md,
                ),
              ]
            : null,
      ),
      child: Icon(
        _selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        size: _boxSize,
        color: _iconColor,
      ),
    );

    return FocusableActionDetector(
      enabled: _interactive,
      mouseCursor: _interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _select();
            return null;
          },
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (_) {
            _select();
            return null;
          },
        ),
      },
      child: circle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget control = _buildControl();

    final bool hasText = widget.label != null ||
        widget.labelChild != null ||
        widget.description != null;

    final Widget child;
    if (!hasText) {
      child = control;
    } else {
      final bool hasLabelLine =
          widget.label != null || widget.labelChild != null;
      // DS grid: `grid-cols-[auto_1fr] gap-x-2xs`, control self-centered on
      // the label row, description on the second row.
      child = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: hasLabelLine ? _labelTopOffset : ValidsSpacing.none,
            ),
            child: control,
          ),
          const SizedBox(width: ValidsSpacing.xs2),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.labelChild != null)
                  widget.labelChild!
                else if (widget.label != null)
                  Text(
                    widget.label!,
                    style:
                        ValidsTypography.bodyMd.copyWith(color: _labelColor),
                  ),
                if (widget.description != null)
                  Text(
                    widget.description!,
                    style: ValidsTypography.bodySm
                        .copyWith(color: _descriptionColor),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Semantics(
      enabled: _interactive,
      checked: _selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        onTap: _interactive ? _select : null,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}

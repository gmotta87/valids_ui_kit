import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/palette.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// A toggle switch with an optional label and description.
///
/// Mirrors the design system's `Switch` (`ds-switch`): a 56×32 rounded-full
/// track whose thumb grows from 16px (unchecked, `p-xs`) to 24px (checked,
/// `p-2xs`), with a `ts-body-md` label and a `ts-body-sm` soft description.
/// Use [labelChild] for a rich label (e.g. with inline links/tags).
class ValidsSwitch extends StatefulWidget {
  /// Whether the switch is on (`data-checked` in the DS).
  final bool checked;

  /// Called with the next checked state (DS `onCheckedChange`). `null`
  /// disables the switch.
  final ValueChanged<bool>? onCheckedChange;

  final String? label;
  final Widget? labelChild;
  final String? description;
  final bool disabled;

  const ValidsSwitch({
    super.key,
    required this.checked,
    required this.onCheckedChange,
    this.label,
    this.labelChild,
    this.description,
    this.disabled = false,
  });

  @override
  State<ValidsSwitch> createState() => _ValidsSwitchState();
}

class _ValidsSwitchState extends State<ValidsSwitch> {
  /// DS `transition duration-150`.
  static const Duration _animationDuration = Duration(milliseconds: 150);

  /// DS `w-14` (56px).
  static const double _trackWidth = ValidsSpacing.xl4;

  /// DS `h-8` (32px).
  static const double _trackHeight = ValidsSpacing.xl;

  bool _hovered = false;
  bool _focused = false;

  bool get _isDisabled => widget.disabled || widget.onCheckedChange == null;

  void _toggle() => widget.onCheckedChange?.call(!widget.checked);

  /// DS `focus-ring`: 2px `info-400` ring offset 2px from the edge.
  static List<BoxShadow> get _focusRing {
    const double ringWidth = ValidsBorderWidth.md;
    const double ringOffset = ValidsBorderWidth.md;
    final Color ringColor = ValidsPalette.info.tones
        .firstWhere((tone) => tone.shade == 400)
        .color;
    return [
      BoxShadow(color: ringColor, spreadRadius: ringOffset + ringWidth),
      const BoxShadow(
        color: ValidsColors.backgroundDefault,
        spreadRadius: ringOffset,
      ),
    ];
  }

  Widget _buildTrack() {
    final bool checked = widget.checked;

    // DS: track padding `p-xs` (8) unchecked → `p-2xs` (4) checked; the thumb
    // fills the padded height (16px → 24px).
    final double padding = checked ? ValidsSpacing.xs2 : ValidsSpacing.xs;
    final double thumbSize = _trackHeight - padding * 2;

    // DS: `bg-medium`, checked `bg-brand-secondary-default`, hover `bg-bold` /
    // `bg-brand-secondary-bold`, disabled `bg-softer`.
    late final Color trackColor;
    if (_isDisabled) {
      trackColor = ValidsColors.backgroundSofter;
    } else if (checked) {
      trackColor = _hovered ? ValidsColors.primaryDark : ValidsColors.primary;
    } else {
      trackColor = _hovered
          ? ValidsColors.backgroundBold
          : ValidsColors.backgroundMedium;
    }

    // DS thumb: `bg-default`, disabled `bg-inactive`.
    final Color thumbColor = _isDisabled
        ? ValidsColors.backgroundInactive
        : ValidsColors.backgroundDefault;

    return FocusableActionDetector(
      enabled: !_isDisabled,
      mouseCursor: _isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _toggle();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: _isDisabled ? null : _toggle,
        child: AnimatedContainer(
          duration: _animationDuration,
          width: _trackWidth,
          height: _trackHeight,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: ValidsRadius.fullRadius,
            boxShadow: _focused ? _focusRing : null,
          ),
          child: AnimatedAlign(
            duration: _animationDuration,
            alignment: checked ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: _animationDuration,
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color: thumbColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget toggle = Semantics(
      toggled: widget.checked,
      enabled: !_isDisabled,
      label: widget.label,
      child: _buildTrack(),
    );

    final bool hasText =
        widget.label != null ||
        widget.labelChild != null ||
        widget.description != null;
    if (!hasText) return toggle;

    // DS `ds-switch`: field grid with `gap-x-md`, control spanning both rows
    // and self-centered; label `ts-body-md text-default`, description
    // `ts-body-sm text-soft` (both `text-inactive` when disabled).
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _isDisabled ? null : _toggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          toggle,
          const SizedBox(width: ValidsSpacing.md),
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
                    style: ValidsTypography.bodyMd.copyWith(
                      color: _isDisabled
                          ? ValidsColors.textInactive
                          : ValidsColors.textDefault,
                    ),
                  ),
                if (widget.description != null)
                  Text(
                    widget.description!,
                    style: ValidsTypography.bodySm.copyWith(
                      color: _isDisabled
                          ? ValidsColors.textInactive
                          : ValidsColors.textSoft,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

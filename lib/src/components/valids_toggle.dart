import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/palette.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// A two-state toggle button with an icon and/or a label.
///
/// Mirrors the design system's `Toggle` (`ds-toggle`): a 32px-high,
/// `rounded-md` bordered pill with `ts-body-highlight-xs` text that takes the
/// brand color when pressed and shows a `focus-ring` when focused via
/// keyboard.
class ValidsToggle extends StatefulWidget {
  final IconData? icon;
  final String? label;

  /// Whether the toggle is pressed (`data-pressed` in the DS).
  final bool pressed;

  /// Called with the next pressed state when the toggle is activated
  /// (DS `onPressedChange`). `null` disables the toggle.
  final ValueChanged<bool>? onPressedChange;

  final bool disabled;

  const ValidsToggle({
    super.key,
    this.icon,
    this.label,
    this.pressed = false,
    required this.onPressedChange,
    this.disabled = false,
  }) : assert(
         icon != null || label != null,
         'ValidsToggle requires an icon and/or a label',
       );

  @override
  State<ValidsToggle> createState() => _ValidsToggleState();
}

class _ValidsToggleState extends State<ValidsToggle> {
  /// DS `transition duration-150`.
  static const Duration _animationDuration = Duration(milliseconds: 150);

  /// DS `h-8` (32px).
  static const double _height = ValidsSpacing.xl;

  /// DS `min-w-12` (48px).
  static const double _minWidth = ValidsSpacing.xl3;

  /// DS `[&_svg]:size-md` (16px).
  static const double _iconSize = ValidsSpacing.md;

  bool _hovered = false;
  bool _focused = false;

  bool get _isDisabled => widget.disabled || widget.onPressedChange == null;

  void _toggle() => widget.onPressedChange?.call(!widget.pressed);

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

  @override
  Widget build(BuildContext context) {
    final bool pressed = widget.pressed;

    // DS: base `border-soft bg-default text-soft`;
    // hover (enabled, unpressed) `border/text brand-secondary-default`;
    // pressed `border/text brand-secondary-default bg-brand-secondary-softer`;
    // disabled `border-inactive text-inactive` (pressed keeps the softer bg).
    late final Color borderColor;
    late final Color foregroundColor;
    late final Color backgroundColor;
    if (pressed) {
      backgroundColor = ValidsColors.primarySofter;
      borderColor = _isDisabled
          ? ValidsColors.borderInactive
          : ValidsColors.primary;
      foregroundColor = _isDisabled
          ? ValidsColors.textInactive
          : ValidsColors.primary;
    } else if (_isDisabled) {
      backgroundColor = ValidsColors.backgroundDefault;
      borderColor = ValidsColors.borderInactive;
      foregroundColor = ValidsColors.textInactive;
    } else if (_hovered) {
      backgroundColor = ValidsColors.backgroundDefault;
      borderColor = ValidsColors.primary;
      foregroundColor = ValidsColors.primary;
    } else {
      backgroundColor = ValidsColors.backgroundDefault;
      borderColor = ValidsColors.borderSoft;
      foregroundColor = ValidsColors.textSoft;
    }

    return Semantics(
      button: true,
      enabled: !_isDisabled,
      toggled: pressed,
      label: widget.label,
      child: FocusableActionDetector(
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
            height: _height,
            constraints: const BoxConstraints(minWidth: _minWidth),
            padding: const EdgeInsets.symmetric(horizontal: ValidsSpacing.xs),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: ValidsRadius.mdRadius,
              border: Border.all(
                color: borderColor,
                width: ValidsBorderWidth.sm,
              ),
              boxShadow: _focused ? _focusRing : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null)
                  Icon(widget.icon, size: _iconSize, color: foregroundColor),
                if (widget.icon != null && widget.label != null)
                  const SizedBox(width: ValidsSpacing.xs3),
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: ValidsTypography.bodyHighlightXs.copyWith(
                      color: foregroundColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

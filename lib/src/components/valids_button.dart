import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/palette.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_spinner.dart';

/// Visual style of a [ValidsButton], matching the ValiDS design system.
enum ValidsButtonVariant { filled, outlined, ghost }

/// Semantic intent of a [ValidsButton]: `brand` (default) or `destructive`.
enum ValidsButtonKind { brand, destructive }

/// Size of a [ValidsButton]. `none` removes padding for inline/link usage
/// (and uses the small radius, like the design system).
enum ValidsButtonSize { md, sm, none }

/// `background-color-button-destructive-bold` → error-900.
Color get _destructiveBold =>
    ValidsPalette.error.tones.firstWhere((t) => t.shade == 900).color;

/// Action button mirroring the design system's `ds-button`
/// (`kind` × `variant` × `size`, plus `disabled` / `softDisabled`).
///
/// Extras beyond the DS: [label]/[icon] convenience props (the DS uses
/// arbitrary children) and a [loading] state that shows an inline spinner and
/// blocks presses.
class ValidsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ValidsButtonVariant variant;
  final ValidsButtonKind kind;
  final ValidsButtonSize size;

  /// Optional leading icon (convenience extra beyond the DS API).
  final IconData? icon;

  /// Shows a spinner next to the label and blocks presses while `true`.
  final bool loading;

  /// Hard disabled: non-interactive, disabled visuals (DS `disabled`).
  final bool disabled;

  /// Disabled visuals but still focusable/actionable (DS `softDisabled`).
  final bool softDisabled;

  const ValidsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ValidsButtonVariant.filled,
    this.kind = ValidsButtonKind.brand,
    this.size = ValidsButtonSize.md,
    this.icon,
    this.loading = false,
    this.disabled = false,
    this.softDisabled = false,
  });

  /// Resting accent per [kind]: `brand-primary-default` / destructive error-800.
  Color get _accent => kind == ValidsButtonKind.destructive
      ? ValidsColors.dangerDark
      : ValidsColors.primary;

  /// Hover accent per [kind]: `brand-primary-bold` / destructive error-900.
  Color get _accentBold => kind == ValidsButtonKind.destructive
      ? _destructiveBold
      : ValidsColors.primaryDark;

  /// Ghost text color per [kind] (`--btn-ghost`).
  Color get _ghost => kind == ValidsButtonKind.destructive
      ? ValidsColors.dangerDark
      : ValidsColors.primary;

  bool get _visuallyDisabled =>
      disabled || softDisabled || (onPressed == null && !loading);

  /// DS icons render at `size-lg` (24px) inside buttons.
  static const double _iconSize = ValidsSpacing.lg;

  @override
  Widget build(BuildContext context) {
    final bool blocked = disabled || loading || onPressed == null;

    return ElevatedButton(
      onPressed: blocked ? null : onPressed,
      style: _buttonStyle(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading) ...[
            const SizedBox(
              height: _iconSize,
              width: _iconSize,
              child: ValidsSpinner(kind: ValidsSpinnerKind.inherit),
            ),
            const SizedBox(width: ValidsSpacing.xs), // gap-xs
          ] else if (icon != null) ...[
            Icon(icon, size: _iconSize),
            const SizedBox(width: ValidsSpacing.xs), // gap-xs
          ],
          Text(label),
        ],
      ),
    );
  }

  /// px-md py-md (md) / px-md py-xs (sm) / none.
  EdgeInsetsGeometry get _padding {
    switch (size) {
      case ValidsButtonSize.md:
        return const EdgeInsets.symmetric(
          horizontal: ValidsSpacing.md,
          vertical: ValidsSpacing.md,
        );
      case ValidsButtonSize.sm:
        return const EdgeInsets.symmetric(
          horizontal: ValidsSpacing.md,
          vertical: ValidsSpacing.xs,
        );
      case ValidsButtonSize.none:
        return EdgeInsets.zero;
    }
  }

  /// `rounded-md`, or `rounded-sm` for size `none`.
  BorderRadius get _radius => size == ValidsButtonSize.none
      ? ValidsRadius.smRadius
      : ValidsRadius.mdRadius;

  Color get _background {
    switch (variant) {
      case ValidsButtonVariant.filled:
        return _visuallyDisabled ? ValidsColors.backgroundInactive : _accent;
      case ValidsButtonVariant.outlined:
        return ValidsColors.backgroundDefault;
      case ValidsButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _foreground {
    switch (variant) {
      case ValidsButtonVariant.filled:
        return ValidsColors.textInvert;
      case ValidsButtonVariant.outlined:
        return _visuallyDisabled ? ValidsColors.textInactive : _accent;
      case ValidsButtonVariant.ghost:
        return _visuallyDisabled ? ValidsColors.textInactive : _ghost;
    }
  }

  BorderSide get _side {
    switch (variant) {
      case ValidsButtonVariant.filled:
        return BorderSide(
          color: _visuallyDisabled ? ValidsColors.borderInactive : _accent,
          width: ValidsBorderWidth.sm,
        );
      case ValidsButtonVariant.outlined:
        return BorderSide(
          color: _visuallyDisabled ? ValidsColors.borderInactive : _accent,
          width: ValidsBorderWidth.sm,
        );
      case ValidsButtonVariant.ghost:
        return const BorderSide(
          color: Colors.transparent,
          width: ValidsBorderWidth.sm,
        );
    }
  }

  /// Hover/pressed overlay: filled → kind bold; outlined/ghost → kind @10%.
  Color? get _overlay {
    if (_visuallyDisabled) return Colors.transparent;
    switch (variant) {
      case ValidsButtonVariant.filled:
        return _accentBold;
      case ValidsButtonVariant.outlined:
        return _accent.withValues(alpha: 0.10);
      case ValidsButtonVariant.ghost:
        return _ghost.withValues(alpha: 0.10);
    }
  }

  ButtonStyle _buttonStyle() {
    final bool isNone = size == ValidsButtonSize.none;

    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      padding: WidgetStatePropertyAll(_padding),
      // min-w-16 (64px) for sm/md.
      minimumSize: WidgetStatePropertyAll(
        isNone ? Size.zero : const Size(ValidsSpacing.xl5, 0),
      ),
      tapTargetSize: isNone ? MaterialTapTargetSize.shrinkWrap : null,
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: _radius),
      ),
      side: WidgetStatePropertyAll(_side),
      backgroundColor: WidgetStatePropertyAll(_background),
      foregroundColor: WidgetStatePropertyAll(_foreground),
      iconSize: const WidgetStatePropertyAll(_iconSize),
      textStyle: const WidgetStatePropertyAll(ValidsTypography.buttonMd),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused)) {
          return _overlay;
        }
        return null;
      }),
    );
  }
}

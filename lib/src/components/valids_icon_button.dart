import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/palette.dart';
import '../tokens/spacing.dart';
import 'valids_button.dart';

/// Semantic color of a [ValidsIconButton], matching the ValiDS design system
/// (`brand`, `destructive`, `neutral` and the feedback kinds — the DS only
/// styles the feedback kinds for the `ghost` variant).
enum ValidsIconButtonKind {
  brand,
  destructive,
  neutral,
  success,
  error,
  info,
  warning,
}

/// Resolved color slots for a kind, mirroring the DS `--ib-*` variables.
class _IconButtonColors {
  final Color fill; // --ib-fill
  final Color fillHover; // --ib-fill-hover
  final Color fillText; // --ib-fill-text
  final Color outline; // --ib-outline
  final Color ghost; // --ib-ghost
  final Color ghostHover; // --ib-ghost-hover

  const _IconButtonColors({
    required this.fill,
    required this.fillHover,
    required this.fillText,
    required this.outline,
    required this.ghost,
    required this.ghostHover,
  });
}

/// `background-color-button-destructive-bold` → error-900.
Color get _destructiveBold =>
    ValidsPalette.error.tones.firstWhere((t) => t.shade == 900).color;

/// An icon-only button mirroring the design system's `ds-icon-button`
/// (`kind` × `variant` × `size`, plus `disabled` / `softDisabled`). Reuses
/// [ValidsButtonVariant] and [ValidsButtonSize] for the shared tokens.
///
/// DS defaults: `kind: brand`, `variant: ghost`, `size: sm`.
class ValidsIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ValidsIconButtonKind kind;
  final ValidsButtonVariant variant;
  final ValidsButtonSize size;

  /// Hard disabled: non-interactive, disabled visuals (DS `disabled`).
  final bool disabled;

  /// Disabled visuals but still focusable/actionable (DS `softDisabled`).
  final bool softDisabled;

  const ValidsIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.kind = ValidsIconButtonKind.brand,
    this.variant = ValidsButtonVariant.ghost,
    this.size = ValidsButtonSize.sm,
    this.disabled = false,
    this.softDisabled = false,
  });

  _IconButtonColors get _colors {
    switch (kind) {
      case ValidsIconButtonKind.brand:
        return _IconButtonColors(
          fill: ValidsColors.primary,
          fillHover: ValidsColors.primaryDark,
          fillText: ValidsColors.textInvert,
          outline: ValidsColors.primary,
          ghost: ValidsColors.primary,
          ghostHover: ValidsColors.primary,
        );
      case ValidsIconButtonKind.destructive:
        return _IconButtonColors(
          fill: ValidsColors.dangerDark,
          fillHover: _destructiveBold,
          fillText: ValidsColors.textInvert,
          outline: ValidsColors.dangerDark,
          ghost: ValidsColors.dangerDark,
          ghostHover: ValidsColors.dangerDark,
        );
      case ValidsIconButtonKind.neutral:
        return const _IconButtonColors(
          fill: ValidsColors.backgroundDefault,
          fillHover: ValidsColors.backgroundSoft,
          fillText: ValidsColors.textSoft,
          outline: ValidsColors.borderBold,
          ghost: ValidsColors.textSoft,
          ghostHover: ValidsColors.backgroundBold,
        );
      // Feedback kinds: the DS only defines the ghost slots (text/hover =
      // feedback 800). The other slots reuse the same tone so the extra
      // filled/outlined combinations keep working.
      case ValidsIconButtonKind.success:
        return _feedback(ValidsColors.successDark);
      case ValidsIconButtonKind.error:
        return _feedback(ValidsColors.dangerDark);
      case ValidsIconButtonKind.info:
        return _feedback(ValidsColors.infoDark);
      case ValidsIconButtonKind.warning:
        return _feedback(ValidsColors.warningDark);
    }
  }

  static _IconButtonColors _feedback(Color tone) => _IconButtonColors(
        fill: tone,
        fillHover: tone,
        fillText: ValidsColors.textInvert,
        outline: tone,
        ghost: tone,
        ghostHover: tone,
      );

  bool get _visuallyDisabled => disabled || softDisabled || onPressed == null;

  /// p-md (md) / p-xs (sm) / none.
  EdgeInsets get _padding {
    switch (size) {
      case ValidsButtonSize.md:
        return const EdgeInsets.all(ValidsSpacing.md);
      case ValidsButtonSize.sm:
        return const EdgeInsets.all(ValidsSpacing.xs);
      case ValidsButtonSize.none:
        return EdgeInsets.zero;
    }
  }

  /// `rounded-md`, or `rounded-sm` for size `none`.
  BorderRadius get _radius => size == ValidsButtonSize.none
      ? ValidsRadius.smRadius
      : ValidsRadius.mdRadius;

  /// DS icons render at `size-lg` (24px).
  static const double _iconSize = ValidsSpacing.lg;

  @override
  Widget build(BuildContext context) {
    final _IconButtonColors colors = _colors;
    final bool visuallyDisabled = _visuallyDisabled;

    late final Color background;
    late final Color foreground;
    late final Color borderColor;
    late final Color? hoverOverlay;

    switch (variant) {
      case ValidsButtonVariant.filled:
        background =
            visuallyDisabled ? ValidsColors.backgroundInactive : colors.fill;
        foreground =
            visuallyDisabled ? ValidsColors.textInvert : colors.fillText;
        borderColor =
            visuallyDisabled ? ValidsColors.borderInactive : colors.fill;
        hoverOverlay = visuallyDisabled ? null : colors.fillHover;
      case ValidsButtonVariant.outlined:
        background = ValidsColors.backgroundDefault;
        foreground =
            visuallyDisabled ? ValidsColors.textInactive : colors.outline;
        borderColor =
            visuallyDisabled ? ValidsColors.borderInactive : colors.outline;
        hoverOverlay = visuallyDisabled
            ? null
            : colors.outline.withValues(alpha: 0.10);
      case ValidsButtonVariant.ghost:
        background = Colors.transparent;
        foreground =
            visuallyDisabled ? ValidsColors.textInactive : colors.ghost;
        borderColor = Colors.transparent;
        hoverOverlay = visuallyDisabled
            ? null
            : colors.ghostHover.withValues(alpha: 0.10);
    }

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: _radius,
        side: BorderSide(color: borderColor, width: ValidsBorderWidth.sm),
      ),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: _radius,
        hoverColor: hoverOverlay,
        splashColor: hoverOverlay,
        highlightColor: hoverOverlay,
        child: Padding(
          padding: _padding,
          child: Icon(icon, size: _iconSize, color: foreground),
        ),
      ),
    );
  }
}

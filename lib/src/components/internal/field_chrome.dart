import 'package:flutter/material.dart';

import '../../tokens/borders.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Internal building blocks shared by the ValiDS form fields
/// (`ds-text-field`, `ds-text-area`, `ds-select`, `ds-number-picker`).
///
/// Mirrors the DS shared classes `field-wrapper`, `field-floating-label`,
/// `field-adornment` and the `FieldSupport` component. This file is not
/// exported by the package.

/// DS field transition (`duration-200 ease-out`).
const Duration fieldTransitionDuration = Duration(milliseconds: 200);

/// The bordered box of a field (`field-wrapper` / `select-wrapper`):
/// `rounded-md border-sm border-soft bg-default px-md`, with hover
/// (`border-bold`), focus (`border-bold` + 1px ring), invalid (`error-800`)
/// and disabled (`border-inactive`) states.
class FieldWrapper extends StatelessWidget {
  final bool hovered;
  final bool focused;
  final bool invalid;
  final bool disabled;

  /// `h-14` (56px) for single-line fields; `null` lets content size the box.
  final double? height;
  final BoxConstraints? constraints;

  /// Defaults to `px-md`.
  final EdgeInsetsGeometry? padding;
  final Widget child;

  const FieldWrapper({
    super.key,
    this.hovered = false,
    this.focused = false,
    this.invalid = false,
    this.disabled = false,
    this.height,
    this.constraints,
    this.padding,
    required this.child,
  });

  Color get _borderColor {
    if (disabled) return ValidsColors.borderInactive;
    if (invalid) return ValidsColors.dangerDark;
    if (focused || hovered) return ValidsColors.borderBold;
    return ValidsColors.borderSoft;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: fieldTransitionDuration,
      curve: Curves.easeOut,
      height: height,
      constraints: constraints,
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: ValidsSpacing.md),
      decoration: BoxDecoration(
        color: ValidsColors.backgroundDefault,
        borderRadius: ValidsRadius.mdRadius,
        border: Border.all(color: _borderColor, width: ValidsBorderWidth.sm),
        // Focus ring (`focus-ring-field`): 1px ring in the border color.
        boxShadow: focused && !disabled
            ? [BoxShadow(color: _borderColor, spreadRadius: ValidsBorderWidth.sm)]
            : null,
      ),
      child: child,
    );
  }
}

/// The floating label (`field-floating-label`): rests inside the field as
/// `ts-body-md text-soft`; floats to the top border as a `ts-body-xs` chip
/// (`bg-default px-2xs rounded-sm`) when focused, filled or with a start
/// adornment. Must be a child of a `Stack` with `clipBehavior: Clip.none`.
class FieldFloatingLabel extends StatelessWidget {
  final String label;
  final bool floated;
  final bool invalid;
  final bool disabled;

  /// Resting offset from the wrapper top (`top-sm` for text areas; the same
  /// 12px centers the 32px-tall label in the 56px single-line wrapper).
  final double restTop;

  /// Extra widget rendered after the label text (e.g. the required tag).
  final Widget? trailing;

  const FieldFloatingLabel({
    super.key,
    required this.label,
    required this.floated,
    this.invalid = false,
    this.disabled = false,
    this.restTop = ValidsSpacing.sm,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = disabled
        ? ValidsColors.textInactive
        : invalid
            ? ValidsColors.dangerDark
            : ValidsColors.textSoft;

    return AnimatedPositioned(
      duration: fieldTransitionDuration,
      curve: Curves.easeOut,
      left: floated ? ValidsSpacing.sm : ValidsSpacing.md,
      // Max width: floated `calc(100% - 2rem)`, resting `calc(100% - 6rem)`.
      right: floated
          ? ValidsSpacing.md + ValidsSpacing.xs2
          : ValidsSpacing.xl6,
      // Floated: centered on the top border (chip line height = leading-md).
      top: floated ? -ValidsTypography.leadingMd / 2 : restTop,
      child: IgnorePointer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: AnimatedContainer(
                duration: fieldTransitionDuration,
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: floated ? ValidsSpacing.xs2 : ValidsSpacing.none,
                ),
                decoration: BoxDecoration(
                  color: floated
                      ? ValidsColors.backgroundDefault
                      : Colors.transparent,
                  borderRadius: ValidsRadius.smRadius,
                ),
                child: AnimatedDefaultTextStyle(
                  duration: fieldTransitionDuration,
                  curve: Curves.easeOut,
                  style: (floated
                          ? ValidsTypography.bodyXs
                          : ValidsTypography.bodyMd)
                      .copyWith(color: color),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: ValidsSpacing.xs2),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Support/error text below a field (DS `FieldSupport`):
/// `mt-2xs px-md ts-body-xs text-soft`, error variant in
/// `text-feedback-error` with a 16px error icon. Renders nothing when empty.
class FieldSupport extends StatelessWidget {
  final String? description;
  final String? errorMessage;

  const FieldSupport({super.key, this.description, this.errorMessage});

  bool get _hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final String? text = _hasError ? errorMessage : description;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final Color color =
        _hasError ? ValidsColors.dangerDark : ValidsColors.textSoft;

    return Padding(
      padding: const EdgeInsets.only(
        top: ValidsSpacing.xs2,
        left: ValidsSpacing.md,
        right: ValidsSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasError) ...[
            const Icon(
              Icons.error,
              size: ValidsSpacing.md,
              color: ValidsColors.dangerDark,
            ),
            const SizedBox(width: ValidsSpacing.xs2),
          ],
          Expanded(
            child: Text(
              text,
              style: ValidsTypography.bodyXs.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Styles a start/end adornment (`field-adornment`): icons at `size-lg` in
/// `icon-soft` (#4d4d4d) and text as `ts-caption-md text-soft`
/// (`AdornmentText`); inactive tones when disabled.
class FieldAdornment extends StatelessWidget {
  final bool disabled;
  final Widget child;

  const FieldAdornment({super.key, this.disabled = false, required this.child});

  @override
  Widget build(BuildContext context) {
    final Color color =
        disabled ? ValidsColors.textInactive : ValidsColors.textSoft;
    return IconTheme.merge(
      data: IconThemeData(color: color, size: ValidsSpacing.lg),
      child: DefaultTextStyle.merge(
        style: ValidsTypography.captionMd.copyWith(color: color),
        child: child,
      ),
    );
  }
}

/// "Obrigatório" / "Opcional" tag rendered next to the label
/// (extra beyond the DS API, kept from the previous implementation).
class FieldRequiredTag extends StatelessWidget {
  final bool isRequired;

  const FieldRequiredTag({super.key, required this.isRequired});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValidsSpacing.xs2,
        vertical: ValidsSpacing.xs3,
      ),
      decoration: BoxDecoration(
        color: isRequired
            ? ValidsColors.danger.withValues(alpha: 0.10)
            : ValidsColors.backgroundSoft,
        borderRadius: ValidsRadius.smRadius,
      ),
      child: Text(
        isRequired ? 'Obrigatório' : 'Opcional',
        style: ValidsTypography.captionSm.copyWith(
          color:
              isRequired ? ValidsColors.dangerDark : ValidsColors.textSoft,
        ),
      ),
    );
  }
}

/// An option row in a dropdown/sheet list (`ds-select-item`):
/// `px-md py-xs`, title `ts-body-md text-default`, description
/// `ts-body-sm text-soft`, highlighted with `brand/10`, disabled in
/// `text-inactive`.
class FieldOptionTile extends StatelessWidget {
  final String title;
  final String? description;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  const FieldOptionTile({
    super.key,
    required this.title,
    this.description,
    this.selected = false,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ValidsSpacing.md,
          vertical: ValidsSpacing.xs,
        ),
        color: selected
            ? ValidsColors.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ValidsTypography.bodyMd.copyWith(
                      color: disabled
                          ? ValidsColors.textInactive
                          : ValidsColors.textDefault,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: ValidsTypography.bodySm.copyWith(
                        color: disabled
                            ? ValidsColors.textInactive
                            : ValidsColors.textSoft,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check,
                size: ValidsSpacing.lg,
                color: ValidsColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

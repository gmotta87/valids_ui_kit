import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Semantic color of a [ValidsChip], matching the ValiDS design system.
enum ValidsChipKind { brand, neutral, success, info, warning, error }

/// A compact tag/label. Mirrors the design system's Chip: fixed 32px height,
/// 64px minimum width, pill shape (`rounded-full`), 1px border and
/// `ts-body-highlight-xs` centered text, with the semantic `kind` colors.
///
/// The optional leading icon, tap action and removal (`onDeleted`, the DS
/// `ChipIconButton`) are kept as functional extensions.
class ValidsChip extends StatelessWidget {
  final String label;
  final ValidsChipKind kind;
  final IconData? leadingIcon;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  /// Maximum width of the chip. The DS uses `max-w-full`, so the default is
  /// unbounded (the label truncates within the available space).
  final double maxWidth;

  const ValidsChip({
    super.key,
    required this.label,
    this.kind = ValidsChipKind.brand,
    this.leadingIcon,
    this.onTap,
    this.onDeleted,
    this.maxWidth = double.infinity,
  });

  /// DS: `h-8` (32px).
  static const double _height = ValidsSpacing.xl;

  /// DS: `min-w-16` (64px).
  static const double _minWidth = ValidsSpacing.xl5;

  /// Icon slot, matching the chip's `leading-md` (16px) line height.
  static const double _iconSize = ValidsSpacing.md;

  /// DS: `bg-*` per kind (`*-softer` for brand/neutral, `*-default` = 50 for
  /// feedback kinds).
  Color get _background {
    switch (kind) {
      case ValidsChipKind.brand:
        return ValidsColors.primarySofter;
      case ValidsChipKind.neutral:
        return ValidsColors.backgroundSofter;
      case ValidsChipKind.success:
        return ValidsColors.successSoft;
      case ValidsChipKind.info:
        return ValidsColors.infoSoft;
      case ValidsChipKind.warning:
        return ValidsColors.warningSoft;
      case ValidsChipKind.error:
        return ValidsColors.dangerSoft;
    }
  }

  /// DS: `text-*` per kind (`text-soft` for neutral, 800 tone otherwise).
  Color get _foreground {
    switch (kind) {
      case ValidsChipKind.brand:
        return ValidsColors.primary;
      case ValidsChipKind.neutral:
        return ValidsColors.textSoft;
      case ValidsChipKind.success:
        return ValidsColors.successDark;
      case ValidsChipKind.info:
        return ValidsColors.infoDark;
      case ValidsChipKind.warning:
        return ValidsColors.warningDark;
      case ValidsChipKind.error:
        return ValidsColors.dangerDark;
    }
  }

  /// DS: `border-*` per kind (`border-bold` for neutral, text tone otherwise).
  Color get _border {
    switch (kind) {
      case ValidsChipKind.neutral:
        return ValidsColors.borderBold;
      default:
        return _foreground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color foreground = _foreground;

    final Widget chip = Container(
      height: _height,
      constraints: BoxConstraints(minWidth: _minWidth, maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(
        horizontal: ValidsSpacing.xs, // DS: px-xs
        vertical: ValidsSpacing.xs2, // DS: py-2xs
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: ValidsRadius.fullRadius, // DS: rounded-full
        border: Border.all(color: _border, width: ValidsBorderWidth.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // DS: justify-center
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: _iconSize, color: foreground),
            const SizedBox(width: ValidsSpacing.xs2), // DS: gap-2xs
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // DS: ChipTruncate
              textAlign: TextAlign.center,
              style: ValidsTypography.bodyHighlightXs
                  .copyWith(color: foreground),
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: ValidsSpacing.xs2), // DS: gap-2xs
            GestureDetector(
              onTap: onDeleted,
              child: Icon(Icons.close, size: _iconSize, color: foreground),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }
    return chip;
  }
}

import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Size of a [ValidsAnchor], matching the ValiDS design system:
/// `inherit` (default — follows the surrounding text size) or the
/// `ts-body-link-highlight-*` scale (xs=12, sm=14, md=16, lg=18).
enum ValidsAnchorSize { inherit, xs, sm, md, lg }

/// Color treatment of a [ValidsAnchor]: `brand` uses the brand color, while
/// `inherit` follows the surrounding text color.
enum ValidsAnchorKind { brand, inherit }

/// Inline text link mirroring the design system's `ds-anchor`
/// (`kind` + `size`, bold underlined `ts-body-link-highlight-*` styles).
///
/// Extras beyond the DS: the optional [icon] trailing affordance, the
/// [underline] toggle, and the inactive color when [onTap] is null.
class ValidsAnchor extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final ValidsAnchorSize size;
  final ValidsAnchorKind kind;

  /// Optional trailing icon (convenience extra beyond the DS).
  final IconData? icon;

  /// Set to false to remove the underline (extra beyond the DS).
  final bool underline;

  const ValidsAnchor({
    super.key,
    required this.label,
    this.onTap,
    this.size = ValidsAnchorSize.inherit,
    this.kind = ValidsAnchorKind.brand,
    this.icon,
    this.underline = true,
  });

  /// `ts-body-link-highlight-*`; `inherit` keeps the ambient size, bold +
  /// underlined (DS `font-base font-bold underline`).
  TextStyle _textStyle(BuildContext context) {
    switch (size) {
      case ValidsAnchorSize.xs:
        return ValidsTypography.bodyLinkHighlightXs;
      case ValidsAnchorSize.sm:
        return ValidsTypography.bodyLinkHighlightSm;
      case ValidsAnchorSize.md:
        return ValidsTypography.bodyLinkHighlightMd;
      case ValidsAnchorSize.lg:
        return ValidsTypography.bodyLinkHighlightLg;
      case ValidsAnchorSize.inherit:
        return DefaultTextStyle.of(context).style.copyWith(
              fontFamily: ValidsTypography.fontFamily,
              fontWeight: ValidsTypography.bold,
              decoration: TextDecoration.underline,
            );
    }
  }

  Color _color(BuildContext context) {
    if (onTap == null) return ValidsColors.textInactive;
    switch (kind) {
      case ValidsAnchorKind.brand:
        return ValidsColors.primary;
      case ValidsAnchorKind.inherit:
        return DefaultTextStyle.of(context).style.color ??
            ValidsColors.textDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _color(context);
    final TextStyle style = _textStyle(context).copyWith(
      color: color,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
      decorationColor: color,
    );
    final double iconSize =
        style.fontSize ?? ValidsTypography.textBase;

    return InkWell(
      onTap: onTap,
      borderRadius: ValidsRadius.smRadius, // rounded-sm
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: style),
          if (icon != null) ...[
            const SizedBox(width: ValidsSpacing.xs), // gap-xs
            Icon(icon, size: iconSize, color: color),
          ],
        ],
      ),
    );
  }
}

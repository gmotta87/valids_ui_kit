import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';

/// A thin rule between blocks of content.
///
/// Mirrors the design system's Separator: a `bg-soft` line, 1px thick, filling
/// the cross axis with no intrinsic margin (`h-px w-full` horizontally,
/// `h-full w-px` vertically). The [thickness] and [color] overrides are
/// convenience extensions.
class ValidsSeparator extends StatelessWidget {
  final double thickness;
  final Axis orientation;
  final Color? color;

  const ValidsSeparator({
    super.key,
    this.thickness = ValidsBorderWidth.sm,
    this.orientation = Axis.horizontal,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor =
        color ?? ValidsColors.backgroundSoft; // DS: bg-soft

    if (orientation == Axis.vertical) {
      return VerticalDivider(
        width: thickness, // no intrinsic margin, as in the DS
        thickness: thickness,
        color: effectiveColor,
      );
    }
    return Divider(
      height: thickness, // no intrinsic margin, as in the DS
      thickness: thickness,
      color: effectiveColor,
    );
  }
}

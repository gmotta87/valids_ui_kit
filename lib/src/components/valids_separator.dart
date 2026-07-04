import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class ValidsSeparator extends StatelessWidget {
  final double thickness;
  final bool isVertical;

  const ValidsSeparator({
    super.key,
    this.thickness = 1.0,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return VerticalDivider(
        thickness: thickness,
        color: ValidsColors.grey200,
      );
    }
    return Divider(
      thickness: thickness,
      color: ValidsColors.grey200,
    );
  }
}

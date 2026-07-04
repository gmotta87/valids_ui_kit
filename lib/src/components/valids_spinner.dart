import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class ValidsSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const ValidsSpinner({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? ValidsColors.primary),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../tokens/colors.dart';

enum ValidsIconButtonVariant { primary, secondary, ghost }

class ValidsIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ValidsIconButtonVariant variant;
  final double size;
  final bool isDisabled;

  const ValidsIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = ValidsIconButtonVariant.ghost,
    this.size = 24,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size),
      onPressed: isDisabled ? null : onPressed,
      style: _getButtonStyle(),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case ValidsIconButtonVariant.primary:
        return IconButton.styleFrom(
          backgroundColor: ValidsColors.primary,
          foregroundColor: ValidsColors.white,
          disabledBackgroundColor: ValidsColors.grey200,
          disabledForegroundColor: ValidsColors.grey400,
        );
      case ValidsIconButtonVariant.secondary:
        return IconButton.styleFrom(
          backgroundColor: ValidsColors.grey200,
          foregroundColor: ValidsColors.black,
        );
      case ValidsIconButtonVariant.ghost:
      default:
        return IconButton.styleFrom(
          foregroundColor: ValidsColors.primary,
        );
    }
  }
}

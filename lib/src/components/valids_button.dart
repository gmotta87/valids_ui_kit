import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum ValidsButtonVariant { primary, secondary, outline, ghost }

class ValidsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ValidsButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  const ValidsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ValidsButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: _getButtonStyle(),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ValidsColors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case ValidsButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: ValidsColors.grey200,
          foregroundColor: ValidsColors.black,
        );
      case ValidsButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: ValidsColors.primary,
          side: const BorderSide(color: ValidsColors.primary),
          elevation: 0,
        );
      case ValidsButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: ValidsColors.primary,
          elevation: 0,
        );
      case ValidsButtonVariant.primary:
      default:
        return ElevatedButton.styleFrom(
          backgroundColor: ValidsColors.primary,
          foregroundColor: ValidsColors.white,
        );
    }
  }
}

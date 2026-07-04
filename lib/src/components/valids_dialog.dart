import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';
import 'valids_button.dart';

class ValidsDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;
  final IconData? icon;

  const ValidsDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonLabel,
    this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
    this.icon,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? primaryButtonLabel,
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonLabel,
    VoidCallback? onSecondaryPressed,
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ValidsDialog(
        title: title,
        message: message,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryPressed: onSecondaryPressed,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: ValidsColors.white,
      title: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 48, color: ValidsColors.primary),
            const SizedBox(height: ValidsSpacing.md),
          ],
          Text(title, style: ValidsTypography.h3, textAlign: TextAlign.center),
        ],
      ),
      content: Text(
        message,
        style: ValidsTypography.body,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (secondaryButtonLabel != null)
          ValidsButton(
            label: secondaryButtonLabel!,
            variant: ValidsButtonVariant.ghost,
            onPressed: () {
              Navigator.of(context).pop();
              onSecondaryPressed?.call();
            },
          ),
        if (primaryButtonLabel != null)
          ValidsButton(
            label: primaryButtonLabel!,
            onPressed: () {
              Navigator.of(context).pop();
              onPrimaryPressed?.call();
            },
          ),
      ],
    );
  }
}

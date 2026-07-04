import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';

enum ValidsAlertType { success, error, warning, info }

class ValidsAlert extends StatelessWidget {
  final String title;
  final String message;
  final ValidsAlertType type;

  const ValidsAlert({
    super.key,
    required this.title,
    required this.message,
    this.type = ValidsAlertType.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ValidsSpacing.md),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getIcon(), color: _getBorderColor()),
          const SizedBox(width: ValidsSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ValidsTypography.body.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: ValidsSpacing.xs),
                Text(message, style: ValidsTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ValidsAlertType.success: return ValidsColors.success.withOpacity(0.1);
      case ValidsAlertType.error: return ValidsColors.danger.withOpacity(0.1);
      case ValidsAlertType.warning: return ValidsColors.warning.withOpacity(0.1);
      case ValidsAlertType.info: default: return ValidsColors.info.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case ValidsAlertType.success: return ValidsColors.success;
      case ValidsAlertType.error: return ValidsColors.danger;
      case ValidsAlertType.warning: return ValidsColors.warning;
      case ValidsAlertType.info: default: return ValidsColors.info;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ValidsAlertType.success: return Icons.check_circle;
      case ValidsAlertType.error: return Icons.error;
      case ValidsAlertType.warning: return Icons.warning;
      case ValidsAlertType.info: default: return Icons.info;
    }
  }
}

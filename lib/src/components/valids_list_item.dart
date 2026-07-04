import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';

class ValidsListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDisabled;

  const ValidsListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: ValidsTypography.body.copyWith(
          fontWeight: FontWeight.w600,
          color: isDisabled ? ValidsColors.grey500 : ValidsColors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: ValidsTypography.caption.copyWith(
                color: isDisabled ? ValidsColors.grey400 : ValidsColors.grey600,
              ),
            )
          : null,
      leading: leading,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: ValidsColors.grey400) : null),
      onTap: isDisabled ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ValidsSpacing.md,
        vertical: ValidsSpacing.xs,
      ),
      shape: Border(
        bottom: BorderSide(color: ValidsColors.grey200, width: 1),
      ),
    );
  }
}

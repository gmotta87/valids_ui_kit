import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// A list row with title, optional subtitle, leading and trailing content
/// (no direct DS counterpart; inherited from the legacy whitelabel kit and
/// restyled with the ValiDS tokens).
class ValidsListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool disabled;

  const ValidsListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: ValidsTypography.captionLg.copyWith(
          color:
              disabled ? ValidsColors.textInactive : ValidsColors.textDefault,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: ValidsTypography.bodySm.copyWith(
                color:
                    disabled ? ValidsColors.textInactive : ValidsColors.textSoft,
              ),
            )
          : null,
      leading: leading,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right,
                  color: ValidsColors.textInactive)
              : null),
      onTap: disabled ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ValidsSpacing.md,
        vertical: ValidsSpacing.xs2,
      ),
      shape: const Border(
        bottom: BorderSide(
          color: ValidsColors.borderDefault,
          width: ValidsBorderWidth.sm,
        ),
      ),
    );
  }
}

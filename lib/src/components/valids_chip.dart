import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';

class ValidsChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final IconData? leadingIcon;

  const ValidsChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.onDeleted,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      onDeleted: onDeleted,
      avatar: leadingIcon != null ? Icon(leadingIcon, size: 16) : null,
      backgroundColor: ValidsColors.grey100,
      selectedColor: ValidsColors.primary.withOpacity(0.2),
      checkmarkColor: ValidsColors.primary,
      labelStyle: ValidsTypography.caption.copyWith(
        color: isSelected ? ValidsColors.primary : ValidsColors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? ValidsColors.primary : ValidsColors.grey300,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: ValidsSpacing.xs),
    );
  }
}

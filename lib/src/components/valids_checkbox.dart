import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';

class ValidsCheckbox extends StatelessWidget {
  final bool value;
  final String? label;
  final ValueChanged<bool?>? onChanged;
  final bool isDisabled;

  const ValidsCheckbox({
    super.key,
    required this.value,
    this.label,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget checkbox = Checkbox(
      value: value,
      onChanged: isDisabled ? null : onChanged,
      activeColor: ValidsColors.primary,
      checkColor: ValidsColors.white,
      side: const BorderSide(color: ValidsColors.grey400, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    if (label == null) return checkbox;

    return InkWell(
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          const SizedBox(width: ValidsSpacing.xs),
          Text(
            label!,
            style: ValidsTypography.body.copyWith(
              color: isDisabled ? ValidsColors.grey500 : ValidsColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

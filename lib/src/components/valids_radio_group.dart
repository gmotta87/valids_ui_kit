import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/spacing.dart';

class ValidsRadioOption<T> {
  final T value;
  final String label;

  ValidsRadioOption({required this.value, required this.label});
}

class ValidsRadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final List<ValidsRadioOption<T>> options;
  final ValueChanged<T?> onChanged;
  final bool isDisabled;
  final Axis direction;

  const ValidsRadioGroup({
    super.key,
    required this.groupValue,
    required this.options,
    required this.onChanged,
    this.isDisabled = false,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final children = options.map((option) {
      return InkWell(
        onTap: isDisabled ? null : () => onChanged(option.value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: ValidsSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<T>(
                value: option.value,
                groupValue: groupValue,
                onChanged: isDisabled ? null : onChanged,
                activeColor: ValidsColors.primary,
              ),
              const SizedBox(width: ValidsSpacing.xs),
              Text(
                option.label,
                style: ValidsTypography.body.copyWith(
                  color: isDisabled ? ValidsColors.grey500 : ValidsColors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    if (direction == Axis.horizontal) {
      return Wrap(
        spacing: ValidsSpacing.md,
        children: children,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

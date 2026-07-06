import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_switch.dart';

class ValidsSwitchOption<T> {
  final T value;
  final String label;
  final String? description;
  final bool disabled;

  const ValidsSwitchOption({
    required this.value,
    required this.label,
    this.description,
    this.disabled = false,
  });
}

/// A group of switches.
///
/// Mirrors the design system's `SwitchGroup` (`ds-switch-group`): a vertical
/// flex of [ValidsSwitch]es with a `gap-md` (16px) between them. The optional
/// group [label]/[description], the horizontal [orientation] and the
/// group-level [disabled] flag are extras kept from the Flutter API.
class ValidsSwitchGroup<T> extends StatelessWidget {
  final String? label;
  final String? description;
  final List<ValidsSwitchOption<T>> options;
  final Set<T> value;
  final ValueChanged<Set<T>>? onValueChange;
  final Axis orientation;
  final bool disabled;

  const ValidsSwitchGroup({
    super.key,
    this.label,
    this.description,
    required this.options,
    required this.value,
    required this.onValueChange,
    this.orientation = Axis.vertical,
    this.disabled = false,
  });

  bool get _isGroupDisabled => disabled || onValueChange == null;

  void _toggle(T optionValue) {
    final next = Set<T>.of(value);
    if (!next.add(optionValue)) next.remove(optionValue);
    onValueChange?.call(next);
  }

  Widget _buildOption(ValidsSwitchOption<T> option) {
    final bool isDisabled = _isGroupDisabled || option.disabled;

    return ValidsSwitch(
      checked: value.contains(option.value),
      onCheckedChange: isDisabled ? null : (_) => _toggle(option.value),
      label: option.label,
      description: option.description,
      disabled: isDisabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final optionWidgets = options.map(_buildOption).toList();

    // DS: `flex flex-col gap-md` (16px between switches).
    final Widget optionsWidget = orientation == Axis.horizontal
        ? Wrap(
            spacing: ValidsSpacing.md,
            runSpacing: ValidsSpacing.md,
            children: optionWidgets,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < optionWidgets.length; i++) ...[
                if (i > 0) const SizedBox(height: ValidsSpacing.md),
                optionWidgets[i],
              ],
            ],
          );

    if (label == null && description == null) return optionsWidget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: ValidsTypography.captionLg.copyWith(
              color: _isGroupDisabled
                  ? ValidsColors.textInactive
                  : ValidsColors.textDefault,
            ),
          ),
        if (description != null)
          Text(
            description!,
            style: ValidsTypography.bodySm.copyWith(
              color: _isGroupDisabled
                  ? ValidsColors.textInactive
                  : ValidsColors.textSoft,
            ),
          ),
        const SizedBox(height: ValidsSpacing.xs),
        optionsWidget,
      ],
    );
  }
}

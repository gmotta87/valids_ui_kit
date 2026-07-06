import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_checkbox.dart';

/// One selectable option inside a [ValidsCheckboxGroup].
///
/// Mirrors a `ds-checkbox` child: per-item [description], [disabled] and
/// [error] states are supported, matching the DS Checkbox API.
class ValidsCheckboxOption<T> {
  final T value;
  final String label;
  final String? description;
  final bool disabled;

  /// Applies the DS error state to this item's checkbox.
  final bool error;

  const ValidsCheckboxOption({
    required this.value,
    required this.label,
    this.description,
    this.disabled = false,
    this.error = false,
  });
}

/// A group of checkboxes mirroring `ds-checkbox-group`.
///
/// DS layout: `flex flex-wrap gap-md`, stacked as a column when
/// [orientation] is vertical (the default). A group-level [disabled]
/// disables every item.
///
/// Extras beyond the DS: the optional [label]/[description] header (the DS
/// relies on external labelling via `aria-label`), the typed
/// [ValidsCheckboxOption] list instead of arbitrary children, and the
/// `Set`-based [value] instead of `string[]`.
class ValidsCheckboxGroup<T> extends StatelessWidget {
  final String? label;
  final String? description;
  final List<ValidsCheckboxOption<T>> options;
  final Set<T> value;
  final ValueChanged<Set<T>>? onValueChange;
  final Axis orientation;
  final bool disabled;

  const ValidsCheckboxGroup({
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

  Widget _buildOption(ValidsCheckboxOption<T> option) {
    final bool isDisabled = _isGroupDisabled || option.disabled;

    return ValidsCheckbox(
      checked: value.contains(option.value),
      onCheckedChange: isDisabled ? null : (_) => _toggle(option.value),
      disabled: isDisabled,
      error: option.error,
      label: option.label,
      description: option.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    // `flex flex-wrap gap-md data-[orientation=vertical]:flex-col`.
    final Widget optionsWidget = Wrap(
      direction: orientation,
      spacing: ValidsSpacing.md,
      runSpacing: ValidsSpacing.md,
      children: options.map(_buildOption).toList(),
    );

    if (label == null && description == null) return optionsWidget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: ValidsTypography.bodyMd.copyWith(
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
        const SizedBox(height: ValidsSpacing.xs2),
        optionsWidget,
      ],
    );
  }
}

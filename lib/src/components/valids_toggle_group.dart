import 'package:flutter/material.dart';
import '../tokens/spacing.dart';
import 'valids_toggle.dart';

enum ValidsToggleGroupMode { single, multiple }

class ValidsToggleGroupItem<T> {
  final T value;
  final IconData? icon;
  final String? label;
  final bool disabled;

  const ValidsToggleGroupItem({
    required this.value,
    this.icon,
    this.label,
    this.disabled = false,
  }) : assert(
         icon != null || label != null,
         'ValidsToggleGroupItem requires an icon and/or a label',
       );
}

/// A group of toggle buttons with single or multiple selection.
///
/// Mirrors the design system's `ToggleGroup` (`ds-toggle-group`): a `gap-xs`
/// flex of [ValidsToggle]s (a column when [orientation] is vertical). As in
/// the DS, single mode also deselects: pressing the selected item clears the
/// value (the callback receives `null`).
class ValidsToggleGroup<T> extends StatelessWidget {
  final List<ValidsToggleGroupItem<T>> items;
  final ValidsToggleGroupMode mode;
  final T? value;
  final ValueChanged<T?>? onValueChange;
  final Set<T> values;
  final ValueChanged<Set<T>>? onValuesChange;
  final bool disabled;
  final Axis orientation;

  const ValidsToggleGroup.single({
    super.key,
    required this.items,
    required this.value,
    required this.onValueChange,
    this.disabled = false,
    this.orientation = Axis.horizontal,
  }) : mode = ValidsToggleGroupMode.single,
       values = const <Never>{},
       onValuesChange = null;

  const ValidsToggleGroup.multiple({
    super.key,
    required this.items,
    required this.values,
    required this.onValuesChange,
    this.disabled = false,
    this.orientation = Axis.horizontal,
  }) : mode = ValidsToggleGroupMode.multiple,
       value = null,
       onValueChange = null;

  bool get _isGroupDisabled =>
      disabled ||
      (mode == ValidsToggleGroupMode.single
          ? onValueChange == null
          : onValuesChange == null);

  bool _isSelected(ValidsToggleGroupItem<T> item) =>
      mode == ValidsToggleGroupMode.single
      ? value == item.value
      : values.contains(item.value);

  void _handleTap(ValidsToggleGroupItem<T> item) {
    if (mode == ValidsToggleGroupMode.single) {
      // DS single mode: pressing the selected item deselects it.
      onValueChange?.call(value == item.value ? null : item.value);
    } else {
      final next = Set<T>.of(values);
      if (!next.add(item.value)) next.remove(item.value);
      onValuesChange?.call(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      for (final item in items)
        ValidsToggle(
          icon: item.icon,
          label: item.label,
          pressed: _isSelected(item),
          disabled: _isGroupDisabled || item.disabled,
          onPressedChange: (_) => _handleTap(item),
        ),
    ];

    // DS: `flex gap-xs data-[orientation=vertical]:flex-col`.
    if (orientation == Axis.horizontal) {
      return Wrap(
        spacing: ValidsSpacing.xs,
        runSpacing: ValidsSpacing.xs,
        children: buttons,
      );
    }

    // Vertical: all pills share the width of the widest, stacked with a gap.
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(height: ValidsSpacing.xs),
            buttons[i],
          ],
        ],
      ),
    );
  }
}

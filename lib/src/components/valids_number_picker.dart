import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'internal/field_chrome.dart';

/// Compact select mirroring the design system's `ds-number-picker`:
/// a 40px trigger (`h-10 px-xs`, min width `w-20`) showing the current value
/// in `ts-body-md` with a chevron, opening a scrollable list of discrete
/// [items], with [value] / [onValueChange], [disabled] and [error] states.
///
/// Extras beyond the DS API, kept from the previous implementation:
/// [label] rendered above the trigger, [placeholder] and the
/// [ValidsNumberPicker.range] factory.
///
/// Mobile adaptation: the options open in a modal bottom sheet instead of an
/// anchored popup, capped at the DS list height (`max-h-108`).
class ValidsNumberPicker extends StatefulWidget {
  final List<String> items;
  final String? value;
  final ValueChanged<String>? onValueChange;
  final String? label;
  final String? placeholder;
  final bool disabled;
  final bool error;

  const ValidsNumberPicker({
    super.key,
    required this.items,
    this.value,
    this.onValueChange,
    this.label,
    this.placeholder,
    this.disabled = false,
    this.error = false,
  });

  /// Builds a picker whose items are the numbers of a min/max/step range.
  factory ValidsNumberPicker.range({
    Key? key,
    required num min,
    required num max,
    num step = 1,
    String? value,
    ValueChanged<String>? onValueChange,
    String? label,
    String? placeholder,
    bool disabled = false,
    bool error = false,
  }) {
    final List<String> items = [];
    for (num v = min; v <= max; v += step) {
      items.add(v == v.roundToDouble() ? v.toInt().toString() : v.toString());
    }
    return ValidsNumberPicker(
      key: key,
      items: items,
      value: value,
      onValueChange: onValueChange,
      label: label,
      placeholder: placeholder,
      disabled: disabled,
      error: error,
    );
  }

  @override
  State<ValidsNumberPicker> createState() => _ValidsNumberPickerState();
}

class _ValidsNumberPickerState extends State<ValidsNumberPicker> {
  /// Trigger: `h-10` (40px) with min width `w-20` (80px).
  static const double _triggerHeight = ValidsSpacing.xl2;
  static const double _triggerMinWidth = ValidsSpacing.xl6;

  /// DS list height limit: `max-h-108` (× 4px).
  static const double _listMaxHeight = 432;

  bool _isOpen = false;
  bool _hovered = false;

  bool get _isDisabled => widget.disabled || widget.onValueChange == null;

  Future<void> _openList() async {
    setState(() => _isOpen = true);
    final String? picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: ValidsColors.backgroundDefault,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ValidsRadius.lg),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null) ...[
                Padding(
                  padding: const EdgeInsets.all(ValidsSpacing.md),
                  child: Text(
                    widget.label!,
                    style: ValidsTypography.headingSm.copyWith(
                      color: ValidsColors.textDefault,
                    ),
                  ),
                ),
                const Divider(
                  height: ValidsBorderWidth.sm,
                  color: ValidsColors.borderDefault,
                ),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: _listMaxHeight),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final item in widget.items)
                      FieldOptionTile(
                        title: item,
                        selected: item == widget.value,
                        onTap: () => Navigator.of(sheetContext).pop(item),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    if (mounted) {
      setState(() => _isOpen = false);
    }
    if (picked != null) widget.onValueChange?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.value != null && widget.value!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          // Extra: label above the trigger (the DS number picker is
          // unlabeled; DataTable pairs it with an external label).
          Text(
            widget.label!,
            style: ValidsTypography.bodySm.copyWith(
              color: widget.error && !_isDisabled
                  ? ValidsColors.dangerDark
                  : _isDisabled
                      ? ValidsColors.textInactive
                      : ValidsColors.textSoft,
            ),
          ),
          const SizedBox(height: ValidsSpacing.xs2),
        ],
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: _isDisabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _isDisabled ? null : _openList,
            child: FieldWrapper(
              height: _triggerHeight,
              constraints: const BoxConstraints(minWidth: _triggerMinWidth),
              // `px-xs`.
              padding:
                  const EdgeInsets.symmetric(horizontal: ValidsSpacing.xs),
              hovered: _hovered,
              focused: _isOpen,
              invalid: widget.error,
              disabled: _isDisabled,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      hasValue
                          ? widget.value!
                          : (widget.placeholder ?? 'Selecione'),
                      style: ValidsTypography.bodyMd.copyWith(
                        color: !hasValue || _isDisabled
                            ? ValidsColors.textInactive
                            : ValidsColors.textDefault,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: ValidsSpacing.xs),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: fieldTransitionDuration,
                    curve: Curves.easeOut,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: ValidsSpacing.lg,
                      color: _isDisabled
                          ? ValidsColors.textInactive
                          : ValidsColors.textSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

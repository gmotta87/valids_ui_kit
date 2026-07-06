import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'internal/field_chrome.dart';
import 'valids_spinner.dart';

/// An option displayed by [ValidsSelect].
class ValidsSelectItem<T> {
  final T value;
  final String label;
  final String? description;
  final bool disabled;

  const ValidsSelectItem({
    required this.value,
    required this.label,
    this.description,
    this.disabled = false,
  });
}

/// Single-choice select mirroring the design system's `ds-select`:
/// a 56px `select-wrapper` trigger with floating [label], selected value in
/// `ts-body-md`, rotating chevron, optional [startAdornment], clear button
/// ([clearable]) and support/error text below ([description] /
/// [errorMessage]). Items render as `ds-select-item` rows (title +
/// optional description); [loading] shows a spinner in the options list.
///
/// Mobile adaptation: the options open in a modal bottom sheet instead of an
/// anchored popup, capped at the DS list height (`max-h-108`).
class ValidsSelect<T> extends StatefulWidget {
  final String? label;
  final String? description;
  final String? placeholder;
  final String? errorMessage;
  final Widget? startAdornment;
  final bool disabled;
  final bool loading;
  final bool clearable;
  final List<ValidsSelectItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onValueChange;

  const ValidsSelect({
    super.key,
    required this.items,
    this.label,
    this.description,
    this.placeholder,
    this.errorMessage,
    this.startAdornment,
    this.disabled = false,
    this.loading = false,
    this.clearable = false,
    this.value,
    this.onValueChange,
  });

  @override
  State<ValidsSelect<T>> createState() => _ValidsSelectState<T>();
}

class _ValidsSelectState<T> extends State<ValidsSelect<T>> {
  /// DS list height limits: `max-h-108` / `min-h-18` (× 4px).
  static const double _listMaxHeight = 432;
  static const double _listMinHeight = 72;

  bool _isOpen = false;
  bool _hovered = false;

  bool get _isDisabled =>
      widget.disabled || (widget.onValueChange == null && !widget.loading);

  bool get _invalid => widget.errorMessage != null;

  ValidsSelectItem<T>? get _selectedItem {
    for (final item in widget.items) {
      if (item.value == widget.value) {
        return item;
      }
    }
    return null;
  }

  /// The label floats when there is a value, the popup is open or a start
  /// adornment is present (like the DS `select-floating-label`).
  bool get _floated =>
      _selectedItem != null || _isOpen || widget.startAdornment != null;

  Future<void> _openSheet() async {
    setState(() => _isOpen = true);
    await showModalBottomSheet<void>(
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
                constraints: const BoxConstraints(
                  minHeight: _listMinHeight,
                  maxHeight: _listMaxHeight,
                ),
                child: widget.loading
                    ? const _LoadingList()
                    : ListView(
                        shrinkWrap: true,
                        children: widget.items
                            .map(
                              (item) => FieldOptionTile(
                                title: item.label,
                                description: item.description,
                                selected: item.value == widget.value,
                                disabled: item.disabled,
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  widget.onValueChange?.call(item.value);
                                },
                              ),
                            )
                            .toList(),
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
  }

  Widget _buildValue() {
    final selectedItem = _selectedItem;
    if (selectedItem != null) {
      return Text(
        selectedItem.label,
        style: ValidsTypography.bodyMd.copyWith(
          color: _isDisabled
              ? ValidsColors.textInactive
              : ValidsColors.textDefault,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    // DS keeps the placeholder transparent while the label rests over it;
    // it only becomes visible once the label floats.
    if (_floated && widget.placeholder != null) {
      return Text(
        widget.placeholder!,
        style: ValidsTypography.bodyMd.copyWith(
          color: ValidsColors.textInactive,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.clearable && _selectedItem != null && !_isDisabled) ...[
          GestureDetector(
            onTap: () => widget.onValueChange?.call(null),
            child: const Icon(
              Icons.close,
              size: ValidsSpacing.lg,
              color: ValidsColors.textSoft,
            ),
          ),
          const SizedBox(width: ValidsSpacing.xs),
        ],
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: _isDisabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _isDisabled ? null : _openSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FieldWrapper(
                  // `h-14` (56px).
                  height: ValidsSpacing.xl4,
                  hovered: _hovered,
                  focused: _isOpen,
                  invalid: _invalid,
                  disabled: _isDisabled,
                  child: Row(
                    children: [
                      if (widget.startAdornment != null) ...[
                        FieldAdornment(
                          disabled: _isDisabled,
                          child: widget.startAdornment!,
                        ),
                        const SizedBox(width: ValidsSpacing.xs),
                      ],
                      Expanded(child: _buildValue()),
                      const SizedBox(width: ValidsSpacing.xs),
                      _buildTrailing(),
                    ],
                  ),
                ),
                if (widget.label != null)
                  FieldFloatingLabel(
                    label: widget.label!,
                    floated: _floated,
                    invalid: _invalid,
                    disabled: _isDisabled,
                  ),
              ],
            ),
          ),
        ),
        FieldSupport(
          description: widget.description,
          errorMessage: widget.errorMessage,
        ),
      ],
    );
  }
}

/// Loading state of the options list (`ds-dropdown-loading-spinner`):
/// a centered spinner with `py-lg`.
class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ValidsSpacing.lg),
        child: ValidsSpinner(),
      ),
    );
  }
}

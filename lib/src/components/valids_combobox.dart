import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'internal/field_chrome.dart';
import 'valids_calendar.dart';
import 'valids_chip.dart';

/// An option displayed by [ValidsCombobox].
class ValidsComboboxItem<T> {
  final T value;
  final String label;
  final String? description;
  final bool disabled;

  const ValidsComboboxItem({
    required this.value,
    required this.label,
    this.description,
    this.disabled = false,
  });
}

/// A searchable select field mirroring the ValiDS `ds-combobox`: floating
/// label, neutral chips (with "+N" overflow) in multiple mode, clear button
/// and rotating chevron trigger, support text, and options with checkbox
/// indicators / highlight in `brand/10`. Options open in a modal bottom
/// sheet with a filter input (mobile stand-in for the DS popup).
class ValidsCombobox<T> extends StatefulWidget {
  final String? label;
  final String? description;
  final String? placeholder;
  final String? errorMessage;
  final bool disabled;
  final bool loading;

  /// Leading content rendered at the start of the field.
  final Widget? startAdornment;

  /// Maximum number of chips shown before collapsing the rest into a "+N"
  /// overflow indicator (DS `maxVisibleChips`).
  final int maxVisibleChips;

  /// Shows a clear button when there is a selection. The DS always renders
  /// it; set to `false` to hide.
  final bool clearable;

  /// Enables multiple selection, rendering the values as chips in the field.
  final bool multiple;
  final List<ValidsComboboxItem<T>> items;

  /// Selected value when [multiple] is `false`.
  final T? value;
  final ValueChanged<T?>? onValueChange;

  /// Selected values when [multiple] is `true`.
  final List<T> values;
  final ValueChanged<List<T>>? onValuesChange;

  /// Shows a "select all" row when in multiple mode.
  final bool showSelectAll;
  final String searchPlaceholder;

  /// Message shown when the filter yields no options (DS `emptyMessage`).
  final String emptyMessage;

  const ValidsCombobox({
    super.key,
    required this.items,
    this.label,
    this.placeholder,
    this.errorMessage,
    this.disabled = false,
    this.loading = false,
    this.clearable = true,
    this.multiple = false,
    this.value,
    this.onValueChange,
    this.values = const [],
    this.onValuesChange,
    this.showSelectAll = false,
    this.searchPlaceholder = 'Buscar...',
    this.emptyMessage = 'Nenhum resultado encontrado',
    this.description,
    this.startAdornment,
    this.maxVisibleChips = 2,
  });

  @override
  State<ValidsCombobox<T>> createState() => _ValidsComboboxState<T>();
}

class _ValidsComboboxState<T> extends State<ValidsCombobox<T>> {
  bool _isOpen = false;

  bool get _isMultiple => widget.multiple;

  bool get _isDisabled =>
      widget.disabled ||
      widget.loading ||
      (_isMultiple
          ? widget.onValuesChange == null
          : widget.onValueChange == null);

  ValidsComboboxItem<T>? _itemForValue(T? value) {
    for (final item in widget.items) {
      if (item.value == value) {
        return item;
      }
    }
    return null;
  }

  Future<void> _openSheet() async {
    setState(() => _isOpen = true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ValidsColors.backgroundDefault,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ValidsRadius.lg),
        ),
      ),
      builder: (sheetContext) => _ComboboxSheet<T>(
        title: widget.label ?? 'Selecione',
        items: widget.items,
        isMultiple: _isMultiple,
        loading: widget.loading,
        showSelectAll: widget.showSelectAll,
        searchPlaceholder: widget.searchPlaceholder,
        emptyMessage: widget.emptyMessage,
        initialValue: widget.value,
        initialValues: widget.values,
        onValueChange: widget.onValueChange,
        onValuesChange: widget.onValuesChange,
      ),
    );
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  void _removeValue(T value) {
    final updated = List<T>.of(widget.values)..remove(value);
    widget.onValuesChange?.call(updated);
  }

  bool get _hasSelection =>
      _isMultiple ? widget.values.isNotEmpty : widget.value != null;

  bool get _showClear => widget.clearable && !_isDisabled && _hasSelection;

  void _clear() {
    if (_isMultiple) {
      widget.onValuesChange?.call(<T>[]);
    } else {
      widget.onValueChange?.call(null);
    }
  }

  /// DS `ds-combobox-overflow-chip`: a plain "+N" text in `ts-body-md`.
  Widget _buildOverflowChip(int count) {
    return Text(
      '+$count',
      style: ValidsTypography.bodyMd.copyWith(
        color:
            _isDisabled ? ValidsColors.textInactive : ValidsColors.textDefault,
      ),
    );
  }

  Widget _buildChip(ValidsComboboxItem<T> item) {
    return ValidsChip(
      label: item.label,
      kind: ValidsChipKind.neutral,
      onDeleted: _isDisabled ? null : () => _removeValue(item.value),
    );
  }

  Widget _buildFieldContent(bool showPlaceholder) {
    final placeholderText = Text(
      showPlaceholder ? (widget.placeholder ?? '') : '',
      style: ValidsTypography.bodyMd.copyWith(
        color: ValidsColors.textInactive,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (_isMultiple) {
      if (widget.values.isEmpty) return placeholderText;
      final selectedItems = widget.values
          .map(_itemForValue)
          .whereType<ValidsComboboxItem<T>>()
          .toList();
      final visible = selectedItems.take(widget.maxVisibleChips).toList();
      final int overflow = selectedItems.length - visible.length;
      return Wrap(
        spacing: ValidsSpacing.xs2,
        runSpacing: ValidsSpacing.xs2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...visible.map(_buildChip),
          if (overflow > 0) _buildOverflowChip(overflow),
        ],
      );
    }

    final selectedItem = _itemForValue(widget.value);
    if (selectedItem == null) return placeholderText;
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

  @override
  Widget build(BuildContext context) {
    final bool hasValue = _hasSelection;
    // DS shows the placeholder only while the label is floated (focus/open);
    // with no label it is always visible.
    final bool showPlaceholder = widget.label == null || _isOpen;
    final Color iconColor =
        _isDisabled ? ValidsColors.textInactive : ValidsColors.textSoft;

    return ValidsFieldShell(
      label: widget.label,
      description: widget.description,
      errorMessage: widget.errorMessage,
      disabled: _isDisabled,
      isOpen: _isOpen,
      hasValue: hasValue,
      onTap: _openSheet,
      startAdornment: widget.startAdornment,
      endAdornments: [
        if (_showClear)
          InkWell(
            onTap: _clear,
            customBorder: const CircleBorder(),
            child: Icon(
              Icons.close,
              size: ValidsSpacing.lg,
              color: ValidsColors.textSoft,
              semanticLabel: widget.label != null
                  ? 'Limpar ${widget.label}'
                  : 'Limpar seleção',
            ),
          ),
        AnimatedRotation(
          turns: _isOpen ? 0.5 : 0,
          duration: kValidsFieldAnimationDuration,
          child: Icon(
            Icons.keyboard_arrow_down,
            size: ValidsSpacing.lg,
            color: iconColor,
          ),
        ),
      ],
      child: _buildFieldContent(showPlaceholder),
    );
  }
}

class _ComboboxSheet<T> extends StatefulWidget {
  final String title;
  final List<ValidsComboboxItem<T>> items;
  final bool isMultiple;
  final bool loading;
  final bool showSelectAll;
  final String searchPlaceholder;
  final String emptyMessage;
  final T? initialValue;
  final List<T> initialValues;
  final ValueChanged<T?>? onValueChange;
  final ValueChanged<List<T>>? onValuesChange;

  const _ComboboxSheet({
    required this.title,
    required this.items,
    required this.isMultiple,
    required this.loading,
    required this.showSelectAll,
    required this.searchPlaceholder,
    required this.emptyMessage,
    required this.initialValue,
    required this.initialValues,
    required this.onValueChange,
    required this.onValuesChange,
  });

  @override
  State<_ComboboxSheet<T>> createState() => _ComboboxSheetState<T>();
}

class _ComboboxSheetState<T> extends State<_ComboboxSheet<T>> {
  /// DS item highlight: `bg-brand-secondary-default/10`.
  static const double _highlightAlpha = 0.10;

  /// DS popup list max height (`max-h-108` = 108 × 4px).
  static const double _listMaxHeight = 432;

  String _query = '';
  late List<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List<T>.of(widget.initialValues);
  }

  List<ValidsComboboxItem<T>> get _filteredItems {
    if (_query.isEmpty) return widget.items;
    final query = _query.toLowerCase();
    return widget.items
        .where((item) => item.label.toLowerCase().contains(query))
        .toList();
  }

  List<ValidsComboboxItem<T>> get _selectableFiltered =>
      _filteredItems.where((item) => !item.disabled).toList();

  bool get _allSelected =>
      _selectableFiltered.isNotEmpty &&
      _selectableFiltered
          .every((item) => _selectedValues.contains(item.value));

  bool get _someSelected =>
      _selectableFiltered.any((item) => _selectedValues.contains(item.value));

  void _toggleValue(ValidsComboboxItem<T> item) {
    setState(() {
      if (_selectedValues.contains(item.value)) {
        _selectedValues.remove(item.value);
      } else {
        _selectedValues.add(item.value);
      }
    });
    widget.onValuesChange?.call(List<T>.of(_selectedValues));
  }

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        for (final item in _selectableFiltered) {
          _selectedValues.remove(item.value);
        }
      } else {
        for (final item in _selectableFiltered) {
          if (!_selectedValues.contains(item.value)) {
            _selectedValues.add(item.value);
          }
        }
      }
    });
    widget.onValuesChange?.call(List<T>.of(_selectedValues));
  }

  /// DS `ds-combobox-empty`: `px-md py-md ts-body-md text-soft`.
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(ValidsSpacing.md),
      child: Text(
        widget.emptyMessage,
        style: ValidsTypography.bodyMd.copyWith(color: ValidsColors.textSoft),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(ValidsSpacing.md),
      child: Center(
        child: SizedBox(
          width: ValidsSpacing.lg,
          height: ValidsSpacing.lg,
          child: CircularProgressIndicator(
            strokeWidth: ValidsBorderWidth.md,
            valueColor: AlwaysStoppedAnimation<Color>(ValidsColors.primary),
          ),
        ),
      ),
    );
  }

  /// DS `ds-combobox-item-indicator`: filled/blank checkbox in `size-lg`,
  /// `icon-soft` when unchecked and brand when checked.
  Widget _buildIndicator({
    required bool selected,
    required bool disabled,
    bool indeterminate = false,
  }) {
    final IconData icon = selected
        ? Icons.check_box
        : indeterminate
            ? Icons.indeterminate_check_box
            : Icons.check_box_outline_blank;
    final Color color = disabled
        ? ValidsColors.textInactive
        : (selected || indeterminate)
            ? ValidsColors.primary
            : ValidsColors.textSoft;
    return Icon(icon, size: ValidsSpacing.lg, color: color);
  }

  /// DS `ds-combobox-select-all`: `px-md py-xs`, bottom border
  /// `border-default`, indicator + `ts-body-md` text.
  Widget _buildSelectAll() {
    final bool allSelected = _allSelected;
    final bool indeterminate = !allSelected && _someSelected;
    return InkWell(
      onTap: _selectableFiltered.isEmpty ? null : _toggleSelectAll,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ValidsSpacing.md,
          vertical: ValidsSpacing.xs,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ValidsColors.borderDefault,
              width: ValidsBorderWidth.sm,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildIndicator(
              selected: allSelected,
              indeterminate: indeterminate,
              disabled: _selectableFiltered.isEmpty,
            ),
            const SizedBox(width: ValidsSpacing.xs),
            Text(
              'Selecionar tudo',
              style: ValidsTypography.bodyMd.copyWith(
                color: ValidsColors.textDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// DS `ds-combobox-item`: `px-md py-xs gap-xs ts-body-md`; highlighted /
  /// selected rows use `bg-brand-secondary-default/10`; title in
  /// `text-default`, description in `ts-body-sm text-soft`; disabled items
  /// in `text-inactive`. Multiple mode adds the checkbox indicator.
  Widget _buildOption(ValidsComboboxItem<T> item) {
    if (!widget.isMultiple) {
      return FieldOptionTile(
        title: item.label,
        description: item.description,
        selected: item.value == widget.initialValue,
        disabled: item.disabled,
        onTap: () {
          Navigator.of(context).pop();
          widget.onValueChange?.call(item.value);
        },
      );
    }

    final bool isSelected = _selectedValues.contains(item.value);
    final Color titleColor =
        item.disabled ? ValidsColors.textInactive : ValidsColors.textDefault;
    final Color descriptionColor =
        item.disabled ? ValidsColors.textInactive : ValidsColors.textSoft;

    return InkWell(
      onTap: item.disabled ? null : () => _toggleValue(item),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ValidsSpacing.md,
          vertical: ValidsSpacing.xs,
        ),
        color: isSelected
            ? ValidsColors.primary.withValues(alpha: _highlightAlpha)
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: ValidsSpacing.xs2),
              child: _buildIndicator(
                selected: isSelected,
                disabled: item.disabled,
              ),
            ),
            const SizedBox(width: ValidsSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: ValidsTypography.bodyMd.copyWith(color: titleColor),
                  ),
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: ValidsTypography.bodySm.copyWith(
                        color: descriptionColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: ValidsRadius.mdRadius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextField(
      autofocus: false,
      onChanged: (query) => setState(() => _query = query),
      style: ValidsTypography.bodyMd.copyWith(
        color: ValidsColors.textDefault,
      ),
      cursorColor: ValidsColors.primary,
      decoration: InputDecoration(
        hintText: widget.searchPlaceholder,
        hintStyle: ValidsTypography.bodyMd.copyWith(
          color: ValidsColors.textInactive,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: ValidsSpacing.lg,
          color: ValidsColors.textSoft,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ValidsSpacing.md,
          vertical: ValidsSpacing.xs,
        ),
        enabledBorder:
            border(ValidsColors.borderSoft, ValidsBorderWidth.sm),
        focusedBorder:
            border(ValidsColors.borderBold, ValidsBorderWidth.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(ValidsSpacing.md),
              child: Text(
                widget.title,
                style: ValidsTypography.headingSm.copyWith(
                  color: ValidsColors.textDefault,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ValidsSpacing.md,
              ),
              child: _buildSearchField(),
            ),
            const SizedBox(height: ValidsSpacing.xs),
            if (widget.isMultiple && widget.showSelectAll) _buildSelectAll(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: _listMaxHeight),
              child: widget.loading
                  ? _buildLoadingState()
                  : filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          shrinkWrap: true,
                          children: filtered.map(_buildOption).toList(),
                        ),
            ),
            const SizedBox(height: ValidsSpacing.xs),
          ],
        ),
      ),
    );
  }
}

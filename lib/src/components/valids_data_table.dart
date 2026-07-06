import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_button.dart';
import 'valids_checkbox.dart';
import 'valids_icon_button.dart';
import 'valids_pagination.dart';
import 'valids_skeleton.dart';

/// Visual variant of a [ValidsDataTable], matching the ValiDS design system.
enum ValidsDataTableVariant { solid, striped }

class ValidsDataColumn<T> {
  final String label;
  final Widget Function(T item) cellBuilder;
  final int flex;

  /// Fixed column width in logical pixels. When set, overrides [flex].
  final double? width;
  final bool sortable;
  final Comparator<T>? comparator;
  final void Function(bool ascending)? onSort;

  const ValidsDataColumn({
    required this.label,
    required this.cellBuilder,
    this.flex = 1,
    this.width,
    this.sortable = false,
    this.comparator,
    this.onSort,
  });
}

/// A rich data table mirroring the design system's DataTable
/// (`ds-data-table`): Table chrome (`rounded-sm` `border-default` outline,
/// `bg-soft` header, striped variant, brand-softer selected rows), sortable
/// heads with a ghost/neutral sort button, checkbox selection with
/// "select all" (indeterminate) and error state, loading skeletons, an empty
/// state and built-in pagination rendered in a bottom Controls bar.
class ValidsDataTable<T> extends StatefulWidget {
  final List<ValidsDataColumn<T>> columns;
  final List<T> items;
  final bool selectable;
  final Set<T>? selectedItems;
  final ValueChanged<Set<T>>? onSelectionChanged;

  /// Renders the selection checkboxes in an error state.
  final bool selectionError;
  final String? selectionErrorMessage;
  final bool loading;

  /// Message shown when there are no rows
  /// (`ds-data-table-body` empty state).
  final String emptyMessage;
  final int? rowsPerPage;
  final ValidsDataTableVariant variant;

  const ValidsDataTable({
    super.key,
    required this.columns,
    required this.items,
    this.selectable = false,
    this.selectedItems,
    this.onSelectionChanged,
    this.selectionError = false,
    this.selectionErrorMessage,
    this.loading = false,
    this.emptyMessage = 'Nenhum resultado encontrado.',
    this.rowsPerPage,
    this.variant = ValidsDataTableVariant.solid,
  });

  @override
  State<ValidsDataTable<T>> createState() => _ValidsDataTableState<T>();
}

class _ValidsDataTableState<T> extends State<ValidsDataTable<T>> {
  int? _sortIndex;
  bool _ascending = true;
  int _page = 0;

  /// Width of the leading checkbox slot.
  static const double _checkboxSlotWidth = ValidsSpacing.xl2;

  bool get _striped => widget.variant == ValidsDataTableVariant.striped;

  Set<T> get _selected => widget.selectedItems ?? <T>{};

  BorderSide get _rowDivider => const BorderSide(
        color: ValidsColors.borderDefault,
        width: ValidsBorderWidth.sm,
      );

  List<T> _sortedItems() {
    final List<T> items = List<T>.of(widget.items);
    final int? index = _sortIndex;
    if (index == null || index >= widget.columns.length) return items;
    final Comparator<T>? comparator = widget.columns[index].comparator;
    if (comparator == null) return items;
    items.sort(comparator);
    return _ascending ? items : items.reversed.toList();
  }

  void _handleSort(int index) {
    final ValidsDataColumn<T> column = widget.columns[index];
    if (!column.sortable) return;
    setState(() {
      if (_sortIndex == index) {
        _ascending = !_ascending;
      } else {
        _sortIndex = index;
        _ascending = true;
      }
    });
    column.onSort?.call(_ascending);
  }

  void _toggleAll() {
    if (widget.onSelectionChanged == null) return;
    final bool allSelected =
        widget.items.isNotEmpty && widget.items.every(_selected.contains);
    widget.onSelectionChanged!(
      allSelected ? <T>{} : Set<T>.of(widget.items),
    );
  }

  void _toggleItem(T item, bool checked) {
    if (widget.onSelectionChanged == null) return;
    final Set<T> next = Set<T>.of(_selected);
    if (checked) {
      next.add(item);
    } else {
      next.remove(item);
    }
    widget.onSelectionChanged!(next);
  }

  /// Wraps a cell in a fixed-width box or a flex box depending on the column.
  Widget _cell(ValidsDataColumn<T> column, Widget child) {
    if (column.width != null) {
      return SizedBox(width: column.width, child: child);
    }
    return Expanded(flex: column.flex, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final List<T> sorted = _sortedItems();
    final int? rowsPerPage = widget.rowsPerPage;
    final int pageCount = rowsPerPage == null || sorted.isEmpty
        ? 1
        : ((sorted.length - 1) ~/ rowsPerPage) + 1;
    final int page =
        _page < 0 ? 0 : (_page > pageCount - 1 ? pageCount - 1 : _page);
    final int start = rowsPerPage == null ? 0 : page * rowsPerPage;
    final int end = rowsPerPage == null || start + rowsPerPage > sorted.length
        ? sorted.length
        : start + rowsPerPage;
    final List<T> visible = sorted.sublist(start, end);
    final bool showControls =
        rowsPerPage != null && !widget.loading && sorted.isNotEmpty;

    final Widget table = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ValidsColors.backgroundDefault,
        border: Border.all(
          color: widget.selectionError
              ? ValidsColors.danger
              : ValidsColors.borderDefault,
          width: ValidsBorderWidth.sm,
        ),
        borderRadius: ValidsRadius.smRadius,
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (widget.loading)
            ..._buildSkeletonRows()
          else if (sorted.isEmpty)
            _buildEmpty()
          else
            for (int i = 0; i < visible.length; i++)
              _buildRow(
                visible[i],
                i,
                isLast: i == visible.length - 1 && !showControls,
              ),
          if (showControls) _buildControls(page, pageCount, sorted.length),
        ],
      ),
    );

    if (widget.selectionError && widget.selectionErrorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          table,
          const SizedBox(height: ValidsSpacing.xs2),
          Text(
            widget.selectionErrorMessage!,
            style: ValidsTypography.bodyXs
                .copyWith(color: ValidsColors.dangerDark),
          ),
        ],
      );
    }
    return table;
  }

  /// DataTable.Header — `bg-soft` with `p-md ts-body-highlight-md text-soft`
  /// heads and a ghost/neutral sort button (`ds-data-table-sort-button`).
  Widget _buildHeader() {
    final bool allSelected =
        widget.items.isNotEmpty && widget.items.every(_selected.contains);
    final bool someSelected = _selected.isNotEmpty && !allSelected;
    return Container(
      decoration: BoxDecoration(
        color: ValidsColors.backgroundSoft,
        border: Border(bottom: _rowDivider),
      ),
      child: Row(
        children: [
          if (widget.selectable)
            SizedBox(
              width: _checkboxSlotWidth,
              child: Padding(
                padding: const EdgeInsets.only(left: ValidsSpacing.md),
                child: ValidsCheckbox(
                  checked: allSelected,
                  indeterminate: someSelected,
                  error: widget.selectionError,
                  disabled: widget.onSelectionChanged == null ||
                      widget.items.isEmpty,
                  onCheckedChange: (_) => _toggleAll(),
                ),
              ),
            ),
          for (int i = 0; i < widget.columns.length; i++) _buildHeaderCell(i),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(int index) {
    final ValidsDataColumn<T> column = widget.columns[index];
    final bool isSorted = _sortIndex == index;
    final Widget label = Text(
      column.label,
      style: ValidsTypography.bodyHighlightSm
          .copyWith(color: ValidsColors.textSoft),
    );

    if (!column.sortable) {
      return _cell(
        column,
        Padding(
          padding: const EdgeInsets.all(ValidsSpacing.md),
          child: label,
        ),
      );
    }

    return _cell(
      column,
      Padding(
        padding: const EdgeInsets.all(ValidsSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: label),
            const SizedBox(width: ValidsSpacing.xs),
            ValidsIconButton(
              icon: isSorted
                  ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more,
              kind: ValidsIconButtonKind.neutral,
              variant: ValidsButtonVariant.ghost,
              size: ValidsButtonSize.none,
              onPressed: () => _handleSort(index),
            ),
          ],
        ),
      ),
    );
  }

  /// DataTable rows — `bg-default`, striped even rows in `bg-softer`,
  /// selected rows in the brand softer tone, `p-md ts-body-md` cells.
  Widget _buildRow(T item, int index, {required bool isLast}) {
    final bool isSelected = _selected.contains(item);
    final Color background = isSelected
        ? ValidsColors.primarySofter
        : _striped && index.isOdd
            ? ValidsColors.backgroundSofter
            : ValidsColors.backgroundDefault;

    return Container(
      decoration: BoxDecoration(
        color: background,
        border: isLast ? null : Border(bottom: _rowDivider),
      ),
      child: Row(
        children: [
          if (widget.selectable)
            SizedBox(
              width: _checkboxSlotWidth,
              child: Padding(
                padding: const EdgeInsets.only(left: ValidsSpacing.md),
                child: ValidsCheckbox(
                  checked: isSelected,
                  error: widget.selectionError,
                  disabled: widget.onSelectionChanged == null,
                  onCheckedChange: (checked) => _toggleItem(item, checked),
                ),
              ),
            ),
          for (final column in widget.columns)
            _cell(
              column,
              Padding(
                padding: const EdgeInsets.all(ValidsSpacing.md),
                child: DefaultTextStyle.merge(
                  style: ValidsTypography.bodySm
                      .copyWith(color: ValidsColors.textDefault),
                  child: column.cellBuilder(item),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSkeletonRows() {
    final int count = widget.rowsPerPage ?? 4;
    return [
      for (int i = 0; i < count; i++)
        Container(
          decoration: BoxDecoration(
            border: i == count - 1 ? null : Border(bottom: _rowDivider),
          ),
          padding: const EdgeInsets.all(ValidsSpacing.md),
          child: Row(
            children: [
              if (widget.selectable)
                const SizedBox(
                  width: _checkboxSlotWidth,
                  child: ValidsSkeleton(
                    width: ValidsSpacing.md,
                    height: ValidsSpacing.md,
                  ),
                ),
              for (int c = 0; c < widget.columns.length; c++) ...[
                _cell(
                  widget.columns[c],
                  const ValidsSkeleton(height: ValidsSpacing.md),
                ),
                if (c < widget.columns.length - 1)
                  const SizedBox(width: ValidsSpacing.md),
              ],
            ],
          ),
        ),
    ];
  }

  /// Empty state — `py-xs ts-body-highlight-md text-default` inside a cell.
  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: ValidsSpacing.md,
        vertical: ValidsSpacing.lg,
      ),
      child: Text(
        widget.emptyMessage,
        style: ValidsTypography.bodyHighlightMd
            .copyWith(color: ValidsColors.textDefault),
      ),
    );
  }

  /// DataTable.Controls — `border-t border-default bg-default px-md py-lg`,
  /// with the item count and the DS Pagination.
  Widget _buildControls(int page, int pageCount, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: ValidsSpacing.md,
        vertical: ValidsSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: ValidsColors.backgroundDefault,
        border: Border(top: _rowDivider),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: ValidsSpacing.sm,
        spacing: ValidsSpacing.lg,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$total',
                  style: ValidsTypography.bodyHighlightMd,
                ),
                const TextSpan(text: ' itens'),
              ],
            ),
            style: ValidsTypography.bodyMd
                .copyWith(color: ValidsColors.textDefault),
          ),
          ValidsPagination(
            currentPage: page + 1,
            totalPages: pageCount,
            onPageChange: (target) => setState(() => _page = target - 1),
          ),
        ],
      ),
    );
  }
}

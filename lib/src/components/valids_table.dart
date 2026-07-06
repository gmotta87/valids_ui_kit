import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

class ValidsTableColumn {
  final String label;
  final int flex;
  final double? width;

  const ValidsTableColumn({required this.label, this.flex = 1, this.width});
}

class ValidsTableRow {
  final List<Widget> cells;

  /// Highlights the row with the brand softer background
  /// (`aria-selected` row in the DS).
  final bool selected;

  const ValidsTableRow({required this.cells, this.selected = false});
}

enum ValidsTableVariant { solid, striped }

/// A simple declarative table mirroring the design system's Table
/// (`ds-table`): `rounded-sm` outline in `border-default`, `bg-soft` header
/// with `ts-body-highlight-md` heads, `bg-default` rows separated by
/// `border-default` (even rows in `bg-softer` on the striped variant) and an
/// optional bottom [controls] bar (Table.Controls).
class ValidsTable extends StatelessWidget {
  final List<ValidsTableColumn> columns;
  final List<ValidsTableRow> rows;
  final ValidsTableVariant variant;

  /// Optional bar rendered below the body (Table.Controls in the DS) —
  /// typically a summary, a pagination and/or a page-size picker.
  final Widget? controls;

  const ValidsTable({
    super.key,
    required this.columns,
    required this.rows,
    this.variant = ValidsTableVariant.solid,
    this.controls,
  });

  ValidsTable.fromCells({
    super.key,
    required this.columns,
    required List<List<Widget>> cells,
    this.variant = ValidsTableVariant.solid,
    this.controls,
  }) : rows = cells.map((row) => ValidsTableRow(cells: row)).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ValidsColors.backgroundDefault,
        border: Border.all(
          color: ValidsColors.borderDefault,
          width: ValidsBorderWidth.sm,
        ),
        borderRadius: ValidsRadius.smRadius,
      ),
      child: Column(
        children: [
          _buildHeader(),
          for (int i = 0; i < rows.length; i++)
            _buildRow(rows[i], i, isLast: i == rows.length - 1),
          if (controls != null) _buildControls(),
        ],
      ),
    );
  }

  Widget _wrapCell(ValidsTableColumn column, Widget child) {
    if (column.width != null) {
      return SizedBox(width: column.width, child: child);
    }
    return Expanded(flex: column.flex, child: child);
  }

  /// Table.Head — `p-md text-left ts-body-highlight-md text-soft`.
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: ValidsColors.backgroundSoft,
        border: Border(
          bottom: BorderSide(
            color: ValidsColors.borderDefault,
            width: ValidsBorderWidth.sm,
          ),
        ),
      ),
      child: Row(
        children: [
          for (final column in columns)
            _wrapCell(
              column,
              Padding(
                padding: const EdgeInsets.all(ValidsSpacing.md),
                child: Text(
                  column.label,
                  style: ValidsTypography.bodyHighlightSm
                      .copyWith(color: ValidsColors.textSoft),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Table.Row + Table.Cell — `bg-default`, `border-b border-default`
  /// (omitted on the last row), striped even rows in `bg-softer`, selected
  /// rows in the brand softer tone; cells `p-md ts-body-md text-default`.
  Widget _buildRow(ValidsTableRow row, int index, {required bool isLast}) {
    final Color background = row.selected
        ? ValidsColors.primarySofter
        : variant == ValidsTableVariant.striped && index.isOdd
            ? ValidsColors.backgroundSofter
            : ValidsColors.backgroundDefault;

    return Container(
      decoration: BoxDecoration(
        color: background,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: ValidsColors.borderDefault,
                  width: ValidsBorderWidth.sm,
                ),
              ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < columns.length; i++)
            _wrapCell(
              columns[i],
              Padding(
                padding: const EdgeInsets.all(ValidsSpacing.md),
                child: i < row.cells.length
                    ? DefaultTextStyle.merge(
                        style: ValidsTypography.bodySm
                            .copyWith(color: ValidsColors.textDefault),
                        child: row.cells[i],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }

  /// Table.Controls — `border-t border-default bg-default px-md py-lg`.
  Widget _buildControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: ValidsSpacing.md,
        vertical: ValidsSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: ValidsColors.backgroundDefault,
        border: Border(
          top: BorderSide(
            color: ValidsColors.borderDefault,
            width: ValidsBorderWidth.sm,
          ),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: ValidsTypography.bodyMd
            .copyWith(color: ValidsColors.textDefault),
        child: controls!,
      ),
    );
  }
}

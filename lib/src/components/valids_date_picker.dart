import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_calendar.dart';
import 'valids_chip.dart';

/// A quick-select shortcut shown in the calendar of a [ValidsDatePicker]
/// (DS `shortcuts` items).
class ValidsDatePickerShortcut {
  final String label;
  final DateTime date;

  const ValidsDatePickerShortcut({required this.label, required this.date});
}

/// A date field mirroring the ValiDS `ds-date-picker`: floating label,
/// calendar trigger and clear adornments, support text and a DS-styled
/// calendar (fixed 6 weeks, week starting on Sunday, pt-BR labels) opened in
/// a modal bottom sheet. Dates are displayed as dd/MM/yyyy.
class ValidsDatePicker extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime?>? onChange;
  final VoidCallback? onClear;
  final String? label;
  final String? description;
  final String placeholder;
  final String? errorMessage;
  final bool disabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime day)? selectableDayPredicate;
  final List<ValidsDatePickerShortcut> shortcuts;

  const ValidsDatePicker({
    super.key,
    this.value,
    this.onChange,
    this.onClear,
    this.label,
    this.description,
    this.placeholder = 'dd/mm/aaaa',
    this.errorMessage,
    this.disabled = false,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.shortcuts = const [],
  });

  @override
  State<ValidsDatePicker> createState() => _ValidsDatePickerState();
}

class _ValidsDatePickerState extends State<ValidsDatePicker> {
  bool _isOpen = false;

  bool get _isEnabled => !widget.disabled && widget.onChange != null;

  void _clear() {
    if (widget.onClear != null) {
      widget.onClear!();
    } else {
      widget.onChange?.call(null);
    }
  }

  static String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  Future<void> _openPicker() async {
    setState(() => _isOpen = true);
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ValidsColors.backgroundDefault,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ValidsRadius.lg),
        ),
      ),
      builder: (sheetContext) => _DatePickerSheet(
        initialDate: widget.value,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        selectableDayPredicate: widget.selectableDayPredicate,
        shortcuts: widget.shortcuts,
      ),
    );
    if (mounted) {
      setState(() => _isOpen = false);
    }
    if (picked != null) widget.onChange?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.value != null;
    // DS shows the `dd/mm/aaaa` placeholder only while the label is floated
    // (focus/open); with no label it is always visible.
    final bool showPlaceholder =
        !hasValue && (widget.label == null || _isOpen);

    return ValidsFieldShell(
      label: widget.label,
      description: widget.description,
      errorMessage: widget.errorMessage,
      disabled: !_isEnabled,
      isOpen: _isOpen,
      hasValue: hasValue,
      onTap: _openPicker,
      endAdornments: [
        if (hasValue && _isEnabled)
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
        Icon(
          Icons.calendar_today,
          size: ValidsSpacing.lg,
          color:
              _isEnabled ? ValidsColors.textSoft : ValidsColors.textInactive,
          semanticLabel: 'Abrir calendário',
        ),
      ],
      child: Text(
        hasValue
            ? _formatDate(widget.value!)
            : (showPlaceholder ? widget.placeholder : ''),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ValidsTypography.bodyMd.copyWith(
          color: !hasValue || !_isEnabled
              ? ValidsColors.textInactive
              : ValidsColors.textDefault,
        ),
      ),
    );
  }
}

class _DatePickerSheet extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime day)? selectableDayPredicate;
  final List<ValidsDatePickerShortcut> shortcuts;

  const _DatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.selectableDayPredicate,
    required this.shortcuts,
  });

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final DateTime reference = widget.initialDate ?? DateTime.now();
    _month = DateTime(reference.year, reference.month);
  }

  bool _isShortcutEnabled(ValidsDatePickerShortcut shortcut) {
    final DateTime day =
        DateTime(shortcut.date.year, shortcut.date.month, shortcut.date.day);
    if (widget.firstDate != null && day.isBefore(widget.firstDate!)) {
      return false;
    }
    if (widget.lastDate != null && day.isAfter(widget.lastDate!)) return false;
    final bool Function(DateTime day)? predicate =
        widget.selectableDayPredicate;
    if (predicate != null && !predicate(day)) return false;
    return true;
  }

  Widget? _buildShortcuts() {
    if (widget.shortcuts.isEmpty) return null;
    return Wrap(
      spacing: ValidsSpacing.xs,
      runSpacing: ValidsSpacing.xs,
      children: [
        for (final shortcut in widget.shortcuts)
          ValidsChip(
            label: shortcut.label,
            kind: ValidsChipKind.neutral,
            onTap: _isShortcutEnabled(shortcut)
                ? () => Navigator.of(context).pop(shortcut.date)
                : null,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(ValidsSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValidsCalendar(
                month: _month,
                onMonthChange: (month) => setState(() => _month = month),
                selectedDate: widget.initialDate,
                onDaySelected: (day) => Navigator.of(context).pop(day),
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                selectableDayPredicate: widget.selectableDayPredicate,
                shortcuts: _buildShortcuts(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

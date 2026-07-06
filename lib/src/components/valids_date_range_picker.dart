import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_calendar.dart';
import 'valids_chip.dart';

/// A quick-select shortcut shown in the calendar of a
/// [ValidsDateRangePicker] (DS `shortcuts` items).
class ValidsDateRangePickerShortcut {
  final String label;
  final DateTimeRange range;

  const ValidsDateRangePickerShortcut({
    required this.label,
    required this.range,
  });
}

/// A period field mirroring the ValiDS `ds-date-range-picker`: floating
/// label, start/end values separated by the DS separator bar, calendar
/// trigger and clear adornments, support text and a DS-styled range calendar
/// (1 month on narrow viewports, 2 from the `md` breakpoint) opened in a
/// modal bottom sheet. Dates are displayed as dd/MM/yyyy.
class ValidsDateRangePicker extends StatefulWidget {
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?>? onChange;
  final VoidCallback? onClear;
  final String? label;
  final String? description;

  /// Placeholder shown for each empty side of the period (DS `dd/mm/aaaa`).
  final String placeholder;
  final String? errorMessage;
  final bool disabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final List<ValidsDateRangePickerShortcut> shortcuts;

  const ValidsDateRangePicker({
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
    this.shortcuts = const [],
  });

  @override
  State<ValidsDateRangePicker> createState() => _ValidsDateRangePickerState();
}

class _ValidsDateRangePickerState extends State<ValidsDateRangePicker> {
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
    final DateTimeRange? picked = await showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ValidsColors.backgroundDefault,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ValidsRadius.lg),
        ),
      ),
      builder: (sheetContext) => _DateRangePickerSheet(
        initialRange: widget.value,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        shortcuts: widget.shortcuts,
      ),
    );
    if (mounted) {
      setState(() => _isOpen = false);
    }
    if (picked != null) widget.onChange?.call(picked);
  }

  Widget _buildSide(DateTime? date, bool showPlaceholder) {
    final bool filled = date != null;
    return Text(
      filled ? _formatDate(date) : (showPlaceholder ? widget.placeholder : ''),
      maxLines: 1,
      style: ValidsTypography.bodyMd.copyWith(
        color: !filled || !_isEnabled
            ? ValidsColors.textInactive
            : ValidsColors.textDefault,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.value != null;
    // DS shows the placeholders and separator only while the label is
    // floated (value present or popup open); with no label, always.
    final bool showPlaceholder = widget.label == null || _isOpen || hasValue;
    final bool showSeparator = hasValue || _isOpen || widget.label == null;

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
      child: Row(
        children: [
          _buildSide(widget.value?.start, showPlaceholder),
          // DS `ds-date-range-picker-separator`: a `size-sm` × 1px bar in
          // `border-soft`, fading in with the placeholders.
          AnimatedOpacity(
            duration: kValidsFieldAnimationDuration,
            opacity: showSeparator ? 1 : 0,
            child: Container(
              width: ValidsSpacing.sm,
              height: ValidsBorderWidth.sm,
              margin: const EdgeInsets.symmetric(horizontal: ValidsSpacing.xs),
              color: ValidsColors.borderSoft,
            ),
          ),
          Flexible(child: _buildSide(widget.value?.end, showPlaceholder)),
        ],
      ),
    );
  }
}

class _DateRangePickerSheet extends StatefulWidget {
  final DateTimeRange? initialRange;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final List<ValidsDateRangePickerShortcut> shortcuts;

  const _DateRangePickerSheet({
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
    required this.shortcuts,
  });

  @override
  State<_DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<_DateRangePickerSheet> {
  late DateTime _month;
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialRange?.start;
    _end = widget.initialRange?.end;
    final DateTime reference = _start ?? DateTime.now();
    _month = DateTime(reference.year, reference.month);
  }

  void _handleDay(DateTime day) {
    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        _start = day;
        _end = null;
      } else if (day.isBefore(_start!)) {
        _start = day;
      } else {
        _end = day;
      }
    });
    if (_start != null && _end != null) {
      Navigator.of(context).pop(DateTimeRange(start: _start!, end: _end!));
    }
  }

  bool _isShortcutEnabled(ValidsDateRangePickerShortcut shortcut) {
    if (widget.firstDate != null &&
        shortcut.range.start.isBefore(widget.firstDate!)) {
      return false;
    }
    if (widget.lastDate != null &&
        shortcut.range.end.isAfter(widget.lastDate!)) {
      return false;
    }
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
                ? () => Navigator.of(context).pop(shortcut.range)
                : null,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // DS `numberOfMonths`: 2 from the `md` breakpoint, 1 below it.
    final int numberOfMonths =
        MediaQuery.sizeOf(context).width >= kValidsBreakpointMd ? 2 : 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(ValidsSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValidsCalendar(
                isRange: true,
                month: _month,
                numberOfMonths: numberOfMonths,
                onMonthChange: (month) => setState(() => _month = month),
                rangeStart: _start,
                rangeEnd: _end,
                onDaySelected: _handleDay,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                shortcuts: _buildShortcuts(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

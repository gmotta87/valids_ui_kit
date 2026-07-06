import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/sizing.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'internal/field_chrome.dart';

/// Internal building blocks shared by [ValidsCombobox], [ValidsDatePicker]
/// and [ValidsDateRangePicker]. This file is intentionally NOT exported by
/// the package barrel; import it directly from sibling components.

/// DS transition duration used by `field-wrapper` / floating labels (0.2s).
const Duration kValidsFieldAnimationDuration = fieldTransitionDuration;

/// DS `md` responsive breakpoint (48rem = 768px), used by the calendar to
/// decide between 1 and 2 visible months and to place shortcuts.
const double kValidsBreakpointMd = ValidsSizing.xl3;

/// The DS field frame (`field-wrapper` / `combobox-wrapper`): a bordered
/// container with a floating label, optional adornments and support text
/// (description / error) below, exactly mirroring the ValiDS tokens:
///
/// - height `spacing.14` (56px), padding-inline `md`, radius `md`;
/// - border `sm` `border-soft`; open/focus → `border-bold` (+1px ring ⇒ 2px);
/// - invalid → `error-800`; disabled → `border-inactive`;
/// - floating label: rest 16px/`leading-xl` `text-soft`; floated 12px /
///   `leading-md` on the top border with `bg-default` and `2xs` padding.
class ValidsFieldShell extends StatelessWidget {
  final String? label;
  final String? description;
  final String? errorMessage;
  final bool disabled;

  /// Whether the popup/sheet driven by this field is open (focus state).
  final bool isOpen;

  /// Whether the field has a value — floats the label up.
  final bool hasValue;
  final VoidCallback? onTap;
  final Widget? startAdornment;
  final List<Widget> endAdornments;
  final Widget child;

  const ValidsFieldShell({
    super.key,
    required this.child,
    this.label,
    this.description,
    this.errorMessage,
    this.disabled = false,
    this.isOpen = false,
    this.hasValue = false,
    this.onTap,
    this.startAdornment,
    this.endAdornments = const [],
  });

  bool get _hasError => errorMessage != null;

  /// DS floats the label when the field has a value, the popup is open or a
  /// start adornment is present (`data-has-start-adornment`).
  bool get _labelFloated => hasValue || isOpen || startAdornment != null;

  @override
  Widget build(BuildContext context) {
    final Widget field = Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: ValidsRadius.mdRadius,
          child: FieldWrapper(
            focused: isOpen,
            invalid: _hasError,
            disabled: disabled,
            constraints: const BoxConstraints(minHeight: ValidsSpacing.xl4),
            child: Row(
              children: [
                if (startAdornment != null) ...[
                  FieldAdornment(
                    disabled: disabled,
                    child: startAdornment!,
                  ),
                  const SizedBox(width: ValidsSpacing.xs),
                ],
                Expanded(child: child),
                for (final Widget adornment in endAdornments) ...[
                  const SizedBox(width: ValidsSpacing.xs),
                  adornment,
                ],
              ],
            ),
          ),
        ),
        if (label != null)
          FieldFloatingLabel(
            label: label!,
            floated: _labelFloated,
            invalid: _hasError,
            disabled: disabled,
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        field,
        FieldSupport(description: description, errorMessage: errorMessage),
      ],
    );
  }
}

/// The DS calendar (`ds-date-picker-calendar` / `ds-date-range-picker-calendar`):
/// bordered container with optional shortcuts, month caption(s) with
/// around-navigation and a 7×6 fixed-weeks grid (week starts on Sunday,
/// outside days hidden), pt-BR labels.
class ValidsCalendar extends StatelessWidget {
  /// First visible month (any day of the month).
  final DateTime month;
  final ValueChanged<DateTime> onMonthChange;
  final int numberOfMonths;

  /// Selected day in single mode.
  final DateTime? selectedDate;

  /// Range endpoints in range mode.
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final bool isRange;
  final ValueChanged<DateTime> onDaySelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Optional shortcuts panel (DS renders it as a vertical toggle group on
  /// wide viewports; callers may pass any widget).
  final Widget? shortcuts;

  const ValidsCalendar({
    super.key,
    required this.month,
    required this.onMonthChange,
    required this.onDaySelected,
    this.numberOfMonths = 1,
    this.selectedDate,
    this.rangeStart,
    this.rangeEnd,
    this.isRange = false,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.shortcuts,
  });

  /// pt-BR narrow weekday names, week starting on Sunday (`weekStartsOn: 0`).
  static const List<String> _weekdayNarrow = [
    'D',
    'S',
    'T',
    'Q',
    'Q',
    'S',
    'S',
  ];

  /// pt-BR month names, capitalized as the DS caption formatter does.
  static const List<String> _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDisabledDay(DateTime day) {
    if (firstDate != null && day.isBefore(_dateOnly(firstDate!))) return true;
    if (lastDate != null && day.isAfter(_dateOnly(lastDate!))) return true;
    final bool Function(DateTime day)? predicate = selectableDayPredicate;
    if (predicate != null && !predicate(day)) return true;
    return false;
  }

  bool get _canGoPrevious {
    if (firstDate == null) return true;
    final DateTime previous = DateTime(month.year, month.month - 1);
    return !previous
        .isBefore(DateTime(firstDate!.year, firstDate!.month));
  }

  bool get _canGoNext {
    if (lastDate == null) return true;
    final DateTime next =
        DateTime(month.year, month.month + numberOfMonths);
    return !next.isAfter(DateTime(lastDate!.year, lastDate!.month));
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required String semanticLabel,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: ValidsSpacing.xl,
        height: ValidsSpacing.xl,
        child: Icon(
          icon,
          size: ValidsSpacing.lg,
          color: enabled ? ValidsColors.textSoft : ValidsColors.textInactive,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day) {
    final bool disabledDay = _isDisabledDay(day);
    final bool isToday = _sameDay(day, DateTime.now());
    final DateTime? start = rangeStart != null ? _dateOnly(rangeStart!) : null;
    final DateTime? end = rangeEnd != null ? _dateOnly(rangeEnd!) : null;

    bool isStart = false;
    bool isEnd = false;
    bool isMiddle = false;
    bool isSelected = false;

    if (isRange) {
      isStart = start != null && _sameDay(day, start);
      isEnd = end != null && _sameDay(day, end);
      isMiddle = start != null &&
          end != null &&
          day.isAfter(start) &&
          day.isBefore(end);
    } else {
      isSelected = selectedDate != null && _sameDay(day, selectedDate!);
    }

    final bool boldBackground = isSelected || isStart || isEnd;

    // Shape: selected days are fully rounded; range ends round only the
    // outer side; range middle is squared (`radius-none`).
    BorderRadius radius = ValidsRadius.fullRadius;
    if (isStart && isEnd) {
      radius = ValidsRadius.fullRadius;
    } else if (isStart) {
      radius = const BorderRadius.horizontal(
        left: Radius.circular(ValidsRadius.full),
      );
    } else if (isEnd) {
      radius = const BorderRadius.horizontal(
        right: Radius.circular(ValidsRadius.full),
      );
    } else if (isMiddle) {
      radius = ValidsRadius.noneRadius;
    }

    Color? background;
    if (!disabledDay || (!isRange && boldBackground)) {
      if (boldBackground) {
        background = ValidsColors.primary;
      } else if (isMiddle) {
        background = ValidsColors.primarySofter;
      }
    }

    Color textColor = ValidsColors.textDefault;
    FontWeight weight = ValidsTypography.regular;
    TextDecoration decoration = TextDecoration.none;
    if (isToday) {
      textColor = ValidsColors.primary;
      weight = ValidsTypography.bold;
      decoration = TextDecoration.underline;
    }
    if (boldBackground) {
      textColor = ValidsColors.textInvert;
      weight = ValidsTypography.regular;
      decoration = TextDecoration.none;
    } else if (isMiddle) {
      textColor = ValidsColors.textDefault;
      weight = ValidsTypography.regular;
      decoration = TextDecoration.none;
    }
    if (disabledDay) {
      textColor = ValidsColors.textInactive;
      if (isRange) background = null;
    }

    return SizedBox(
      width: ValidsSpacing.xl,
      height: ValidsSpacing.xl,
      child: Material(
        color: background ?? ValidsColors.backgroundDefault.withValues(alpha: 0),
        borderRadius: radius,
        child: InkWell(
          onTap: disabledDay ? null : () => onDaySelected(day),
          borderRadius: radius,
          child: Center(
            child: Text(
              '${day.day}',
              style: ValidsTypography.bodySm.copyWith(
                color: textColor,
                fontWeight: weight,
                decoration: decoration,
                decorationColor: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonth(DateTime visibleMonth, {
    required bool showPrevious,
    required bool showNext,
  }) {
    final int daysInMonth =
        DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    // Week starts on Sunday (`weekStartsOn: 0`).
    final int leadingBlanks =
        DateTime(visibleMonth.year, visibleMonth.month, 1).weekday % 7;
    const int fixedWeeks = 6;
    const int daysPerWeek = 7;

    final String caption =
        '${_monthNames[visibleMonth.month - 1]} ${visibleMonth.year}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: ValidsSpacing.xl,
          // Match the 7-column grid width so `Expanded` has a bounded box
          // even inside the horizontally-scrollable calendar viewport.
          width: daysPerWeek * ValidsSpacing.xl,
          child: Row(
            children: [
              if (showPrevious)
                _navButton(
                  icon: Icons.chevron_left,
                  enabled: _canGoPrevious,
                  onTap: () => onMonthChange(
                    DateTime(month.year, month.month - 1),
                  ),
                  semanticLabel: 'Ir para o mês anterior',
                )
              else
                const SizedBox(width: ValidsSpacing.xl),
              Expanded(
                child: Center(
                  child: Text(
                    caption,
                    style: ValidsTypography.headingSm.copyWith(
                      color: ValidsColors.textDefault,
                    ),
                  ),
                ),
              ),
              if (showNext)
                _navButton(
                  icon: Icons.chevron_right,
                  enabled: _canGoNext,
                  onTap: () => onMonthChange(
                    DateTime(month.year, month.month + 1),
                  ),
                  semanticLabel: 'Ir para o mês seguinte',
                )
              else
                const SizedBox(width: ValidsSpacing.xl),
            ],
          ),
        ),
        const SizedBox(height: ValidsSpacing.md),
        Container(
          padding: const EdgeInsets.all(ValidsSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: ValidsRadius.mdRadius,
            border: Border.all(
              color: ValidsColors.borderDefault,
              width: ValidsBorderWidth.sm,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final String name in _weekdayNarrow)
                    SizedBox(
                      width: ValidsSpacing.xl,
                      height: ValidsSpacing.xl,
                      child: Center(
                        child: Text(
                          name,
                          style: ValidsTypography.bodyHighlightSm.copyWith(
                            color: ValidsColors.textDefault,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              for (int week = 0; week < fixedWeeks; week++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int weekday = 0; weekday < daysPerWeek; weekday++)
                      _buildCellAt(
                        visibleMonth,
                        week * daysPerWeek + weekday - leadingBlanks + 1,
                        daysInMonth,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCellAt(DateTime visibleMonth, int dayNumber, int daysInMonth) {
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      // `showOutsideDays: false` — hidden cells keep the 32px footprint.
      return const SizedBox(
        width: ValidsSpacing.xl,
        height: ValidsSpacing.xl,
      );
    }
    return _buildDayCell(
      DateTime(visibleMonth.year, visibleMonth.month, dayNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget months = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < numberOfMonths; index++) ...[
          if (index > 0) const SizedBox(width: ValidsSpacing.md),
          _buildMonth(
            DateTime(month.year, month.month + index),
            showPrevious: index == 0,
            showNext: index == numberOfMonths - 1,
          ),
        ],
      ],
    );

    return Container(
      padding: const EdgeInsets.all(ValidsSpacing.md),
      decoration: BoxDecoration(
        color: ValidsColors.backgroundDefault,
        borderRadius: ValidsRadius.mdRadius,
        border: Border.all(
          color: ValidsColors.borderSoft,
          width: ValidsBorderWidth.sm,
        ),
      ),
      child: Builder(
        builder: (context) {
          final bool wide =
              MediaQuery.sizeOf(context).width >= kValidsBreakpointMd;
          if (shortcuts == null) {
            return months;
          }
          if (wide) {
            // DS: shortcuts as a left column with `2xl` top padding.
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: ValidsSpacing.xl2),
                  child: shortcuts!,
                ),
                const SizedBox(width: ValidsSpacing.md),
                months,
              ],
            );
          }
          // Narrow viewports: DS hides the shortcuts; we keep the feature by
          // stacking them above the grid.
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shortcuts!,
              const SizedBox(height: ValidsSpacing.md),
              months,
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// A single section of a [ValidsAccordion].
///
/// Mirrors the DS `Accordion.Item` composition: trigger with a title,
/// optional description and optional leading icon, plus a collapsible
/// content panel.
class ValidsAccordionItem {
  final String title;
  final Widget content;
  final String? description;

  /// Extra (não presente no DS web): leading icon rendered inside the
  /// trigger, styled like the DS `[&_svg]:icon-soft` rule.
  final IconData? icon;
  final bool disabled;

  const ValidsAccordionItem({
    required this.title,
    required this.content,
    this.description,
    this.icon,
    this.disabled = false,
  });
}

/// Accordion matching the ValiDS design system (`ds-accordion`).
///
/// Each item is an independent card (`rounded-sm bg-default border
/// border-soft`) separated by a `gap-md`, with a `ts-heading-sm` trigger and
/// a `ts-body-md` content panel. Hovering an enabled trigger promotes the
/// card border to `border-bold`.
class ValidsAccordion extends StatefulWidget {
  final List<ValidsAccordionItem> items;

  /// DS `openMultiple`: allows several panels open at once.
  final bool openMultiple;
  final Set<int> defaultValue;
  final Set<int>? value;
  final ValueChanged<Set<int>>? onValueChange;

  const ValidsAccordion({
    super.key,
    required this.items,
    this.openMultiple = false,
    this.defaultValue = const {},
    this.value,
    this.onValueChange,
  });

  @override
  State<ValidsAccordion> createState() => _ValidsAccordionState();
}

class _ValidsAccordionState extends State<ValidsAccordion> {
  late Set<int> _expanded;
  int? _hovered;

  /// DS chevron/panel transition: `duration-300`.
  static const Duration _duration = Duration(milliseconds: 300);

  /// DS icons are 24px (`size-6`).
  static const double _iconSize = ValidsSpacing.lg;

  bool get _isControlled => widget.value != null;

  Set<int> get _effectiveExpanded =>
      _isControlled ? widget.value! : _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = Set<int>.from(widget.value ?? widget.defaultValue);
  }

  void _toggle(int index) {
    final Set<int> expanded = Set<int>.from(_effectiveExpanded);
    if (expanded.contains(index)) {
      expanded.remove(index);
    } else {
      if (!widget.openMultiple) {
        expanded.clear();
      }
      expanded.add(index);
    }
    if (!_isControlled) {
      setState(() => _expanded = expanded);
    }
    widget.onValueChange?.call(expanded);
  }

  @override
  Widget build(BuildContext context) {
    // DS root: `flex w-full flex-col gap-md`.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < widget.items.length; i++) ...[
          if (i > 0) const SizedBox(height: ValidsSpacing.md),
          _buildItem(i),
        ],
      ],
    );
  }

  Widget _buildItem(int index) {
    final ValidsAccordionItem item = widget.items[index];
    final bool isExpanded =
        !item.disabled && _effectiveExpanded.contains(index);

    // DS item border: `border-soft`, hover → `border-bold`,
    // disabled → `border-inactive`.
    final Color borderColor = item.disabled
        ? ValidsColors.borderInactive
        : _hovered == index
            ? ValidsColors.borderBold
            : ValidsColors.borderSoft;

    final Color titleColor =
        item.disabled ? ValidsColors.textInactive : ValidsColors.textDefault;
    final Color softColor =
        item.disabled ? ValidsColors.textInactive : ValidsColors.textSoft;

    // DS item: `rounded-sm bg-default border border-soft` with a
    // border-color transition (`duration-200`).
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: ValidsColors.backgroundDefault,
        border: Border.all(
          color: borderColor,
          width: ValidsBorderWidth.sm,
        ),
        borderRadius: ValidsRadius.smRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Semantics(
              header: true,
              child: InkWell(
                onTap: item.disabled ? null : () => _toggle(index),
                onHover: (hovering) => setState(
                  () => _hovered = hovering ? index : null,
                ),
                child: Padding(
                  // DS trigger: `p-md` with `gap-xs` between text and chevron.
                  padding: const EdgeInsets.all(ValidsSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.icon != null) ...[
                        Icon(item.icon, size: _iconSize, color: softColor),
                        const SizedBox(width: ValidsSpacing.xs),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DS title: `ts-heading-sm text-default`.
                            Text(
                              item.title,
                              style: ValidsTypography.headingSm
                                  .copyWith(color: titleColor),
                            ),
                            // DS description: `ts-body-sm text-soft`.
                            if (item.description != null)
                              Text(
                                item.description!,
                                style: ValidsTypography.bodySm
                                    .copyWith(color: softColor),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: ValidsSpacing.xs),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: _duration,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: _iconSize,
                          color: softColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Container(
                width: double.infinity,
                // DS content: `px-md pt-xs pb-md`.
                padding: const EdgeInsets.fromLTRB(
                  ValidsSpacing.md,
                  ValidsSpacing.xs,
                  ValidsSpacing.md,
                  ValidsSpacing.md,
                ),
                // DS content text: `ts-body-md text-default`.
                child: DefaultTextStyle.merge(
                  style: ValidsTypography.bodyMd
                      .copyWith(color: ValidsColors.textDefault),
                  child: item.content,
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: _duration,
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }
}

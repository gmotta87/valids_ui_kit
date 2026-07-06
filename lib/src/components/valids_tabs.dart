import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

class ValidsTab {
  final String label;

  /// Extra (não presente no DS web): leading icon on the tab.
  final IconData? icon;
  final bool disabled;

  const ValidsTab({
    required this.label,
    this.icon,
    this.disabled = false,
  });
}

/// Tabs matching the ValiDS design system (`ds-tabs`).
///
/// The tab list is a horizontally scrollable row with a `border-soft` bottom
/// border and an animated 2px brand indicator that slides under the active
/// tab. Tabs use `ts-body-sm text-soft`, promoted to `ts-body-highlight-sm`
/// in the brand color when active (reserving the bold width so the layout
/// doesn't shift). The panel gets a `pt-md`.
class ValidsTabs extends StatefulWidget {
  final List<ValidsTab> tabs;
  final List<Widget> children;
  final int? value;
  final int defaultValue;
  final ValueChanged<int>? onValueChange;
  final bool disabled;

  /// Extra (não presente no DS web): vertical tab list.
  final Axis orientation;

  /// Extra: the DS list is always content-sized and scrollable; pass `false`
  /// to stretch the tabs across the available width instead.
  final bool? isScrollable;

  const ValidsTabs({
    super.key,
    required this.tabs,
    required this.children,
    this.value,
    this.defaultValue = 0,
    this.onValueChange,
    this.disabled = false,
    this.orientation = Axis.horizontal,
    this.isScrollable,
  }) : assert(
          tabs.length == children.length,
          'tabs and children must have the same length.',
        );

  @override
  State<ValidsTabs> createState() => _ValidsTabsState();
}

class _ValidsTabsState extends State<ValidsTabs> {
  late int _currentIndex;

  final GlobalKey _listKey = GlobalKey();
  late List<GlobalKey> _tabKeys;
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  /// DS indicator transition: `duration-200 ease-in-out`.
  static const Duration _duration = Duration(milliseconds: 200);

  /// Extra icons follow the DS `size-4` (16px) inline icon size.
  static const double _iconSize = ValidsSpacing.md;

  /// DS default: list always scrollable (`overflow-x-auto`); `false` is the
  /// kept extra that stretches tabs instead.
  bool get _scrollable => widget.isScrollable ?? true;

  @override
  void initState() {
    super.initState();
    _currentIndex =
        (widget.value ?? widget.defaultValue).clamp(0, widget.tabs.length - 1);
    _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant ValidsTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
      _currentIndex = _currentIndex.clamp(0, widget.tabs.length - 1);
    }
    if (widget.value != null && widget.value != _currentIndex) {
      _currentIndex = widget.value!.clamp(0, widget.tabs.length - 1);
    }
  }

  void _select(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    widget.onValueChange?.call(index);
  }

  /// Measures the active tab to position the sliding indicator, mirroring
  /// the DS `--active-tab-left`/`--active-tab-width` variables.
  void _measureIndicator() {
    if (!mounted) return;
    final RenderBox? listBox =
        _listKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? tabBox =
        _tabKeys[_currentIndex].currentContext?.findRenderObject() as RenderBox?;
    if (listBox == null || tabBox == null || !tabBox.attached) return;
    final double left =
        tabBox.localToGlobal(Offset.zero, ancestor: listBox).dx;
    final double width = tabBox.size.width;
    if (left != _indicatorLeft || width != _indicatorWidth) {
      setState(() {
        _indicatorLeft = left;
        _indicatorWidth = width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orientation == Axis.vertical) {
      return _buildVertical();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureIndicator());

    final Widget tabStack = Stack(
      children: [
        Row(
          key: _listKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.tabs.length; i++)
              if (_scrollable)
                _buildTab(i)
              else
                Expanded(child: _buildTab(i)),
          ],
        ),
        // DS `ds-tabs-indicator`: 2px brand bar sliding under the active tab.
        AnimatedPositioned(
          duration: _duration,
          curve: Curves.easeInOut,
          left: _indicatorLeft,
          bottom: 0,
          width: _indicatorWidth,
          height: ValidsBorderWidth.md,
          child: Container(color: ValidsColors.primary),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          // DS list: `border-b-sm border-soft`.
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ValidsColors.borderSoft,
                width: ValidsBorderWidth.sm,
              ),
            ),
          ),
          child: _scrollable
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: tabStack,
                )
              : tabStack,
        ),
        // DS panel: `pt-md`.
        Padding(
          padding: const EdgeInsets.only(top: ValidsSpacing.md),
          child: widget.children[_currentIndex],
        ),
      ],
    );
  }

  /// Extra: vertical orientation, styled with the same DS tokens (soft
  /// divider, 2px brand indicator beside the active tab).
  Widget _buildVertical() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: ValidsColors.borderSoft,
                  width: ValidsBorderWidth.sm,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < widget.tabs.length; i++)
                  _buildTab(i, vertical: true),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: ValidsSpacing.md),
              child: widget.children[_currentIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, {bool vertical = false}) {
    final ValidsTab tab = widget.tabs[index];
    final bool isSelected = index == _currentIndex;
    final bool disabled = widget.disabled || tab.disabled;

    // DS tab: `ts-body-sm text-soft`, active `ts-body-highlight-sm` in the
    // brand color, disabled `text-inactive`.
    final Color foreground = disabled
        ? ValidsColors.textInactive
        : isSelected
            ? ValidsColors.primary
            : ValidsColors.textSoft;
    final TextStyle textStyle = (isSelected
            ? ValidsTypography.bodyHighlightSm
            : ValidsTypography.bodySm)
        .copyWith(color: foreground);

    // DS grid trick: reserve the bold width so activating a tab doesn't
    // shift the layout.
    final Widget label = Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Text(tab.label, style: ValidsTypography.bodyHighlightSm),
        ),
        Text(tab.label, overflow: TextOverflow.ellipsis, style: textStyle),
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: vertical ? null : _tabKeys[index],
        onTap: disabled ? null : () => _select(index),
        // DS hover: `bg-bold/10` (inactive) or brand `/10` (active).
        hoverColor: (isSelected
                ? ValidsColors.primary
                : ValidsColors.backgroundBold)
            .withValues(alpha: 0.10),
        child: Container(
          // DS tab: `p-xs` plus `px-xs` on the inner label span.
          padding: const EdgeInsets.all(ValidsSpacing.xs),
          decoration: vertical
              ? BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      width: ValidsBorderWidth.md,
                      color: isSelected
                          ? ValidsColors.primary
                          : Colors.transparent,
                    ),
                  ),
                )
              : null,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: ValidsSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (tab.icon != null) ...[
                  Icon(tab.icon, size: _iconSize, color: foreground),
                  const SizedBox(width: ValidsSpacing.xs),
                ],
                Flexible(child: label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

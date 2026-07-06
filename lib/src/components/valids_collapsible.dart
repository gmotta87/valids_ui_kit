import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Where the panel is rendered relative to the trigger (DS `panelPosition`).
enum ValidsCollapsiblePanelPosition { top, bottom }

typedef ValidsCollapsibleTriggerBuilder = Widget Function(
  BuildContext context,
  bool open,
  VoidCallback toggle,
);

/// A disclosure primitive matching the ValiDS design system
/// (`ds-collapsible`): a ghost brand button-style trigger with a rotating
/// chevron indicator, plus an unstyled panel that expands/collapses.
///
/// Supports `panelPosition`, controlled/uncontrolled state and a custom
/// trigger via [triggerBuilder] (the DS `render` prop equivalent).
class ValidsCollapsible extends StatefulWidget {
  final String? title;
  final Widget child;
  final bool defaultOpen;

  /// Extra (não presente no DS web como prop direta; equivale ao `disabled`
  /// do botão usado como trigger).
  final bool disabled;
  final bool? open;
  final ValueChanged<bool>? onOpenChange;
  final ValidsCollapsiblePanelPosition panelPosition;
  final ValidsCollapsibleTriggerBuilder? triggerBuilder;

  const ValidsCollapsible({
    super.key,
    this.title,
    required this.child,
    this.defaultOpen = false,
    this.disabled = false,
    this.open,
    this.onOpenChange,
    this.panelPosition = ValidsCollapsiblePanelPosition.bottom,
    this.triggerBuilder,
  }) : assert(
          title != null || triggerBuilder != null,
          'Provide a title or a triggerBuilder.',
        );

  @override
  State<ValidsCollapsible> createState() => _ValidsCollapsibleState();
}

class _ValidsCollapsibleState extends State<ValidsCollapsible> {
  late bool _open;

  /// DS panel/indicator transition: `duration-200`.
  static const Duration _duration = Duration(milliseconds: 200);

  /// DS indicator chevron is 24px (`size-6`).
  static const double _iconSize = ValidsSpacing.lg;

  bool get _isControlled => widget.open != null;

  bool get _effectiveOpen =>
      !widget.disabled && (_isControlled ? widget.open! : _open);

  @override
  void initState() {
    super.initState();
    _open = widget.open ?? widget.defaultOpen;
  }

  void _toggle() {
    if (widget.disabled) return;
    final bool next = !_effectiveOpen;
    if (!_isControlled) {
      setState(() => _open = next);
    }
    widget.onOpenChange?.call(next);
  }

  bool get _panelOnTop =>
      widget.panelPosition == ValidsCollapsiblePanelPosition.top;

  @override
  Widget build(BuildContext context) {
    final Widget trigger = widget.triggerBuilder != null
        ? widget.triggerBuilder!(context, _effectiveOpen, _toggle)
        : _defaultTrigger();

    final Widget panel = _buildPanel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _panelOnTop ? [panel, trigger] : [trigger, panel],
    );
  }

  /// DS default trigger: a `Button` with `kind: brand`, `variant: ghost`,
  /// `size: none` — brand-colored `ts-button-md` text with a chevron
  /// indicator that rotates 180° when open.
  Widget _defaultTrigger() {
    final Color foreground =
        widget.disabled ? ValidsColors.textInactive : ValidsColors.primary;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.disabled ? null : _toggle,
        borderRadius: ValidsRadius.smRadius,
        // DS ghost button hover: brand at 10% (`/10`).
        hoverColor: ValidsColors.primary.withValues(alpha: 0.10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.title ?? '',
                style: ValidsTypography.buttonMd.copyWith(color: foreground),
              ),
            ),
            const SizedBox(width: ValidsSpacing.xs),
            AnimatedRotation(
              turns: _effectiveOpen ? 0.5 : 0.0,
              duration: _duration,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: _iconSize,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// DS panel: unstyled content, only clipped with a height transition
  /// (`overflow-hidden transition-[height] duration-200`).
  Widget _buildPanel() {
    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity),
      secondChild: SizedBox(
        width: double.infinity,
        child: widget.child,
      ),
      crossFadeState: _effectiveOpen
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: _duration,
      sizeCurve: Curves.easeInOut,
    );
  }
}

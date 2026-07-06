import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Where the [ValidsInfotip] popup is placed relative to its trigger
/// (DS `slotProps.positioner.side`, default `top`).
enum ValidsInfotipPosition { top, bottom, left, right }

/// Contextual tip shown on hover or tap, mirroring the design system's
/// Infotip (a popover, not a tooltip, so it also works on touch devices).
///
/// DS anatomy: popup `max-w-60` (240px), `rounded-sm`, `bg-bold` with
/// `px-sm py-xs`, centered `ts-body-xs` text in `text-invert`, plus a 16×8
/// arrow in the same color; positioned with an 8px side offset.
///
/// Supports controlled open state via [open] / [onOpenChange] and
/// uncontrolled initial state via [defaultOpen], like the DS `Infotip.Root`.
///
/// Extras beyond the DS: a plain [message] convenience prop and a default
/// info-icon trigger when no [child] is given.
class ValidsInfotip extends StatefulWidget {
  final String? message;

  /// Rich popup content (the DS accepts arbitrary `Infotip.Content`
  /// children). Inherits the DS text style via [DefaultTextStyle].
  final Widget? content;
  final ValidsInfotipPosition position;

  /// The trigger element. Defaults to an info icon.
  final Widget? child;
  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;

  const ValidsInfotip({
    super.key,
    this.message,
    this.content,
    this.position = ValidsInfotipPosition.top,
    this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
  }) : assert(message != null || content != null,
            'Provide a message or content.');

  @override
  State<ValidsInfotip> createState() => _ValidsInfotipState();
}

class _ValidsInfotipState extends State<ValidsInfotip> {
  /// DS popup `max-w-60` → 240px.
  static const double _maxWidth = ValidsSpacing.xl10;

  /// DS arrow SVG is 16×8.
  static const Size _arrowSize = Size(16, 8);

  /// The DS arrow sits 6px outside the popup (`-bottom-1.5`), i.e. it
  /// overlaps the popup by 2px so no seam is visible.
  static const double _arrowOverlap = 2;

  /// Default trigger icon size, matching the DS docs trigger (`size-md`).
  static const double _triggerIconSize = ValidsSpacing.md;

  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  bool get _isControlled => widget.open != null;
  late bool _open;
  bool _hoverOpened = false;

  @override
  void initState() {
    super.initState();
    _open = widget.open ?? widget.defaultOpen;
    if (_open) _controller.show();
  }

  @override
  void didUpdateWidget(covariant ValidsInfotip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isControlled && widget.open != _open) {
      _open = widget.open!;
      _sync();
    }
  }

  void _sync() {
    if (_open) {
      _controller.show();
    } else {
      _controller.hide();
    }
  }

  void _setOpen(bool next) {
    if (_open == next) return;
    if (!_isControlled) {
      setState(() => _open = next);
      _sync();
    }
    widget.onOpenChange?.call(next);
  }

  void _toggle() {
    _hoverOpened = false; // taps pin the tip open until dismissed
    _setOpen(!_open);
  }

  void _handleHoverEnter() {
    if (_open) return;
    _hoverOpened = true;
    _setOpen(true);
  }

  void _handleHoverExit() {
    if (_hoverOpened) {
      _hoverOpened = false;
      _setOpen(false);
    }
  }

  ({Alignment target, Alignment follower}) get _anchor {
    switch (widget.position) {
      case ValidsInfotipPosition.top:
        return (target: Alignment.topCenter, follower: Alignment.bottomCenter);
      case ValidsInfotipPosition.bottom:
        return (target: Alignment.bottomCenter, follower: Alignment.topCenter);
      case ValidsInfotipPosition.left:
        return (target: Alignment.centerLeft, follower: Alignment.centerRight);
      case ValidsInfotipPosition.right:
        return (target: Alignment.centerRight, follower: Alignment.centerLeft);
    }
  }

  Widget _buildPopup() {
    final TextStyle textStyle = ValidsTypography.bodyXs.copyWith(
      color: ValidsColors.textInvert, // text-invert
    );
    final Widget bubble = Container(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      padding: const EdgeInsets.symmetric(
        horizontal: ValidsSpacing.sm, // px-sm
        vertical: ValidsSpacing.xs, // py-xs
      ),
      decoration: const BoxDecoration(
        color: ValidsColors.backgroundBold, // bg-bold
        borderRadius: ValidsRadius.smRadius, // rounded-sm
      ),
      child: DefaultTextStyle.merge(
        style: textStyle,
        textAlign: TextAlign.center, // text-center
        child: widget.content ??
            Text(widget.message!, textAlign: TextAlign.center),
      ),
    );

    // Down-pointing arrow, rotated per side and nudged into the bubble so
    // the two shapes merge seamlessly.
    Widget arrow(int quarterTurns, Offset nudge) => Transform.translate(
          offset: nudge,
          child: RotatedBox(
            quarterTurns: quarterTurns,
            child: const CustomPaint(
              size: _arrowSize,
              painter: _InfotipArrowPainter(ValidsColors.backgroundBold),
            ),
          ),
        );

    switch (widget.position) {
      case ValidsInfotipPosition.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [bubble, arrow(0, const Offset(0, -_arrowOverlap))],
        );
      case ValidsInfotipPosition.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [arrow(2, const Offset(0, _arrowOverlap)), bubble],
        );
      case ValidsInfotipPosition.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [bubble, arrow(3, const Offset(-_arrowOverlap, 0))],
        );
      case ValidsInfotipPosition.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [arrow(1, const Offset(_arrowOverlap, 0)), bubble],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final anchor = _anchor;
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _setOpen(false),
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              targetAnchor: anchor.target,
              followerAnchor: anchor.follower,
              child: Material(
                color: Colors.transparent,
                child: _buildPopup(),
              ),
            ),
          ],
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: MouseRegion(
          onEnter: (_) => _handleHoverEnter(),
          onExit: (_) => _handleHoverExit(),
          child: GestureDetector(
            onTap: _toggle,
            child: widget.child ??
                const Icon(
                  Icons.info_outline,
                  size: _triggerIconSize,
                  color: ValidsColors.textSoft,
                ),
          ),
        ),
      ),
    );
  }
}

/// Paints the DS infotip arrow: a 16×8 triangle pointing down.
class _InfotipArrowPainter extends CustomPainter {
  final Color color;

  const _InfotipArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _InfotipArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

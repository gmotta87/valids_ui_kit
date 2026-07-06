import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Visual and semantic variants of a [ValidsAlert], matching the ValiDS
/// design system (`info | success | warning | error`).
enum ValidsAlertVariant { info, success, warning, error }

/// A contextual message with an icon, title and optional description,
/// mirroring the design system's `ds-alert`.
///
/// DS anatomy: `p-md` container, `rounded-md`, `border-sm`, background
/// `feedback-*-default` (tone 50) and border/icon/text `feedback-*` (tone
/// 800); icon and close button vertically centered beside the text column
/// with a `gap-x-xs` (8px) gutter. Title uses `ts-heading-sm` and the
/// description `ts-body-sm`.
///
/// Like the DS `Alert.Root`, the widget manages its own visibility: pressing
/// the close button hides it (uncontrolled) and fires [onClose]. Pass [open]
/// to control visibility externally.
///
/// Extras beyond the DS: [showIcon] to omit the variant icon and [content]
/// to render rich text (e.g. a link) in place of the plain [description].
class ValidsAlert extends StatefulWidget {
  final String title;
  final String? description;

  /// Rich body rendered instead of [description] (extra beyond the DS
  /// string-based usage; the DS accepts arbitrary `Alert.Description`
  /// children).
  final Widget? content;
  final ValidsAlertVariant variant;

  /// When non-null, shows the close button and is called when it is pressed.
  final VoidCallback? onClose;

  /// Controlled visibility. When set, the alert no longer hides itself on
  /// close — mirror the DS `open` prop by updating it from [onClose].
  final bool? open;

  /// Initial visibility when uncontrolled (DS `defaultOpen`, default `true`).
  final bool defaultOpen;

  /// Extra beyond the DS: hides the variant icon.
  final bool showIcon;

  const ValidsAlert({
    super.key,
    required this.title,
    this.description,
    this.content,
    this.variant = ValidsAlertVariant.info,
    this.onClose,
    this.open,
    this.defaultOpen = true,
    this.showIcon = true,
  });

  @override
  State<ValidsAlert> createState() => _ValidsAlertState();
}

class _ValidsAlertState extends State<ValidsAlert> {
  /// DS icons render at `size-lg` (24px).
  static const double _iconSize = ValidsSpacing.lg;

  late bool _open = widget.open ?? widget.defaultOpen;

  bool get _isControlled => widget.open != null;

  void _handleClose() {
    if (!_isControlled) setState(() => _open = false);
    widget.onClose?.call();
  }

  Color get _backgroundColor {
    // `bg-feedback-*-default` → tone 50.
    switch (widget.variant) {
      case ValidsAlertVariant.success:
        return ValidsColors.successSoft;
      case ValidsAlertVariant.warning:
        return ValidsColors.warningSoft;
      case ValidsAlertVariant.error:
        return ValidsColors.dangerSoft;
      case ValidsAlertVariant.info:
        return ValidsColors.infoSoft;
    }
  }

  Color get _accentColor {
    // `border-feedback-*` / `text-feedback-*` / `icon-feedback-*` → tone 800.
    switch (widget.variant) {
      case ValidsAlertVariant.success:
        return ValidsColors.successDark;
      case ValidsAlertVariant.warning:
        return ValidsColors.warningDark;
      case ValidsAlertVariant.error:
        return ValidsColors.dangerDark;
      case ValidsAlertVariant.info:
        return ValidsColors.infoDark;
    }
  }

  /// DS icon mapping: lightbulb (info), check-circle (success),
  /// warning (warning), error (error).
  IconData get _icon {
    switch (widget.variant) {
      case ValidsAlertVariant.success:
        return Icons.check_circle_outline;
      case ValidsAlertVariant.warning:
        return Icons.warning_amber_rounded;
      case ValidsAlertVariant.error:
        return Icons.error_outline;
      case ValidsAlertVariant.info:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool visible = widget.open ?? _open;
    if (!visible) return const SizedBox.shrink();

    final Color accent = _accentColor;
    final TextStyle bodyStyle =
        ValidsTypography.bodySm.copyWith(color: accent);
    final Widget? body = widget.content != null
        ? DefaultTextStyle.merge(style: bodyStyle, child: widget.content!)
        : (widget.description != null
            ? Text(widget.description!, style: bodyStyle)
            : null);

    return Container(
      padding: const EdgeInsets.all(ValidsSpacing.md),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: ValidsRadius.mdRadius,
        border: Border.all(color: accent, width: ValidsBorderWidth.sm),
      ),
      child: Row(
        // Icon and close button are `self-center` in the DS grid.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.showIcon) ...[
            Icon(_icon, color: accent, size: _iconSize),
            const SizedBox(width: ValidsSpacing.xs), // gap-x-xs
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: ValidsTypography.headingSm.copyWith(color: accent),
                ),
                if (body != null) body,
              ],
            ),
          ),
          if (widget.onClose != null) ...[
            const SizedBox(width: ValidsSpacing.xs), // gap-x-xs
            _AlertCloseButton(accent: accent, onTap: _handleClose),
          ],
        ],
      ),
    );
  }
}

/// The DS `Alert.Close`: a ghost icon button in the variant's feedback color
/// (`size-lg` icon, `rounded-sm`, hover at 10% of the accent).
class _AlertCloseButton extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;

  const _AlertCloseButton({required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: ValidsRadius.smRadius,
        hoverColor: accent.withValues(alpha: 0.10),
        child: Semantics(
          label: 'Fechar alerta',
          button: true,
          child: Icon(
            Icons.close,
            color: accent,
            size: _ValidsAlertState._iconSize,
          ),
        ),
      ),
    );
  }
}

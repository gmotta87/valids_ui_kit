import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_button.dart';
import 'valids_dialog.dart';

/// Semantic intent of a [ValidsAlertDialog]'s confirm action:
/// `brand` (default) or `destructive` (mirrors the DS `AlertDialog.Action`
/// button `kind`).
enum ValidsAlertDialogKind { brand, destructive }

/// A confirmation dialog mirroring the design system's `ds-alert-dialog`:
/// the same popup as [ValidsDialog] (`rounded-lg`, `bg-default`, `p-md`,
/// `shadow-lg`, `gap-md` column) rendered as a modal that cannot be
/// dismissed by clicking the backdrop, with an outlined Cancel button and a
/// filled Action button (`gap-xs`, end-aligned, footer `mt-xs`).
///
/// Extras beyond the DS: [ValidsAlertDialog.show] returning the choice as a
/// `bool` and an async [onConfirm] that keeps the dialog open with a loading
/// state until it completes.
class ValidsAlertDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final ValidsAlertDialogKind kind;
  final ValidsDialogSize size;
  final bool showCloseButton;

  /// Awaited before closing; the confirm button shows a spinner meanwhile.
  final Future<void> Function()? onConfirm;

  const ValidsAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.kind = ValidsAlertDialogKind.brand,
    this.size = ValidsDialogSize.sm,
    this.showCloseButton = false,
    this.onConfirm,
  });

  /// Shows the dialog and resolves to `true` (confirmed), `false`
  /// (cancelled) or `null` (closed via the header X).
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    ValidsAlertDialogKind kind = ValidsAlertDialogKind.brand,
    ValidsDialogSize size = ValidsDialogSize.sm,
    bool showCloseButton = false,
    Future<void> Function()? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      // DS alert dialogs set `disablePointerDismissal`.
      barrierDismissible: false,
      barrierColor: validsDialogBarrierColor(),
      builder: (context) => ValidsAlertDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        kind: kind,
        size: size,
        showCloseButton: showCloseButton,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<ValidsAlertDialog> createState() => _ValidsAlertDialogState();
}

class _ValidsAlertDialogState extends State<ValidsAlertDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (widget.onConfirm != null) {
      setState(() => _isLoading = true);
      await widget.onConfirm!();
      if (!mounted) return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // ds-alert-dialog-viewport: p-md inset around the popup.
      insetPadding: const EdgeInsets.all(ValidsSpacing.md),
      child: Container(
        constraints:
            BoxConstraints(maxWidth: validsDialogMaxWidth(widget.size)),
        padding: const EdgeInsets.all(ValidsSpacing.md), // popup p-md
        decoration: const BoxDecoration(
          color: ValidsColors.backgroundDefault, // bg-default
          borderRadius: ValidsRadius.lgRadius, // rounded-lg
          boxShadow: validsDialogShadow, // shadow-lg
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ds-alert-dialog-header: items-start justify-between gap-xs.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: ValidsTypography.headingMd
                        .copyWith(color: ValidsColors.textDefault),
                  ),
                ),
                if (widget.showCloseButton) ...[
                  const SizedBox(width: ValidsSpacing.xs), // gap-xs
                  ValidsDialogCloseButton(
                    onTap: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: ValidsSpacing.md), // popup gap-md
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  widget.message,
                  style: ValidsTypography.bodyMd
                      .copyWith(color: ValidsColors.textDefault),
                ),
              ),
            ),
            // gap-md from the column plus the footer's own mt-xs.
            const SizedBox(height: ValidsSpacing.md + ValidsSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // justify-end
              children: [
                // ds-alert-dialog-cancel: outlined button.
                ValidsButton(
                  label: widget.cancelLabel,
                  variant: ValidsButtonVariant.outlined,
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: ValidsSpacing.xs), // gap-xs
                // ds-alert-dialog-action: filled button, kind-aware.
                ValidsButton(
                  label: widget.confirmLabel,
                  kind: widget.kind == ValidsAlertDialogKind.destructive
                      ? ValidsButtonKind.destructive
                      : ValidsButtonKind.brand,
                  loading: _isLoading,
                  onPressed: _handleConfirm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/sizing.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_button.dart';

/// Width of a [ValidsDialog], matching the ValiDS design system
/// (`max-w-xs | max-w-lg | max-w-3xl | max-w-5xl | max-w-7xl`).
enum ValidsDialogSize { xs, sm, md, lg, xl }

/// Maximum popup width per [ValidsDialogSize] (DS `ds-dialog-popup` size
/// variants). Shared with [ValidsAlertDialog].
double validsDialogMaxWidth(ValidsDialogSize size) {
  switch (size) {
    case ValidsDialogSize.xs:
      return ValidsSizing.xs; // max-w-xs (320)
    case ValidsDialogSize.sm:
      return ValidsSizing.lg; // max-w-lg (512)
    case ValidsDialogSize.md:
      return ValidsSizing.xl3; // max-w-3xl (768)
    case ValidsDialogSize.lg:
      return ValidsSizing.xl5; // max-w-5xl (1024)
    case ValidsDialogSize.xl:
      return ValidsSizing.xl7; // max-w-7xl (1280)
  }
}

/// Approximation of the DS `overlay-backdrop` (an opaque `bg-bold` layer
/// composited with `mix-blend-mode: multiply`, which Flutter modal barriers
/// cannot reproduce): `background-color-bold` at 75% opacity.
Color validsDialogBarrierColor() =>
    ValidsColors.backgroundBold.withValues(alpha: 0.75);

/// The DS `shadow-lg` box shadow (two 10%-black layers).
const List<BoxShadow> validsDialogShadow = [
  BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 10),
    blurRadius: 15,
    spreadRadius: -3,
  ),
  BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -4,
  ),
];

/// The DS `Dialog.Close` / `AlertDialog.Close`: neutral ghost icon button
/// (`text-soft` X at `size-lg`, `rounded-sm`, hover `bg-bold/10`).
class ValidsDialogCloseButton extends StatelessWidget {
  /// DS close icons render at `size-lg` (24px).
  static const double _iconSize = ValidsSpacing.lg;

  final VoidCallback? onTap;
  final String semanticLabel;

  const ValidsDialogCloseButton({
    super.key,
    required this.onTap,
    this.semanticLabel = 'fechar modal',
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: ValidsRadius.smRadius,
        hoverColor: ValidsColors.backgroundBold.withValues(alpha: 0.10),
        child: Semantics(
          label: semanticLabel,
          button: true,
          child: const Icon(
            Icons.close,
            size: _iconSize,
            color: ValidsColors.textSoft,
          ),
        ),
      ),
    );
  }
}

/// A general-purpose modal dialog mirroring the design system's `ds-dialog`:
/// header (title + optional close button), a scrollable body and an optional
/// footer with actions.
///
/// DS anatomy: viewport with `p-md` inset, popup `rounded-lg` on
/// `bg-default` with `p-md`, `shadow-lg` and a `gap-md` column; title
/// `ts-heading-md`; footer `mt-xs` with `gap-xs` actions aligned to the end
/// (primary filled, secondary outlined).
///
/// For an arbitrary body (e.g. a form) pass [content]; for a simple text
/// body pass [message].
class ValidsDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final ValidsDialogSize size;
  final bool showCloseButton;
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryPressed;

  const ValidsDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.size = ValidsDialogSize.sm,
    this.showCloseButton = true,
    this.primaryButtonLabel,
    this.onPrimaryPressed,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    ValidsDialogSize size = ValidsDialogSize.sm,
    bool showCloseButton = true,
    String? primaryButtonLabel,
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonLabel,
    VoidCallback? onSecondaryPressed,
  }) {
    return showDialog(
      context: context,
      barrierColor: validsDialogBarrierColor(),
      builder: (context) => ValidsDialog(
        title: title,
        message: message,
        content: content,
        size: size,
        showCloseButton: showCloseButton,
        primaryButtonLabel: primaryButtonLabel,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonLabel: secondaryButtonLabel,
        onSecondaryPressed: onSecondaryPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFooter =
        primaryButtonLabel != null || secondaryButtonLabel != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // ds-dialog-viewport: p-md inset around the popup.
      insetPadding: const EdgeInsets.all(ValidsSpacing.md),
      child: Container(
        constraints: BoxConstraints(maxWidth: validsDialogMaxWidth(size)),
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
            // ds-dialog-header: items-start justify-between gap-xs.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: ValidsTypography.headingMd
                        .copyWith(color: ValidsColors.textDefault),
                  ),
                ),
                if (showCloseButton) ...[
                  const SizedBox(width: ValidsSpacing.xs), // gap-xs
                  ValidsDialogCloseButton(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ],
            ),
            // Popup column gap-md between header, body and footer.
            if (content != null || message != null) ...[
              const SizedBox(height: ValidsSpacing.md),
              Flexible(
                child: SingleChildScrollView(
                  child: content ??
                      Text(
                        message!,
                        style: ValidsTypography.bodyMd
                            .copyWith(color: ValidsColors.textDefault),
                      ),
                ),
              ),
            ],
            if (hasFooter) ...[
              // gap-md from the column plus the footer's own mt-xs.
              const SizedBox(height: ValidsSpacing.md + ValidsSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // justify-end
                children: [
                  if (secondaryButtonLabel != null)
                    ValidsButton(
                      label: secondaryButtonLabel!,
                      variant: ValidsButtonVariant.outlined,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSecondaryPressed?.call();
                      },
                    ),
                  if (secondaryButtonLabel != null &&
                      primaryButtonLabel != null)
                    const SizedBox(width: ValidsSpacing.xs), // gap-xs
                  if (primaryButtonLabel != null)
                    ValidsButton(
                      label: primaryButtonLabel!,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onPrimaryPressed?.call();
                      },
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

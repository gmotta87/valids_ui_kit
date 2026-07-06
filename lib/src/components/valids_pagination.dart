import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_button.dart';
import 'valids_icon_button.dart';

/// Pagination control mirroring the design system's Pagination
/// (`ds-pagination`): previous/next ghost chevrons, bordered page squares,
/// an active page highlighted with the brand color and `...` separators when
/// the range is truncated.
class ValidsPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChange;

  /// Number of pages shown on each side of the current page.
  final int siblings;
  final bool disabled;

  const ValidsPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPageChange,
    this.siblings = 0,
    this.disabled = false,
  });

  /// `size-2xl` in the DS.
  static const double _itemSize = ValidsSpacing.xl2;

  bool get _isEnabled => !disabled && onPageChange != null;

  /// Builds the visible page slots, where `null` represents an ellipsis.
  /// Mirrors the DS `getPaginationRange` helper.
  List<int?> _buildPageSlots() {
    final int maxVisible = siblings * 2 + 5;
    if (totalPages <= maxVisible) {
      return [for (int i = 1; i <= totalPages; i++) i];
    }

    final int leftSibling = (currentPage - siblings).clamp(1, totalPages);
    final int rightSibling = (currentPage + siblings).clamp(1, totalPages);
    final bool showLeftEllipsis = leftSibling > 2;
    final bool showRightEllipsis = rightSibling < totalPages - 1;

    if (!showLeftEllipsis && showRightEllipsis) {
      final int leftCount = 3 + siblings * 2;
      return [
        for (int i = 1; i <= leftCount; i++) i,
        null,
        totalPages,
      ];
    }
    if (showLeftEllipsis && !showRightEllipsis) {
      final int rightCount = 3 + siblings * 2;
      return [
        1,
        null,
        for (int i = totalPages - rightCount + 1; i <= totalPages; i++) i,
      ];
    }
    return [
      1,
      null,
      for (int i = leftSibling; i <= rightSibling; i++) i,
      null,
      totalPages,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: ValidsSpacing.xs2,
      runSpacing: ValidsSpacing.xs2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Previous — ghost/neutral/sm icon button, soft-disabled on page 1.
        ValidsIconButton(
          icon: Icons.chevron_left,
          kind: ValidsIconButtonKind.neutral,
          variant: ValidsButtonVariant.ghost,
          size: ValidsButtonSize.sm,
          disabled: disabled || currentPage <= 1,
          onPressed:
              _isEnabled ? () => onPageChange!(currentPage - 1) : null,
        ),
        for (final int? slot in _buildPageSlots())
          slot == null
              ? _PaginationEllipsis(disabled: disabled)
              : _PaginationPage(
                  page: slot,
                  isActive: slot == currentPage,
                  disabled: disabled,
                  onTap: _isEnabled && slot != currentPage
                      ? () => onPageChange!(slot)
                      : null,
                ),
        // Next — soft-disabled on the last page.
        ValidsIconButton(
          icon: Icons.chevron_right,
          kind: ValidsIconButtonKind.neutral,
          variant: ValidsButtonVariant.ghost,
          size: ValidsButtonSize.sm,
          disabled: disabled || currentPage >= totalPages,
          onPressed:
              _isEnabled ? () => onPageChange!(currentPage + 1) : null,
        ),
      ],
    );
  }
}

/// Shared bordered rounded square (`size-2xl rounded-md border ts-body-md`).
class _PaginationItem extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color borderColor;
  final VoidCallback? onTap;
  final Color? hoverOverlay;

  const _PaginationItem({
    required this.child,
    required this.background,
    required this.borderColor,
    this.onTap,
    this.hoverOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ValidsPagination._itemSize,
      height: ValidsPagination._itemSize,
      child: Material(
        color: background,
        borderRadius: ValidsRadius.mdRadius,
        child: InkWell(
          borderRadius: ValidsRadius.mdRadius,
          hoverColor: hoverOverlay,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: ValidsRadius.mdRadius,
              border: Border.all(
                color: borderColor,
                width: ValidsBorderWidth.sm,
              ),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// A page square (`ds-pagination-page`), with the DS hover states:
/// inactive pages gain the brand border/text color on hover; the active page
/// gains a 10% brand overlay.
class _PaginationPage extends StatefulWidget {
  final int page;
  final bool isActive;
  final bool disabled;
  final VoidCallback? onTap;

  const _PaginationPage({
    required this.page,
    required this.isActive,
    required this.disabled,
    this.onTap,
  });

  @override
  State<_PaginationPage> createState() => _PaginationPageState();
}

class _PaginationPageState extends State<_PaginationPage> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool interactive = !widget.disabled && widget.onTap != null;
    final bool brandHover = _hovered && interactive && !widget.isActive;

    final Color background = widget.isActive && !widget.disabled
        ? ValidsColors.primarySofter
        : ValidsColors.backgroundDefault;
    final Color borderColor = widget.disabled
        ? ValidsColors.borderSoft
        : widget.isActive || brandHover
            ? ValidsColors.primary
            : ValidsColors.borderSoft;
    final Color textColor = widget.disabled
        ? ValidsColors.textInactive
        : widget.isActive || brandHover
            ? ValidsColors.primary
            : ValidsColors.textSoft;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: _PaginationItem(
        background: background,
        borderColor: borderColor,
        hoverOverlay: widget.isActive && !widget.disabled
            ? ValidsColors.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        onTap: interactive ? widget.onTap : null,
        child: Text(
          '${widget.page}',
          style: ValidsTypography.bodyMd.copyWith(color: textColor),
        ),
      ),
    );
  }
}

/// The `...` separator (`ds-pagination-ellipsis`).
class _PaginationEllipsis extends StatelessWidget {
  final bool disabled;

  const _PaginationEllipsis({required this.disabled});

  @override
  Widget build(BuildContext context) {
    return _PaginationItem(
      background: ValidsColors.backgroundDefault,
      borderColor: ValidsColors.borderSoft,
      child: Text(
        '...',
        style: ValidsTypography.bodyMd.copyWith(
          color:
              disabled ? ValidsColors.textInactive : ValidsColors.textSoft,
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'valids_button.dart';

/// Semantic color of a [ValidsCopyButton], matching the ValiDS design system
/// (same kinds as the icon button; DS default is `neutral`).
enum ValidsCopyButtonKind {
  brand,
  destructive,
  neutral,
  success,
  error,
  info,
  warning,
}

/// Hint texts for each copy state, mirroring the DS `hints` prop.
class ValidsCopyButtonHints {
  final String idle;
  final String copied;
  final String error;

  const ValidsCopyButtonHints({
    this.idle = 'Copiar',
    this.copied = 'Copiado',
    this.error = 'Erro ao copiar',
  });
}

/// Button that copies a value to the clipboard, showing feedback for the
/// idle / copied / error states.
///
/// Mirrors the design system's `ds-copy-button` (`value`, `hints`,
/// `autoCloseDelay`, `onError`, `kind`/`variant`/`size`, `disabled`), reusing
/// [ValidsButtonVariant] and [ValidsButtonSize] for the shared tokens.
/// DS defaults: `kind: neutral`, `variant: ghost`, `size: none`.
///
/// Extras beyond the DS: [showLabel] renders the current hint inline, and the
/// icon/accent change with the copy state.
class ValidsCopyButton extends StatefulWidget {
  final String value;

  /// Hint texts per state (DS `hints`). Falls back to the deprecated
  /// per-state labels, then to the DS defaults.
  final ValidsCopyButtonHints? hints;

  @Deprecated('Use hints (ValidsCopyButtonHints.idle) instead')
  final String? copyLabel;

  @Deprecated('Use hints (ValidsCopyButtonHints.copied) instead')
  final String? copiedLabel;

  @Deprecated('Use hints (ValidsCopyButtonHints.error) instead')
  final String? errorLabel;

  final ValidsCopyButtonKind kind;
  final ValidsButtonVariant variant;
  final ValidsButtonSize size;
  final bool disabled;

  /// Renders the current hint text next to the icon (extra beyond the DS).
  final bool showLabel;

  /// How long the copied/error feedback stays before returning to idle.
  final Duration autoCloseDelay;

  /// Called before the copy attempt (DS `onClick`).
  final VoidCallback? onPressed;

  /// Called when writing to the clipboard fails (DS `onError`).
  final ValueChanged<Object>? onError;

  const ValidsCopyButton({
    super.key,
    required this.value,
    this.hints,
    @Deprecated('Use hints (ValidsCopyButtonHints.idle) instead')
    this.copyLabel,
    @Deprecated('Use hints (ValidsCopyButtonHints.copied) instead')
    this.copiedLabel,
    @Deprecated('Use hints (ValidsCopyButtonHints.error) instead')
    this.errorLabel,
    this.kind = ValidsCopyButtonKind.neutral,
    this.variant = ValidsButtonVariant.ghost,
    this.size = ValidsButtonSize.none,
    this.disabled = false,
    this.showLabel = false,
    this.autoCloseDelay = const Duration(seconds: 2),
    this.onPressed,
    this.onError,
  });

  @override
  State<ValidsCopyButton> createState() => _ValidsCopyButtonState();
}

enum _CopyState { idle, copied, error }

class _ValidsCopyButtonState extends State<ValidsCopyButton> {
  _CopyState _state = _CopyState.idle;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  ValidsCopyButtonHints get _hints {
    if (widget.hints != null) return widget.hints!;
    const ValidsCopyButtonHints defaults = ValidsCopyButtonHints();
    // ignore: deprecated_member_use_from_same_package
    return ValidsCopyButtonHints(
      // ignore: deprecated_member_use_from_same_package
      idle: widget.copyLabel ?? defaults.idle,
      // ignore: deprecated_member_use_from_same_package
      copied: widget.copiedLabel ?? defaults.copied,
      // ignore: deprecated_member_use_from_same_package
      error: widget.errorLabel ?? defaults.error,
    );
  }

  Future<void> _copy() async {
    widget.onPressed?.call();
    try {
      await Clipboard.setData(ClipboardData(text: widget.value));
      if (!mounted) return;
      setState(() => _state = _CopyState.copied);
    } catch (error) {
      widget.onError?.call(error);
      if (!mounted) return;
      setState(() => _state = _CopyState.error);
    }
    _resetTimer?.cancel();
    _resetTimer = Timer(widget.autoCloseDelay, () {
      if (mounted) setState(() => _state = _CopyState.idle);
    });
  }

  /// Resting accent per kind (the DS `--ib-ghost`/`--ib-outline` slot).
  Color get _kindColor {
    switch (widget.kind) {
      case ValidsCopyButtonKind.brand:
        return ValidsColors.primary;
      case ValidsCopyButtonKind.destructive:
      case ValidsCopyButtonKind.error:
        return ValidsColors.dangerDark;
      case ValidsCopyButtonKind.neutral:
        return ValidsColors.textSoft;
      case ValidsCopyButtonKind.success:
        return ValidsColors.successDark;
      case ValidsCopyButtonKind.info:
        return ValidsColors.infoDark;
      case ValidsCopyButtonKind.warning:
        return ValidsColors.warningDark;
    }
  }

  /// State accent extra: copied/error temporarily recolor the button.
  Color get _accent {
    switch (_state) {
      case _CopyState.copied:
        return ValidsColors.success;
      case _CopyState.error:
        return ValidsColors.danger;
      case _CopyState.idle:
        return _kindColor;
    }
  }

  IconData get _icon {
    switch (_state) {
      case _CopyState.copied:
        return Icons.check;
      case _CopyState.error:
        return Icons.error_outline;
      case _CopyState.idle:
        return Icons.copy;
    }
  }

  String get _label {
    switch (_state) {
      case _CopyState.copied:
        return _hints.copied;
      case _CopyState.error:
        return _hints.error;
      case _CopyState.idle:
        return _hints.idle;
    }
  }

  /// DS icons render at `size-lg` (24px).
  static const double _iconSize = ValidsSpacing.lg;

  /// p-md (md) / p-xs (sm) / none — same scale as the icon button.
  EdgeInsetsGeometry get _padding {
    switch (widget.size) {
      case ValidsButtonSize.md:
        return const EdgeInsets.all(ValidsSpacing.md);
      case ValidsButtonSize.sm:
        return const EdgeInsets.all(ValidsSpacing.xs);
      case ValidsButtonSize.none:
        return EdgeInsets.zero;
    }
  }

  /// `rounded-md`, or `rounded-sm` for size `none`.
  BorderRadius get _radius => widget.size == ValidsButtonSize.none
      ? ValidsRadius.smRadius
      : ValidsRadius.mdRadius;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.disabled;
    final Color accent = _accent;
    final bool isFilled = widget.variant == ValidsButtonVariant.filled;
    final bool isOutlined = widget.variant == ValidsButtonVariant.outlined;

    // Filled slots: neutral uses bg-default/text-soft (DS `--ib-fill`); the
    // other kinds fill with the accent and invert the text.
    final bool neutralIdleFill = widget.kind == ValidsCopyButtonKind.neutral &&
        _state == _CopyState.idle;
    final Color fill =
        neutralIdleFill ? ValidsColors.backgroundDefault : accent;
    final Color fillText =
        neutralIdleFill ? ValidsColors.textSoft : ValidsColors.textInvert;

    final Color background = isFilled
        ? (isDisabled ? ValidsColors.backgroundInactive : fill)
        : (isOutlined ? ValidsColors.backgroundDefault : Colors.transparent);
    final Color foreground = isFilled
        ? (isDisabled ? ValidsColors.textInvert : fillText)
        : (isDisabled ? ValidsColors.textInactive : accent);
    final Color borderColor = isOutlined || isFilled
        ? (isDisabled
            ? ValidsColors.borderInactive
            : (isFilled ? background : accent))
        : Colors.transparent;
    final Color? overlay =
        isDisabled ? null : accent.withValues(alpha: 0.10);

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: _iconSize, color: foreground),
        if (widget.showLabel) ...[
          const SizedBox(width: ValidsSpacing.xs), // gap-xs
          Text(
            _label,
            style: ValidsTypography.captionMd.copyWith(color: foreground),
          ),
        ],
      ],
    );

    return Tooltip(
      message: _label,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(color: borderColor, width: ValidsBorderWidth.sm),
        ),
        child: InkWell(
          onTap: isDisabled ? null : _copy,
          borderRadius: _radius,
          hoverColor: overlay,
          splashColor: overlay,
          highlightColor: overlay,
          child: Padding(padding: _padding, child: content),
        ),
      ),
    );
  }
}

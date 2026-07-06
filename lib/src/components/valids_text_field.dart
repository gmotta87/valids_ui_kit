import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'internal/field_chrome.dart';

/// Single-line text input mirroring the design system's `ds-text-field`:
/// a 56px `field-wrapper` box with floating [label], optional
/// [startAdornment] / [endAdornment], and a support/error text below
/// ([description] / [errorMessage]).
///
/// Extras beyond the DS API, kept from the previous implementation:
/// [isRequired] tag next to the label, [readOnly], [autofocus],
/// [controller], [keyboardType], [obscureText] (with visibility toggle),
/// [inputFormatters] (masks) and [maxLength].
class ValidsTextField extends StatefulWidget {
  final String? label;
  final String? description;
  final String? placeholder;
  final String? errorMessage;

  /// When `true` shows an "Obrigatório" tag next to the label,
  /// when `false` shows an "Opcional" tag. `null` hides the tag.
  final bool? isRequired;
  final bool disabled;
  final bool readOnly;
  final bool autofocus;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? startAdornment;
  final Widget? endAdornment;
  final int? maxLength;

  const ValidsTextField({
    super.key,
    this.label,
    this.description,
    this.placeholder,
    this.errorMessage,
    this.isRequired,
    this.disabled = false,
    this.readOnly = false,
    this.autofocus = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
    this.startAdornment,
    this.endAdornment,
    this.maxLength,
  });

  @override
  State<ValidsTextField> createState() => _ValidsTextFieldState();
}

class _ValidsTextFieldState extends State<ValidsTextField> {
  late bool _obscured = widget.obscureText;
  late TextEditingController _controller;
  late bool _ownsController;
  final FocusNode _focusNode = FocusNode();
  bool _hovered = false;
  bool _hasText = false;

  bool get _invalid => widget.errorMessage != null;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(ValidsTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleTextChange);
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_handleTextChange);
      _hasText = _controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (_ownsController) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final bool hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _handleFocusChange() => setState(() {});

  /// The label floats when focused, filled or with a start adornment
  /// (`data-has-start-adornment`).
  bool get _floated =>
      _focusNode.hasFocus || _hasText || widget.startAdornment != null;

  /// DS shows the placeholder only once the label is out of the way.
  bool get _showPlaceholder =>
      widget.label == null ||
      _focusNode.hasFocus ||
      widget.startAdornment != null;

  Widget? _buildEndAdornment() {
    if (widget.obscureText) {
      // Extra: visibility toggle for password fields.
      return IconButton(
        onPressed: widget.disabled
            ? null
            : () => setState(() => _obscured = !_obscured),
        padding: EdgeInsets.zero,
        icon: Icon(
          _obscured ? Icons.visibility_off : Icons.visibility,
          size: ValidsSpacing.lg,
          color: widget.disabled
              ? ValidsColors.textInactive
              : ValidsColors.textSoft,
        ),
      );
    }
    if (widget.endAdornment != null) {
      return FieldAdornment(
        disabled: widget.disabled,
        child: widget.endAdornment!,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget? endAdornment = _buildEndAdornment();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: widget.disabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.text,
          child: GestureDetector(
            onTap: widget.disabled ? null : _focusNode.requestFocus,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FieldWrapper(
                  // `h-14` (56px).
                  height: ValidsSpacing.xl4,
                  hovered: _hovered,
                  focused: _focusNode.hasFocus,
                  invalid: _invalid,
                  disabled: widget.disabled,
                  child: Row(
                    children: [
                      if (widget.startAdornment != null) ...[
                        FieldAdornment(
                          disabled: widget.disabled,
                          child: widget.startAdornment!,
                        ),
                        const SizedBox(width: ValidsSpacing.xs),
                      ],
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: widget.onChanged,
                          enabled: !widget.disabled,
                          readOnly: widget.readOnly,
                          autofocus: widget.autofocus,
                          keyboardType: widget.keyboardType,
                          obscureText: _obscured,
                          inputFormatters: [
                            ...?widget.inputFormatters,
                            if (widget.maxLength != null)
                              LengthLimitingTextInputFormatter(
                                widget.maxLength,
                              ),
                          ],
                          style: ValidsTypography.bodyMd.copyWith(
                            color: widget.disabled
                                ? ValidsColors.textInactive
                                : ValidsColors.textDefault,
                          ),
                          cursorColor: ValidsColors.primary,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: _showPlaceholder
                                ? widget.placeholder
                                : null,
                            hintStyle: ValidsTypography.bodyMd.copyWith(
                              color: ValidsColors.textInactive,
                            ),
                          ),
                        ),
                      ),
                      if (endAdornment != null) ...[
                        const SizedBox(width: ValidsSpacing.xs),
                        endAdornment,
                      ],
                    ],
                  ),
                ),
                if (widget.label != null)
                  FieldFloatingLabel(
                    label: widget.label!,
                    floated: _floated,
                    invalid: _invalid,
                    disabled: widget.disabled,
                    trailing: widget.isRequired == null
                        ? null
                        : FieldRequiredTag(isRequired: widget.isRequired!),
                  ),
              ],
            ),
          ),
        ),
        FieldSupport(
          description: widget.description,
          errorMessage: widget.errorMessage,
        ),
      ],
    );
  }
}

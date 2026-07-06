import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'internal/field_chrome.dart';

/// Multi-line text input mirroring the design system's `ds-text-area`:
/// a `field-wrapper` box with 144px min height (`min-h-36`), floating
/// [label], optional character counter inside the box (when [maxLength] is
/// set) and support/error text below ([description] / [errorMessage]).
///
/// Extras beyond the DS API, kept from the previous implementation:
/// [isRequired] tag next to the label, [readOnly], [controller],
/// [minLines] / [maxLines] and [showCounter].
class ValidsTextArea extends StatefulWidget {
  final String? label;
  final String? description;
  final String? placeholder;
  final String? errorMessage;

  /// When `true` shows an "Obrigatório" tag next to the label,
  /// when `false` shows an "Opcional" tag. `null` hides the tag.
  final bool? isRequired;
  final bool disabled;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  /// Shows the character counter inside the field when [maxLength] is set.
  final bool showCounter;

  const ValidsTextArea({
    super.key,
    this.label,
    this.description,
    this.placeholder,
    this.errorMessage,
    this.isRequired,
    this.disabled = false,
    this.readOnly = false,
    this.controller,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.showCounter = true,
  });

  @override
  State<ValidsTextArea> createState() => _ValidsTextAreaState();
}

class _ValidsTextAreaState extends State<ValidsTextArea> {
  /// `min-h-36` (36 × 4px).
  static const double _minHeight = 144;

  late TextEditingController _controller;
  late bool _ownsController;
  final FocusNode _focusNode = FocusNode();
  bool _hovered = false;

  bool get _invalid => widget.errorMessage != null;

  bool get _hasCounter => widget.maxLength != null && widget.showCounter;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(ValidsTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleTextChange);
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_handleTextChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (_ownsController) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Rebuild to update the floating label and the character counter.
  void _handleTextChange() => setState(() {});

  void _handleFocusChange() => setState(() {});

  /// The label floats when the field is focused or filled.
  bool get _floated => _focusNode.hasFocus || _controller.text.isNotEmpty;

  /// DS shows the placeholder only once the label is out of the way.
  bool get _showPlaceholder => widget.label == null || _focusNode.hasFocus;

  /// Counter: `ts-body-xs text-default`; `text-inactive` when disabled and
  /// `text-feedback-error` when invalid.
  Color get _counterColor {
    if (widget.disabled) return ValidsColors.textInactive;
    if (_invalid) return ValidsColors.dangerDark;
    return ValidsColors.textDefault;
  }

  @override
  Widget build(BuildContext context) {
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
                  constraints: const BoxConstraints(minHeight: _minHeight),
                  // `p-none pt-xs`, plus `pb-xs` when there is no counter.
                  padding: EdgeInsets.only(
                    top: ValidsSpacing.xs,
                    bottom:
                        _hasCounter ? ValidsSpacing.none : ValidsSpacing.xs,
                  ),
                  hovered: _hovered,
                  focused: _focusNode.hasFocus,
                  invalid: _invalid,
                  disabled: widget.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        // Text content indented by `pl-md`.
                        padding: const EdgeInsets.symmetric(
                          horizontal: ValidsSpacing.md,
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: widget.onChanged,
                          enabled: !widget.disabled,
                          readOnly: widget.readOnly,
                          keyboardType: TextInputType.multiline,
                          minLines: widget.minLines,
                          maxLines: widget.maxLines,
                          inputFormatters: [
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
                      if (_hasCounter)
                        Padding(
                          // Counter row: `px-md py-xs`, right-aligned.
                          padding: const EdgeInsets.symmetric(
                            horizontal: ValidsSpacing.md,
                            vertical: ValidsSpacing.xs,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${_controller.text.length}/${widget.maxLength}',
                              style: ValidsTypography.bodyXs.copyWith(
                                color: _counterColor,
                              ),
                            ),
                          ),
                        ),
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

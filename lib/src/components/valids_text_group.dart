import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Size scale of a [ValidsTextGroup].
///
/// Mirrors the legacy whitelabel `TextGroupSize` enum
/// (`small`, `medium`, `large`).
enum ValidsTextGroupSize { small, medium, large }

/// Horizontal alignment of a [ValidsTextGroup].
///
/// Mirrors the legacy whitelabel `TextGroupAlignment` enum.
enum ValidsTextGroupAlignment { left, center, right }

/// Grupo de textos (título + subtítulo) escalonado por tamanho.
///
/// Reconstrução do `TextGroup` da lib whitelabel legada (storybook
/// "Widgets/Text Group" — "Text Group small/Medium/Large"), adequada aos
/// tokens do design system ValiDS.
///
/// Escala tipográfica (confirmada no legado, onde os subtítulos de
/// `medium` e `large` compartilhavam o mesmo estilo):
///
/// | size   | título                        | subtítulo                  |
/// |--------|-------------------------------|----------------------------|
/// | large  | [ValidsTypography.headingLg]  | [ValidsTypography.bodyMd]  |
/// | medium | [ValidsTypography.headingMd]  | [ValidsTypography.bodyMd]  |
/// | small  | [ValidsTypography.headingSm]  | [ValidsTypography.bodySm]  |
///
/// Assim como no legado, o [subtitle] aceita destaques inline delimitados
/// por asteriscos — `'Aligned at left with *bold*'` renderiza "bold" em
/// negrito.
///
/// ```dart
/// const ValidsTextGroup(
///   title: 'Text Group Large',
///   subtitle: 'Aligned at left with *bold*',
///   size: ValidsTextGroupSize.large,
/// )
/// ```
class ValidsTextGroup extends StatelessWidget {
  /// Título (linha superior, em destaque).
  final String? title;

  /// Subtítulo/descrição. Trechos entre `*asteriscos*` são renderizados
  /// em negrito, como no componente legado.
  final String? subtitle;

  /// Escala dos textos. Padrão: [ValidsTextGroupSize.medium].
  final ValidsTextGroupSize size;

  /// Alinhamento horizontal do grupo. Padrão: esquerda.
  final ValidsTextGroupAlignment alignment;

  const ValidsTextGroup({
    super.key,
    this.title,
    this.subtitle,
    this.size = ValidsTextGroupSize.medium,
    this.alignment = ValidsTextGroupAlignment.left,
  });

  TextStyle get _titleStyle {
    switch (size) {
      case ValidsTextGroupSize.small:
        return ValidsTypography.headingSm;
      case ValidsTextGroupSize.medium:
        return ValidsTypography.headingMd;
      case ValidsTextGroupSize.large:
        return ValidsTypography.headingLg;
    }
  }

  TextStyle get _subtitleStyle {
    switch (size) {
      case ValidsTextGroupSize.small:
        return ValidsTypography.bodySm;
      case ValidsTextGroupSize.medium:
      case ValidsTextGroupSize.large:
        return ValidsTypography.bodyMd;
    }
  }

  /// Estilo dos trechos `*destacados*` do subtítulo (body highlight).
  TextStyle get _subtitleBoldStyle {
    switch (size) {
      case ValidsTextGroupSize.small:
        return ValidsTypography.bodyHighlightSm;
      case ValidsTextGroupSize.medium:
      case ValidsTextGroupSize.large:
        return ValidsTypography.bodyHighlightMd;
    }
  }

  CrossAxisAlignment get _crossAxisAlignment {
    switch (alignment) {
      case ValidsTextGroupAlignment.left:
        return CrossAxisAlignment.start;
      case ValidsTextGroupAlignment.center:
        return CrossAxisAlignment.center;
      case ValidsTextGroupAlignment.right:
        return CrossAxisAlignment.end;
    }
  }

  TextAlign get _textAlign {
    switch (alignment) {
      case ValidsTextGroupAlignment.left:
        return TextAlign.start;
      case ValidsTextGroupAlignment.center:
        return TextAlign.center;
      case ValidsTextGroupAlignment.right:
        return TextAlign.end;
    }
  }

  /// Converte o marcador `*bold*` do legado em [TextSpan]s em negrito.
  List<TextSpan> _parseHighlights(String text, TextStyle base, TextStyle bold) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*([^*]+)\*');
    int index = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > index) {
        spans.add(TextSpan(text: text.substring(index, match.start)));
      }
      spans.add(TextSpan(text: match.group(1), style: bold));
      index = match.end;
    }
    if (index < text.length) {
      spans.add(TextSpan(text: text.substring(index)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (title != null) {
      children.add(
        Text(
          title!,
          textAlign: _textAlign,
          style: _titleStyle.copyWith(color: ValidsColors.textDefault),
        ),
      );
    }

    if (subtitle != null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: ValidsSpacing.xs2));
      }
      children.add(
        Text.rich(
          TextSpan(
            style: _subtitleStyle.copyWith(color: ValidsColors.textSoft),
            children: _parseHighlights(
              subtitle!,
              _subtitleStyle,
              _subtitleBoldStyle,
            ),
          ),
          textAlign: _textAlign,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: _crossAxisAlignment,
      children: children,
    );
  }
}

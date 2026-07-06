import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import 'valids_text_group.dart';

/// Bottom sheet modal com título, subtítulo, conteúdo e ação.
///
/// Reconstrução do `BottomSheet` da lib whitelabel legada (storybook
/// "Widgets/Modal/BottomSheet" — "Exemplo de Bottomsheet"), adequada aos
/// tokens do design system ValiDS. O legado demonstrava todas as
/// combinações de `title`, `child` e `button`, com um cabeçalho composto
/// por um Text Group pequeno + botão de fechar (rotulado
/// "Close Bottom Sheet" para acessibilidade).
///
/// Todos os slots são opcionais e a ordem visual segue o legado:
/// grab handle → cabeçalho (título/subtítulo + fechar) → [child] → [action].
///
/// Prefira a função estática [show]:
///
/// ```dart
/// ValidsBottomSheet.show(
///   context,
///   title: 'Título do bottomsheet',
///   subtitle: 'Subtítulo do bottomsheet',
///   child: Column(children: [...]),
///   action: ValidsButton(label: 'Botão', onPressed: () {}),
/// );
/// ```
class ValidsBottomSheet extends StatelessWidget {
  /// Título do cabeçalho.
  final String? title;

  /// Subtítulo exibido abaixo do título.
  final String? subtitle;

  /// Conteúdo principal (rolável quando maior que o espaço disponível).
  final Widget? child;

  /// Ação exibida ao final (o legado usava uma coluna de botões).
  final Widget? action;

  /// Exibe o botão de fechar no cabeçalho. Padrão: `true`, como no legado.
  final bool showCloseButton;

  const ValidsBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.child,
    this.action,
    this.showCloseButton = true,
  });

  /// Abre o bottom sheet com `showModalBottomSheet`, já estilizado com os
  /// tokens do DS (cantos superiores `radius-lg`, fundo default).
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    Widget? child,
    Widget? action,
    bool showCloseButton = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => ValidsBottomSheet(
        title: title,
        subtitle: subtitle,
        showCloseButton: showCloseButton,
        action: action,
        child: child,
      ),
    );
  }

  /// Grab handle no topo do sheet.
  Widget get _grabHandle => Container(
        width: ValidsSpacing.xl2,
        height: ValidsSpacing.xs2,
        decoration: const BoxDecoration(
          color: ValidsColors.borderSoft,
          borderRadius: ValidsRadius.fullRadius,
        ),
      );

  Widget _buildCloseButton(BuildContext context) {
    return IconButton(
      // Rótulo herdado do legado.
      tooltip: 'Close Bottom Sheet',
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(
        Icons.close,
        size: ValidsSpacing.lg,
        color: ValidsColors.textSoft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasHeaderTexts = title != null || subtitle != null;
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        ValidsSpacing.md,
        ValidsSpacing.xs,
        ValidsSpacing.md,
        ValidsSpacing.md + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: ValidsColors.backgroundDefault,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ValidsRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _grabHandle),
            const SizedBox(height: ValidsSpacing.sm),
            if (hasHeaderTexts || showCloseButton)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: hasHeaderTexts
                        ? ValidsTextGroup(
                            title: title,
                            subtitle: subtitle,
                            size: ValidsTextGroupSize.small,
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (showCloseButton) ...[
                    const SizedBox(width: ValidsSpacing.xs),
                    _buildCloseButton(context),
                  ],
                ],
              ),
            if (child != null) ...[
              const SizedBox(height: ValidsSpacing.md),
              Flexible(child: SingleChildScrollView(child: child)),
            ],
            if (action != null) ...[
              const SizedBox(height: ValidsSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

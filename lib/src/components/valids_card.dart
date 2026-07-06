import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Estado visual de um [ValidsCard].
///
/// Mirrors the legacy whitelabel `CardType` enum
/// (`base`, `validation`, `unavailable`).
enum ValidsCardStatus {
  /// Card padrão: fundo default com borda suave.
  base,

  /// Card aguardando validação: fundo soft, borda destacada e a legenda
  /// "Aguardando validação" (comportamento herdado do legado, usado para
  /// carteiras "Em validação").
  validation,

  /// Card indisponível: fundo de erro suave e ícone de trailing em danger.
  unavailable,
}

/// Card de conteúdo com ícone, título, subtítulo e ação opcional.
///
/// Reconstrução do `Card` da lib whitelabel legada (storybook
/// "Widgets/Card" — "Variações de Cards": Base / Validation / Unavailable /
/// Mixed), adequada aos tokens do design system ValiDS.
///
/// Estrutura (como no legado): um avatar circular com [icon] à esquerda,
/// uma coluna com [title], legenda de validação (quando
/// [ValidsCardStatus.validation]) e [subtitle], um [trailingIcon] à direita
/// e um slot [action] abaixo do cabeçalho (o legado usava um botão).
///
/// ```dart
/// ValidsCard(
///   title: 'Base Card',
///   subtitle: 'Subtitle',
///   icon: Icons.wallet,
///   trailingIcon: Icons.chevron_right,
///   onTap: () {},
/// )
/// ```
class ValidsCard extends StatelessWidget {
  /// Título do card (até 2 linhas, como no legado).
  final String title;

  /// Subtítulo/descrição (até 3 linhas, como no legado).
  final String? subtitle;

  /// Ícone exibido no avatar circular à esquerda.
  final IconData? icon;

  /// Ícone à direita do cabeçalho (ex.: `Icons.chevron_right`).
  /// No status [ValidsCardStatus.unavailable] é pintado em danger.
  final IconData? trailingIcon;

  /// Estado visual do card. Padrão: [ValidsCardStatus.base].
  final ValidsCardStatus status;

  /// Conteúdo opcional abaixo do cabeçalho (o legado usava um botão).
  final Widget? action;

  /// Callback de toque no card inteiro.
  final VoidCallback? onTap;

  const ValidsCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailingIcon,
    this.status = ValidsCardStatus.base,
    this.action,
    this.onTap,
  });

  /// Tamanho do avatar circular do ícone (40px no legado → `spacing-2xl`).
  static const double _avatarSize = ValidsSpacing.xl2;

  BoxDecoration get _decoration {
    switch (status) {
      case ValidsCardStatus.base:
        return BoxDecoration(
          color: ValidsColors.backgroundDefault,
          borderRadius: ValidsRadius.mdRadius,
          border: Border.all(
            color: ValidsColors.borderDefault,
            width: ValidsBorderWidth.sm,
          ),
        );
      case ValidsCardStatus.validation:
        return BoxDecoration(
          color: ValidsColors.backgroundSoft,
          borderRadius: ValidsRadius.mdRadius,
          border: Border.all(
            color: ValidsColors.borderMedium,
            width: ValidsBorderWidth.sm,
          ),
        );
      case ValidsCardStatus.unavailable:
        return const BoxDecoration(
          color: ValidsColors.dangerSoft,
          borderRadius: ValidsRadius.mdRadius,
        );
    }
  }

  Color get _trailingColor => status == ValidsCardStatus.unavailable
      ? ValidsColors.danger
      : ValidsColors.textSoft;

  Widget _buildAvatar() {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: ValidsColors.backgroundSoft,
        borderRadius: ValidsRadius.fullRadius,
        // No legado o avatar do card em validação ganhava uma borda extra.
        border: status == ValidsCardStatus.validation
            ? Border.all(
                color: ValidsColors.borderSoft,
                width: ValidsBorderWidth.sm,
              )
            : null,
      ),
      child: Icon(icon, size: ValidsSpacing.lg, color: ValidsColors.textSoft),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = <Widget>[
      Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: ValidsTypography.bodyHighlightMd.copyWith(
          color: ValidsColors.textDefault,
        ),
      ),
      // Legenda fixa do legado para cards em validação.
      if (status == ValidsCardStatus.validation)
        Text(
          'Aguardando validação',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ValidsTypography.captionSm.copyWith(
            color: ValidsColors.primary,
          ),
        ),
      if (subtitle != null)
        Text(
          subtitle!,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: ValidsTypography.bodySm.copyWith(
            color: ValidsColors.textSoft,
          ),
        ),
    ];

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          _buildAvatar(),
          const SizedBox(width: ValidsSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < texts.length; i++) ...[
                if (i > 0) const SizedBox(height: ValidsSpacing.xs2),
                texts[i],
              ],
            ],
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: ValidsSpacing.md),
          Icon(trailingIcon, size: ValidsSpacing.lg, color: _trailingColor),
        ],
      ],
    );

    final content = Padding(
      padding: const EdgeInsets.all(ValidsSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          if (action != null) ...[
            const SizedBox(height: ValidsSpacing.md),
            action!,
          ],
        ],
      ),
    );

    return Semantics(
      label: title,
      child: DecoratedBox(
        decoration: _decoration,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: ValidsRadius.mdRadius,
            child: content,
          ),
        ),
      ),
    );
  }
}

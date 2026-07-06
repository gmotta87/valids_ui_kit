import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Item de menu compacto com ícone, label e estado selecionado.
///
/// Reconstrução do `MenuItem` da lib whitelabel legada (storybook
/// "Widgets/MenuItem" — "Variações de MenuItem"), adequada aos tokens do
/// design system ValiDS. No legado o item era composto por uma chamada
/// opcional acima do label ("Chamada"), o label, uma descrição opcional,
/// um ícone leading e um widget trailing (ex.: chevron).
///
/// Diferente do `ValidsListItem`, o menu item é mais compacto e possui
/// estado [selected] (fundo `primary-softer` + textos `primary`) e hover.
///
/// ```dart
/// ValidsMenuItem(
///   label: 'Item 1',
///   callout: 'Chamada',
///   icon: Icons.wallet,
///   trailing: const Icon(Icons.navigate_next),
///   onTap: () {},
/// )
/// ```
class ValidsMenuItem extends StatelessWidget {
  /// Texto principal do item.
  final String label;

  /// Chamada/sobrelinha exibida acima do [label]
  /// (no legado: "Chamada").
  final String? callout;

  /// Descrição exibida abaixo do [label].
  final String? description;

  /// Ícone leading.
  final IconData? icon;

  /// Widget trailing (ex.: `Icon(Icons.navigate_next)`).
  final Widget? trailing;

  /// Marca o item como selecionado: fundo `primary-softer` e textos
  /// em `primary`.
  final bool selected;

  /// Desabilita a interação e aplica cores inativas.
  final bool disabled;

  /// Callback de toque.
  final VoidCallback? onTap;

  const ValidsMenuItem({
    super.key,
    required this.label,
    this.callout,
    this.description,
    this.icon,
    this.trailing,
    this.selected = false,
    this.disabled = false,
    this.onTap,
  });

  Color get _labelColor {
    if (disabled) return ValidsColors.textInactive;
    if (selected) return ValidsColors.primary;
    return ValidsColors.textDefault;
  }

  Color get _supportColor {
    if (disabled) return ValidsColors.textInactive;
    if (selected) return ValidsColors.primary;
    return ValidsColors.textSoft;
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ValidsSpacing.sm,
        vertical: ValidsSpacing.xs,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: ValidsSpacing.lg, color: _supportColor),
            const SizedBox(width: ValidsSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (callout != null)
                  Text(
                    callout!,
                    style: ValidsTypography.captionSm.copyWith(
                      color: _supportColor,
                    ),
                  ),
                Text(
                  label,
                  style: ValidsTypography.bodyHighlightSm.copyWith(
                    color: _labelColor,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: ValidsTypography.bodyXs.copyWith(
                      color: _supportColor,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: ValidsSpacing.sm),
            IconTheme.merge(
              data: IconThemeData(
                size: ValidsSpacing.lg,
                color: _supportColor,
              ),
              child: trailing!,
            ),
          ],
        ],
      ),
    );

    return Material(
      color: selected ? ValidsColors.primarySofter : Colors.transparent,
      borderRadius: ValidsRadius.mdRadius,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: ValidsRadius.mdRadius,
        hoverColor: selected
            ? ValidsColors.primarySoft.withValues(alpha: 0.4)
            : ValidsColors.backgroundSoft,
        child: content,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Destino de um [ValidsNavigationBar]: ícone + label.
///
/// Mirrors o modelo de item do `NavigationBar` legado
/// (ex.: Home / Profile / Settings).
class ValidsNavigationBarItem {
  final IconData icon;
  final String label;

  const ValidsNavigationBarItem({required this.icon, required this.label});
}

/// Barra de navegação inferior com itens de ícone + label.
///
/// Reconstrução do `Custom Navigation Bar` da lib whitelabel legada
/// (storybook "Widgets/NavigationBar"), adequada aos tokens do design
/// system ValiDS: item ativo em `primary`, inativos em `text-soft`, fundo
/// `background-default` com borda superior `border-default`.
///
/// ```dart
/// ValidsNavigationBar(
///   items: const [
///     ValidsNavigationBarItem(icon: Icons.home, label: 'Home'),
///     ValidsNavigationBarItem(icon: Icons.person, label: 'Profile'),
///     ValidsNavigationBarItem(icon: Icons.settings, label: 'Settings'),
///   ],
///   currentIndex: _index,
///   onDestinationSelected: (i) => setState(() => _index = i),
/// )
/// ```
class ValidsNavigationBar extends StatelessWidget {
  /// Destinos da barra (no legado: Home, Profile, Settings).
  final List<ValidsNavigationBarItem> items;

  /// Índice do destino atualmente selecionado.
  final int currentIndex;

  /// Chamado com o índice do destino tocado.
  final ValueChanged<int>? onDestinationSelected;

  const ValidsNavigationBar({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onDestinationSelected,
  });

  Widget _buildItem(BuildContext context, int index) {
    final item = items[index];
    final bool active = index == currentIndex;
    final Color color =
        active ? ValidsColors.primary : ValidsColors.textSoft;

    return Expanded(
      child: InkWell(
        onTap: onDestinationSelected == null
            ? null
            : () => onDestinationSelected!(index),
        child: Semantics(
          selected: active,
          button: true,
          label: item.label,
          child: Padding(
            // Padding vertical herdado do legado (8px).
            padding: const EdgeInsets.symmetric(vertical: ValidsSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: ValidsSpacing.lg, color: color),
                const SizedBox(height: ValidsSpacing.xs2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ValidsTypography.captionSm.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ValidsColors.backgroundDefault,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: ValidsColors.borderDefault,
              width: ValidsBorderWidth.sm,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++) _buildItem(context, i),
            ],
          ),
        ),
      ),
    );
  }
}

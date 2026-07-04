# Valids UI Kit

Uma biblioteca Flutter unificada que consolida os componentes do Design System Valids.

## Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  valids_ui_kit:
    git:
      url: https://github.com/gmotta87/valids_ui_kit.git
```

## Uso

### Configurando o Tema

```dart
import 'package:flutter/material.dart';
import 'package:valids_ui_kit/valids_ui_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ValidsTheme.lightTheme,
      home: const MyHomePage(),
    );
  }
}
```

## Componentes Mapeados e Consolidados

| Componente | Status | Descrição |
| :--- | :--- | :--- |
| **Tokens** | ✅ Implementado | Cores, Tipografia e Espaçamento. |
| **ValidsTheme** | ✅ Implementado | Tema global configurado. |
| **ValidsButton** | ✅ Implementado | Botões com variantes (Primary, Secondary, Outline, Ghost). |
| **ValidsIconButton** | ✅ Implementado | Botões de ícone com variantes. |
| **ValidsSwitch** | ✅ Implementado | Toggle switch customizado. |
| **ValidsCheckbox** | ✅ Implementado | Checkbox com suporte a label. |
| **ValidsRadioGroup** | ✅ Implementado | Grupo de opções radiais. |
| **ValidsChip** | ✅ Implementado | Chips para filtros e tags. |
| **ValidsAlert** | ✅ Implementado | Banners de feedback (Success, Error, Warning, Info). |
| **ValidsDialog** | ✅ Implementado | Modais de confirmação e alerta. |
| **ValidsListItem** | ✅ Implementado | Itens de lista padronizados. |
| **ValidsAppBar** | ✅ Implementado | Barra superior com branding. |
| **ValidsSeparator** | ✅ Implementado | Divisores horizontais e verticais. |
| **ValidsSkeleton** | ✅ Implementado | Efeito de shimmer para carregamento. |
| **ValidsSpinner** | ✅ Implementado | Indicador de progresso circular. |

## Exemplos de Uso

### ValidsButton
```dart
ValidsButton(
  label: 'Enviar',
  onPressed: () => print('Clicou!'),
  variant: ValidsButtonVariant.primary,
)
```

### ValidsAlert
```dart
ValidsAlert(
  title: 'Sucesso',
  message: 'Operação realizada com sucesso.',
  type: ValidsAlertType.success,
)
```

### ValidsDialog
```dart
ValidsDialog.show(
  context,
  title: 'Confirmar Ação',
  message: 'Deseja realmente excluir este item?',
  primaryButtonLabel: 'Excluir',
  onPrimaryPressed: () => print('Excluído'),
  secondaryButtonLabel: 'Cancelar',
);
```

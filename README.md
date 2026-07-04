# Valids UI Kit

Uma biblioteca Flutter unificada que consolida os componentes do Design System Valids.

## Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  valids_ui_kit:
    git:
      url: https://github.com/usuario/valids_ui_kit.git
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

### Componentes

#### ValidsButton

```dart
ValidsButton(
  label: 'Enviar',
  onPressed: () => print('Clicou!'),
  variant: ValidsButtonVariant.primary,
)
```

#### ValidsAlert

```dart
ValidsAlert(
  title: 'Sucesso',
  message: 'Operação realizada com sucesso.',
  type: ValidsAlertType.success,
)
```

## Componentes Mapeados e Consolidados

| Componente | Status |
| :--- | :--- |
| ValidsButton | ✅ Implementado |
| ValidsAlert | ✅ Implementado |
| ValidsSeparator | ✅ Implementado |
| ValidsTheme | ✅ Implementado |
| Tokens (Cores, Tipografia, Espaçamento) | ✅ Implementado |
| ValidsSwitch | ⏳ Pendente |
| ValidsCheckbox | ⏳ Pendente |
| ValidsSkeleton | ⏳ Pendente |

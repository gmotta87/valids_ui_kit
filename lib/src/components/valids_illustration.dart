import 'package:flutter/material.dart';

import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// Ilustrações nomeadas herdadas da lib whitelabel legada.
///
/// Mirrors the legacy `IllustrationType` enum, which mapped each name to um
/// arquivo em `assets/illustrations/` (ex.: `authenticator.png`,
/// `magnifeye.gif`). Os nomes de arquivo originais são preservados em
/// [assetFileName] para quando os assets forem migrados.
enum ValidsIllustrationType {
  authenticator('authenticator.png', Icons.verified_user),
  faceScan('face_scan.png', Icons.face_retouching_natural),
  smiles('smiles_scan.png', Icons.sentiment_satisfied_alt),
  magnifeye('magnifeye.gif', Icons.remove_red_eye),
  help('help.png', Icons.help_outline),
  security('security.png', Icons.security),
  start('start.png', Icons.flag),
  success('success.png', Icons.check_circle_outline),
  validation('validation.png', Icons.fact_check),
  warning('warning.png', Icons.warning_amber),
  biometry('biometry.png', Icons.fingerprint),
  camera('camera.png', Icons.photo_camera),
  sendingId('sending-id.png', Icons.badge),
  working('working.png', Icons.engineering),
  discovery('discovery.png', Icons.travel_explore),
  authSuccess('auth_success.png', Icons.verified);

  /// Nome do arquivo original em `assets/illustrations/` no app legado.
  final String assetFileName;

  /// Ícone Material usado no placeholder enquanto os assets originais não
  /// estão disponíveis neste pacote.
  final IconData placeholderIcon;

  const ValidsIllustrationType(this.assetFileName, this.placeholderIcon);
}

/// Ilustração nomeada do design system.
///
/// Reconstrução do `Illustration` da lib whitelabel legada (storybook
/// "Widgets/Illustration" — "Variações de Illustration"), adequada aos
/// tokens do design system ValiDS. O legado renderizava imagens de
/// `assets/illustrations/<arquivo>` em 176×224 (equivalente aos tokens
/// `spacing-8xl` × `spacing-9xl`).
///
/// Como os assets originais não acompanham este pacote, o componente
/// renderiza por padrão um placeholder elegante (container com
/// `background-softer`, raio `md` e um ícone Material correspondente ao
/// [type]). Quando os assets forem adicionados, informe [asset] (e
/// opcionalmente [assetPackage]) para renderizar a imagem real — o caminho
/// legado pode ser reconstruído com
/// `'assets/illustrations/${type.assetFileName}'`.
///
/// ```dart
/// const ValidsIllustration(type: ValidsIllustrationType.faceScan)
///
/// // Com o asset migrado:
/// const ValidsIllustration(
///   type: ValidsIllustrationType.faceScan,
///   asset: 'assets/illustrations/face_scan.png',
/// )
/// ```
class ValidsIllustration extends StatelessWidget {
  /// Qual ilustração exibir (nomes herdados do legado).
  final ValidsIllustrationType type;

  /// Dimensões da ilustração. Padrão: 176×224, como no legado
  /// (`spacing-8xl` × `spacing-9xl`).
  final Size size;

  /// Caminho do asset da ilustração real (quando disponível).
  final String? asset;

  /// Pacote de onde o [asset] deve ser carregado.
  final String? assetPackage;

  const ValidsIllustration({
    super.key,
    required this.type,
    this.size = const Size(ValidsSpacing.xl8, ValidsSpacing.xl9),
    this.asset,
    this.assetPackage,
  });

  @override
  Widget build(BuildContext context) {
    if (asset != null) {
      return Image.asset(
        asset!,
        package: assetPackage,
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
      );
    }

    return Semantics(
      label: 'Illustration: ${type.name}',
      image: true,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          color: ValidsColors.backgroundSofter,
          borderRadius: ValidsRadius.mdRadius,
        ),
        child: Center(
          child: Icon(
            type.placeholderIcon,
            size: ValidsSpacing.xl3,
            color: ValidsColors.textInactive,
          ),
        ),
      ),
    );
  }
}

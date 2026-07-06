import 'package:flutter/material.dart';

/// A single tone within a color scale (e.g. the `800` step of "Roxo").
class ValidsColorTone {
  final int shade;
  final Color color;

  const ValidsColorTone(this.shade, this.color);
}

/// A named color scale from the ValiDS design system (a family of tones).
class ValidsColorScale {
  final String name;
  final String token;
  final List<ValidsColorTone> tones;

  const ValidsColorScale({
    required this.name,
    required this.token,
    required this.tones,
  });
}

/// The full ValiDS color palette, transcribed from the design system tokens
/// (https://valids-componentes.services-valid.com.br).
///
/// Primitive families expose the `50/100/400/800/900` steps used by the brand
/// themes; semantic and neutral families expose their complete scales.
class ValidsPalette {
  ValidsPalette._();

  static const ValidsColorScale purple = ValidsColorScale(
    name: 'Roxo',
    token: 'purple',
    tones: [
      ValidsColorTone(50, Color(0xFFF5EBFF)),
      ValidsColorTone(100, Color(0xFFDDC2F7)),
      ValidsColorTone(400, Color(0xFF9947E6)),
      ValidsColorTone(800, Color(0xFF3B0E66)),
      ValidsColorTone(900, Color(0xFF23083D)),
    ],
  );

  static const ValidsColorScale blue = ValidsColorScale(
    name: 'Azul',
    token: 'blue',
    tones: [
      ValidsColorTone(50, Color(0xFFEBF7FF)),
      ValidsColorTone(100, Color(0xFFC2E1F7)),
      ValidsColorTone(400, Color(0xFF47A5E6)),
      ValidsColorTone(800, Color(0xFF0E4266)),
      ValidsColorTone(900, Color(0xFF08283D)),
    ],
  );

  static const ValidsColorScale green = ValidsColorScale(
    name: 'Verde',
    token: 'green',
    tones: [
      ValidsColorTone(50, Color(0xFFEBFFF5)),
      ValidsColorTone(100, Color(0xFFB9FFDC)),
      ValidsColorTone(400, Color(0xFF2EFF97)),
      ValidsColorTone(800, Color(0xFF006332)),
      ValidsColorTone(900, Color(0xFF053A20)),
    ],
  );

  static const ValidsColorScale red = ValidsColorScale(
    name: 'Vermelho',
    token: 'red',
    tones: [
      ValidsColorTone(50, Color(0xFFFFEBEC)),
      ValidsColorTone(100, Color(0xFFF8C1C3)),
      ValidsColorTone(400, Color(0xFFE9454B)),
      ValidsColorTone(800, Color(0xFF670C10)),
      ValidsColorTone(900, Color(0xFF3E0709)),
    ],
  );

  static const ValidsColorScale orange = ValidsColorScale(
    name: 'Laranja',
    token: 'orange',
    tones: [
      ValidsColorTone(50, Color(0xFFFFF6EB)),
      ValidsColorTone(100, Color(0xFFFCDFBC)),
      ValidsColorTone(400, Color(0xFFF69F37)),
      ValidsColorTone(800, Color(0xFF6F3E05)),
      ValidsColorTone(900, Color(0xFF432503)),
    ],
  );

  static const ValidsColorScale yellow = ValidsColorScale(
    name: 'Amarelo',
    token: 'yellow',
    tones: [
      ValidsColorTone(50, Color(0xFFFFFCEB)),
      ValidsColorTone(100, Color(0xFFFFF08B)),
      ValidsColorTone(400, Color(0xFFFFDF00)),
      ValidsColorTone(800, Color(0xFF746500)),
      ValidsColorTone(900, Color(0xFF463D00)),
    ],
  );

  static const ValidsColorScale pink = ValidsColorScale(
    name: 'Rosa',
    token: 'pink',
    tones: [
      ValidsColorTone(50, Color(0xFFFFEBF2)),
      ValidsColorTone(100, Color(0xFFF7C1D4)),
      ValidsColorTone(400, Color(0xFFE7467F)),
      ValidsColorTone(800, Color(0xFF670D2D)),
      ValidsColorTone(900, Color(0xFF3E081B)),
    ],
  );

  static const ValidsColorScale brown = ValidsColorScale(
    name: 'Marrom',
    token: 'brown',
    tones: [
      ValidsColorTone(50, Color(0xFFFFF3EB)),
      ValidsColorTone(100, Color(0xFFECD9CC)),
      ValidsColorTone(400, Color(0xFFC68C67)),
      ValidsColorTone(800, Color(0xFF533420)),
      ValidsColorTone(900, Color(0xFF281509)),
    ],
  );

  static const ValidsColorScale golden = ValidsColorScale(
    name: 'Dourado',
    token: 'golden',
    tones: [
      ValidsColorTone(50, Color(0xFFFFFAE4)),
      ValidsColorTone(100, Color(0xFFFCE77F)),
      ValidsColorTone(400, Color(0xFFBEA55A)),
      ValidsColorTone(800, Color(0xFF604F2E)),
      ValidsColorTone(900, Color(0xFF483817)),
    ],
  );

  static const ValidsColorScale gray = ValidsColorScale(
    name: 'Cinza',
    token: 'gray',
    tones: [
      ValidsColorTone(50, Color(0xFFF9F9F9)),
      ValidsColorTone(100, Color(0xFFF0F0F0)),
      ValidsColorTone(400, Color(0xFFE3E3E3)),
      ValidsColorTone(800, Color(0xFF222222)),
      ValidsColorTone(900, Color(0xFF151515)),
    ],
  );

  static const ValidsColorScale info = ValidsColorScale(
    name: 'Informação',
    token: 'info',
    tones: [
      ValidsColorTone(50, Color(0xFFE8F3FF)),
      ValidsColorTone(100, Color(0xFFB9DAFF)),
      ValidsColorTone(200, Color(0xFF8BC2FF)),
      ValidsColorTone(300, Color(0xFF5DA9FF)),
      ValidsColorTone(400, Color(0xFF2E91FF)),
      ValidsColorTone(500, Color(0xFF0078FF)),
      ValidsColorTone(600, Color(0xFF0062D1)),
      ValidsColorTone(700, Color(0xFF004CA2)),
      ValidsColorTone(800, Color(0xFF003774)),
      ValidsColorTone(900, Color(0xFF002146)),
    ],
  );

  static const ValidsColorScale success = ValidsColorScale(
    name: 'Sucesso',
    token: 'success',
    tones: [
      ValidsColorTone(50, Color(0xFFEFF9ED)),
      ValidsColorTone(100, Color(0xFFCEEECA)),
      ValidsColorTone(200, Color(0xFFAEE3A7)),
      ValidsColorTone(300, Color(0xFF8DD784)),
      ValidsColorTone(400, Color(0xFF6DCC61)),
      ValidsColorTone(500, Color(0xFF4CC13E)),
      ValidsColorTone(600, Color(0xFF3E9E33)),
      ValidsColorTone(700, Color(0xFF307B28)),
      ValidsColorTone(800, Color(0xFF23581C)),
      ValidsColorTone(900, Color(0xFF153511)),
    ],
  );

  static const ValidsColorScale warning = ValidsColorScale(
    name: 'Atenção',
    token: 'warning',
    tones: [
      ValidsColorTone(50, Color(0xFFFEF9E9)),
      ValidsColorTone(100, Color(0xFFFCEEBC)),
      ValidsColorTone(200, Color(0xFFFAE390)),
      ValidsColorTone(300, Color(0xFFF8D764)),
      ValidsColorTone(400, Color(0xFFF6CC37)),
      ValidsColorTone(500, Color(0xFFF4C10B)),
      ValidsColorTone(600, Color(0xFFBE9913)),
      ValidsColorTone(700, Color(0xFF9B7B07)),
      ValidsColorTone(800, Color(0xFF6F5805)),
      ValidsColorTone(900, Color(0xFF433503)),
    ],
  );

  static const ValidsColorScale error = ValidsColorScale(
    name: 'Erro',
    token: 'error',
    tones: [
      ValidsColorTone(50, Color(0xFFFCECEB)),
      ValidsColorTone(100, Color(0xFFF7C7C2)),
      ValidsColorTone(200, Color(0xFFF1A199)),
      ValidsColorTone(300, Color(0xFFEB7C71)),
      ValidsColorTone(400, Color(0xFFE65648)),
      ValidsColorTone(500, Color(0xFFE0311F)),
      ValidsColorTone(600, Color(0xFFB72819)),
      ValidsColorTone(700, Color(0xFF8E1F14)),
      ValidsColorTone(800, Color(0xFF66160E)),
      ValidsColorTone(900, Color(0xFF3D0D08)),
    ],
  );

  static const ValidsColorScale neutral = ValidsColorScale(
    name: 'Neutras',
    token: 'neutral',
    tones: [
      ValidsColorTone(50, Color(0xFFFEFEFE)),
      ValidsColorTone(75, Color(0xFFF8F8F8)),
      ValidsColorTone(100, Color(0xFFEDEDED)),
      ValidsColorTone(200, Color(0xFFE0E0E0)),
      ValidsColorTone(300, Color(0xFFCDCDCD)),
      ValidsColorTone(400, Color(0xFFA8A8A8)),
      ValidsColorTone(500, Color(0xFF878787)),
      ValidsColorTone(600, Color(0xFF606060)),
      ValidsColorTone(700, Color(0xFF4D4D4D)),
      ValidsColorTone(800, Color(0xFF2F2F2F)),
      ValidsColorTone(900, Color(0xFF0F0F0F)),
    ],
  );

  /// Primitive brand-capable families.
  static const List<ValidsColorScale> primitives = [
    purple,
    blue,
    green,
    red,
    orange,
    yellow,
    pink,
    brown,
    golden,
    gray,
  ];

  /// Semantic feedback families.
  static const List<ValidsColorScale> semantics = [
    info,
    success,
    warning,
    error,
  ];
}

import 'package:flutter/material.dart';

/// A selectable brand color for the ValiDS design system.
///
/// Each brand maps the design system's `50/100/400/800/900` tones of a color
/// family onto the semantic brand roles consumed across the kit. Switching the
/// active brand recolors every component that reads from `ValidsColors`.
class ValidsBrand {
  final String id;
  final String label;
  final Color primary; // 800 — default brand surface/action
  final Color primaryDark; // 900
  final Color primaryLight; // 400
  final Color primarySoft; // 100
  final Color primarySofter; // 50

  const ValidsBrand({
    required this.id,
    required this.label,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primarySoft,
    required this.primarySofter,
  });

  static const ValidsBrand roxo = ValidsBrand(
    id: 'roxo',
    label: 'Roxo',
    primary: Color(0xFF3B0E66),
    primaryDark: Color(0xFF23083D),
    primaryLight: Color(0xFF9947E6),
    primarySoft: Color(0xFFDDC2F7),
    primarySofter: Color(0xFFF5EBFF),
  );

  static const ValidsBrand azul = ValidsBrand(
    id: 'azul',
    label: 'Azul',
    primary: Color(0xFF0E4266),
    primaryDark: Color(0xFF08283D),
    primaryLight: Color(0xFF47A5E6),
    primarySoft: Color(0xFFC2E1F7),
    primarySofter: Color(0xFFEBF7FF),
  );

  static const ValidsBrand verde = ValidsBrand(
    id: 'verde',
    label: 'Verde',
    primary: Color(0xFF006332),
    primaryDark: Color(0xFF053A20),
    primaryLight: Color(0xFF2EFF97),
    primarySoft: Color(0xFFB9FFDC),
    primarySofter: Color(0xFFEBFFF5),
  );

  static const ValidsBrand vermelho = ValidsBrand(
    id: 'vermelho',
    label: 'Vermelho',
    primary: Color(0xFF670C10),
    primaryDark: Color(0xFF3E0709),
    primaryLight: Color(0xFFE9454B),
    primarySoft: Color(0xFFF8C1C3),
    primarySofter: Color(0xFFFFEBEC),
  );

  static const ValidsBrand laranja = ValidsBrand(
    id: 'laranja',
    label: 'Laranja',
    primary: Color(0xFF6F3E05),
    primaryDark: Color(0xFF432503),
    primaryLight: Color(0xFFF69F37),
    primarySoft: Color(0xFFFCDFBC),
    primarySofter: Color(0xFFFFF6EB),
  );

  static const ValidsBrand rosa = ValidsBrand(
    id: 'rosa',
    label: 'Rosa',
    primary: Color(0xFF670D2D),
    primaryDark: Color(0xFF3E081B),
    primaryLight: Color(0xFFE7467F),
    primarySoft: Color(0xFFF7C1D4),
    primarySofter: Color(0xFFFFEBF2),
  );

  static const ValidsBrand marrom = ValidsBrand(
    id: 'marrom',
    label: 'Marrom',
    primary: Color(0xFF533420),
    primaryDark: Color(0xFF281509),
    primaryLight: Color(0xFFC68C67),
    primarySoft: Color(0xFFECD9CC),
    primarySofter: Color(0xFFFFF3EB),
  );

  static const ValidsBrand dourado = ValidsBrand(
    id: 'dourado',
    label: 'Dourado',
    primary: Color(0xFF604F2E),
    primaryDark: Color(0xFF483817),
    primaryLight: Color(0xFFBEA55A),
    primarySoft: Color(0xFFFCE77F),
    primarySofter: Color(0xFFFFFAE4),
  );

  static const ValidsBrand cinza = ValidsBrand(
    id: 'cinza',
    label: 'Cinza',
    primary: Color(0xFF222222),
    primaryDark: Color(0xFF151515),
    primaryLight: Color(0xFFA8A8A8),
    primarySoft: Color(0xFFF0F0F0),
    primarySofter: Color(0xFFF9F9F9),
  );

  /// All selectable brands, in display order. `roxo` is the ValiDS default.
  static const List<ValidsBrand> values = [
    roxo,
    azul,
    verde,
    vermelho,
    laranja,
    rosa,
    marrom,
    dourado,
    cinza,
  ];
}

/// Global holder for the active [ValidsBrand].
///
/// `ValidsColors` reads its brand tones from here, so assigning
/// [ValidsBrandController.current] recolors the whole kit. Listen to
/// [notifier] to rebuild the app when the brand changes.
class ValidsBrandController {
  ValidsBrandController._();

  static final ValueNotifier<ValidsBrand> notifier =
      ValueNotifier<ValidsBrand>(ValidsBrand.roxo);

  static ValidsBrand get current => notifier.value;

  static set current(ValidsBrand brand) => notifier.value = brand;
}

import 'package:flutter/widgets.dart';

/// Border radius tokens from the ValiDS design system
/// (https://valids-componentes.services-valid.com.br → Tema/Bordas).
class ValidsRadius {
  ValidsRadius._();

  /// `radius-none` (0px)
  static const double none = 0;

  /// `radius-sm` → 0.25rem (4px)
  static const double sm = 4;

  /// `radius-md` → 0.5rem (8px)
  static const double md = 8;

  /// `radius-lg` → 1rem (16px)
  static const double lg = 16;

  /// `radius-xl` → 1.5rem (24px)
  static const double xl = 24;

  /// `radius-2xl` → 2rem (32px)
  static const double xl2 = 32;

  /// `radius-full` → 999rem (fully rounded)
  static const double full = 9999;

  // Convenience [BorderRadius] values for the common cases.
  static const BorderRadius noneRadius = BorderRadius.zero;
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xl2Radius = BorderRadius.all(Radius.circular(xl2));
  static const BorderRadius fullRadius =
      BorderRadius.all(Radius.circular(full));
}

/// Border width tokens from the ValiDS design system
/// (https://valids-componentes.services-valid.com.br → Tema/Bordas).
class ValidsBorderWidth {
  ValidsBorderWidth._();

  /// `border-width-off` (0px)
  static const double off = 0;

  /// `border-width-sm` → 0.0625rem (1px)
  static const double sm = 1;

  /// `border-width-md` → 0.125rem (2px)
  static const double md = 2;

  /// `border-width-lg` → 0.25rem (4px)
  static const double lg = 4;

  /// `border-width-xl` → 0.5rem (8px)
  static const double xl = 8;
}

/// Spacing tokens from the ValiDS design system
/// (https://valids-componentes.services-valid.com.br → Tema/Espaçamentos).
///
/// The design system uses a 2-layer architecture: Tailwind primitives
/// (`--spacing: 0.25rem`, so `spacing.4` = 16px) and semantic aliases.
/// This class exposes the semantic layer; names ending in a digit mirror the
/// DS multi-x tokens (`xs2` = `2xs`, `xl3` = `3xl`, ...).
class ValidsSpacing {
  ValidsSpacing._();

  /// `none` → spacing.0 (0px)
  static const double none = 0;

  /// `4xs` → spacing.px (1px)
  static const double xs4 = 1;

  /// `3xs` → spacing.0_5 (2px)
  static const double xs3 = 2;

  /// `2xs` → spacing.1 (4px)
  static const double xs2 = 4;

  /// `xs` → spacing.2 (8px)
  static const double xs = 8;

  /// `sm` → spacing.3 (12px)
  static const double sm = 12;

  /// `md` → spacing.4 (16px)
  static const double md = 16;

  /// `lg` → spacing.6 (24px)
  static const double lg = 24;

  /// `xl` → spacing.8 (32px)
  static const double xl = 32;

  /// `2xl` → spacing.10 (40px)
  static const double xl2 = 40;

  /// `3xl` → spacing.12 (48px)
  static const double xl3 = 48;

  /// `4xl` → spacing.14 (56px)
  static const double xl4 = 56;

  /// `5xl` → spacing.16 (64px)
  static const double xl5 = 64;

  /// `6xl` → spacing.20 (80px)
  static const double xl6 = 80;

  /// `7xl` → spacing.32 (128px)
  static const double xl7 = 128;

  /// `8xl` → spacing.44 (176px)
  static const double xl8 = 176;

  /// `9xl` → spacing.56 (224px)
  static const double xl9 = 224;

  /// `10xl` → spacing.60 (240px)
  static const double xl10 = 240;
}

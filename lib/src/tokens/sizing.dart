/// Sizing (dimension) tokens from the ValiDS design system
/// (https://valids-componentes.services-valid.com.br → Tema/Dimensões).
///
/// These mirror the DS `--container-*` semantic tokens, used for
/// width / min-width / max-width constraints. Names ending in a digit mirror
/// the DS multi-x tokens (`xs3` = `3xs`, `xl7` = `7xl`).
class ValidsSizing {
  ValidsSizing._();

  /// `3xs` → 16rem (256px)
  static const double xs3 = 256;

  /// `2xs` → 18rem (288px)
  static const double xs2 = 288;

  /// `xs` → 20rem (320px)
  static const double xs = 320;

  /// `sm` → 24rem (384px)
  static const double sm = 384;

  /// `md` → 28rem (448px)
  static const double md = 448;

  /// `lg` → 32rem (512px)
  static const double lg = 512;

  /// `xl` → 36rem (576px)
  static const double xl = 576;

  /// `2xl` → 42rem (672px)
  static const double xl2 = 672;

  /// `3xl` → 48rem (768px)
  static const double xl3 = 768;

  /// `4xl` → 56rem (896px)
  static const double xl4 = 896;

  /// `5xl` → 64rem (1024px)
  static const double xl5 = 1024;

  /// `6xl` → 72rem (1152px)
  static const double xl6 = 1152;

  /// `7xl` → 80rem (1280px)
  static const double xl7 = 1280;
}

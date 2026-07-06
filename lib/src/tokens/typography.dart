import 'package:flutter/material.dart';
import 'colors.dart';

/// Typography tokens from the ValiDS design system
/// (https://valids-componentes.services-valid.com.br → Tema/Tipografia).
///
/// Two-layer architecture, mirroring the DS:
/// - primitives: font sizes (`--text-*`), weights (`--font-weight-*`) and
///   line heights (`--leading-*`);
/// - semantic text styles (`ts-*`): compositions named by the role of the
///   text (heading, body, caption, button...). Always prefer these.
///
/// Semantic styles carry no color so they inherit from the surrounding
/// [DefaultTextStyle]; combine with the `ValidsColors.text*` tokens.
class ValidsTypography {
  ValidsTypography._();

  /// Open Sans shipped with this package (`--font-base` in the DS).
  static const String fontFamily = 'packages/valids_ui_kit/OpenSans';

  // --- Primitives: font size (--text-*) -----------------------------------

  /// `text-xs` → 0.75rem (12px)
  static const double textXs = 12;

  /// `text-sm` → 0.875rem (14px)
  static const double textSm = 14;

  /// `text-base` → 1rem (16px)
  static const double textBase = 16;

  /// `text-lg` → 1.125rem (18px)
  static const double textLg = 18;

  /// `text-xl` → 1.25rem (20px)
  static const double textXl = 20;

  /// `text-2xl` → 1.5rem (24px)
  static const double textXl2 = 24;

  /// `text-3xl` → 2.5rem (40px)
  static const double textXl3 = 40;

  // --- Primitives: font weight (--font-weight-*) --------------------------

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extrabold = FontWeight.w800;

  // --- Primitives: line height (--leading-*), in logical pixels -----------

  /// `leading-md` → 1rem (16px)
  static const double leadingMd = 16;

  /// `leading-lg` → 1.5rem (24px)
  static const double leadingLg = 24;

  /// `leading-xl` → 2rem (32px)
  static const double leadingXl = 32;

  /// `leading-2xl` → 2.5rem (40px)
  static const double leadingXl2 = 40;

  /// `leading-3xl` → 3rem (48px)
  static const double leadingXl3 = 48;

  // --- Semantic text styles (ts-*) -----------------------------------------

  /// `ts-heading-xl` — 40px / 48px, bold.
  static const TextStyle headingXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: textXl3,
    height: leadingXl3 / textXl3,
    fontWeight: bold,
  );

  /// `ts-heading-lg` — 24px / 32px, bold.
  static const TextStyle headingLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: textXl2,
    height: leadingXl / textXl2,
    fontWeight: bold,
  );

  /// `ts-heading-md` — 18px / 24px, bold.
  static const TextStyle headingMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: textLg,
    height: leadingLg / textLg,
    fontWeight: bold,
  );

  /// `ts-heading-sm` — 16px / 24px, bold.
  static const TextStyle headingSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: textBase,
    height: leadingLg / textBase,
    fontWeight: bold,
  );

  /// `ts-body-lg` — 18px / 32px, regular.
  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: textLg,
    height: leadingXl / textLg,
    fontWeight: regular,
  );

  /// `ts-body-md` — 16px / 32px, regular.
  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: textBase,
    height: leadingXl / textBase,
    fontWeight: regular,
  );

  /// `ts-body-sm` — 14px / 24px, regular.
  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: textSm,
    height: leadingLg / textSm,
    fontWeight: regular,
  );

  /// `ts-body-xs` — 12px / 16px, regular.
  static const TextStyle bodyXs = TextStyle(
    fontFamily: fontFamily,
    fontSize: textXs,
    height: leadingMd / textXs,
    fontWeight: regular,
  );

  /// `ts-body-highlight-lg` — 18px / 32px, bold.
  static const TextStyle bodyHighlightLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: textLg,
    height: leadingXl / textLg,
    fontWeight: bold,
  );

  /// `ts-body-highlight-md` — 16px / 32px, bold.
  static const TextStyle bodyHighlightMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: textBase,
    height: leadingXl / textBase,
    fontWeight: bold,
  );

  /// `ts-body-highlight-sm` — 14px / 24px, bold.
  static const TextStyle bodyHighlightSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: textSm,
    height: leadingLg / textSm,
    fontWeight: bold,
  );

  /// `ts-body-highlight-xs` — 12px / 16px, bold.
  static const TextStyle bodyHighlightXs = TextStyle(
    fontFamily: fontFamily,
    fontSize: textXs,
    height: leadingMd / textXs,
    fontWeight: bold,
  );

  /// `ts-body-link-lg` — 18px / 32px, regular, underlined.
  static const TextStyle bodyLinkLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: textLg,
    height: leadingXl / textLg,
    fontWeight: regular,
    decoration: TextDecoration.underline,
  );

  /// `ts-body-link-md` — 16px / 32px, regular, underlined.
  static const TextStyle bodyLinkMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: textBase,
    height: leadingXl / textBase,
    fontWeight: regular,
    decoration: TextDecoration.underline,
  );

  /// `ts-body-link-sm` — 14px / 24px, regular, underlined.
  static const TextStyle bodyLinkSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: textSm,
    height: leadingLg / textSm,
    fontWeight: regular,
    decoration: TextDecoration.underline,
  );

  /// `ts-body-link-xs` — 12px / 16px, regular, underlined.
  static const TextStyle bodyLinkXs = TextStyle(
    fontFamily: fontFamily,
    fontSize: textXs,
    height: leadingMd / textXs,
    fontWeight: regular,
    decoration: TextDecoration.underline,
  );

  /// `ts-body-link-highlight-lg` — 18px / 32px, bold, underlined.
  static const TextStyle bodyLinkHighlightLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: textLg,
    height: leadingXl / textLg,
    fontWeight: bold,
    decoration: TextDecoration.underline,
  );

  /// `ts-body-link-highlight-md` — 16px / 32px, bold, underlined.
  static const TextStyle bodyLinkHighlightMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: textBase,
    height: leadingXl / textBase,
    fontWeight: bold,
    decoration: TextDecoration.underline,
  );

  /// `ts-body-link-highlight-sm` — 14px / 24px, bold, underlined.
  static const TextStyle bodyLinkHighlightSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: textSm,
    height: leadingLg / textSm,
    fontWeight: bold,
    decoration: TextDecoration.underline,
  );

  /// `ts-body-link-highlight-xs` — 12px / 16px, bold, underlined.
  static const TextStyle bodyLinkHighlightXs = TextStyle(
    fontFamily: fontFamily,
    fontSize: textXs,
    height: leadingMd / textXs,
    fontWeight: bold,
    decoration: TextDecoration.underline,
  );

  /// `ts-caption-lg` — 16px / 24px, semibold.
  static const TextStyle captionLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: textBase,
    height: leadingLg / textBase,
    fontWeight: semibold,
  );

  /// `ts-caption-md` — 14px / 24px, semibold.
  static const TextStyle captionMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: textSm,
    height: leadingLg / textSm,
    fontWeight: semibold,
  );

  /// `ts-caption-sm` — 12px / 16px, semibold.
  static const TextStyle captionSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: textXs,
    height: leadingMd / textXs,
    fontWeight: semibold,
  );

  /// `ts-button-md` — 16px / 24px, bold.
  static const TextStyle buttonMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: textBase,
    height: leadingLg / textBase,
    fontWeight: bold,
  );

  // --- Legacy aliases (pre-DS naming) --------------------------------------
  // Kept with their original metrics so existing consumers don't shift
  // layout; migrate to the semantic `ts-*` styles above.

  @Deprecated('Use headingXl (ts-heading-xl) instead')
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: bold,
    color: ValidsColors.black,
  );

  @Deprecated('Use headingLg (ts-heading-lg) instead')
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: bold,
    color: ValidsColors.black,
  );

  @Deprecated('Use headingMd (ts-heading-md) instead')
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: bold,
    color: ValidsColors.black,
  );

  @Deprecated('Use bodyMd (ts-body-md) instead')
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    color: ValidsColors.black,
  );

  @Deprecated('Use captionSm (ts-caption-sm) or bodyXs (ts-body-xs) instead')
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    color: ValidsColors.grey600,
  );

  @Deprecated('Use buttonMd (ts-button-md) instead')
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semibold,
    color: ValidsColors.white,
  );
}

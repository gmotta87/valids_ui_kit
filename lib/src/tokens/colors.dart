import 'package:flutter/material.dart';
import '../theme/valids_brand.dart';

/// Color tokens extracted from the ValiDS design system
/// (https://valids-componentes.services-valid.com.br).
///
/// The brand tones (`primary*`) are driven by the globally selected
/// [ValidsBrandController.current], so changing the active brand recolors every
/// component that reads them. Semantic and neutral tones are fixed.
class ValidsColors {
  ValidsColors._();

  // Brand Colors — resolved from the active brand (default: purple family).
  static Color get primary => ValidsBrandController.current.primary;
  static Color get primaryLight => ValidsBrandController.current.primaryLight;
  static Color get primaryDark => ValidsBrandController.current.primaryDark;
  static Color get primarySoft => ValidsBrandController.current.primarySoft;
  static Color get primarySofter => ValidsBrandController.current.primarySofter;

  // Semantic (feedback) Colors.
  // DS mapping: `*-default` background = 50, `*-soft` background = 500,
  // `*-bold` background / text / border = 800.
  static const Color success = Color(0xFF4CC13E); // success-500
  static const Color successDark = Color(0xFF23581C); // success-800
  static const Color successSoft = Color(0xFFEFF9ED); // success-50
  static const Color warning = Color(0xFFF4C10B); // warning-500
  static const Color warningDark = Color(0xFF6F5805); // warning-800
  static const Color warningSoft = Color(0xFFFEF9E9); // warning-50
  static const Color danger = Color(0xFFE0311F); // error-500
  static const Color dangerDark = Color(0xFF66160E); // error-800
  static const Color dangerBolder = Color(0xFF3D0D08); // error-900 (`button-destructive-bold`)
  static const Color dangerSoft = Color(0xFFFCECEB); // error-50
  static const Color info = Color(0xFF0078FF); // info-500
  static const Color infoDark = Color(0xFF003774); // info-800
  static const Color infoSoft = Color(0xFFE8F3FF); // info-50

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF2F2F2F); // neutral-800
  static const Color grey50 = Color(0xFFFEFEFE); // neutral-50
  static const Color grey75 = Color(0xFFF8F8F8); // neutral-75
  static const Color grey100 = Color(0xFFEDEDED); // neutral-100
  static const Color grey200 = Color(0xFFE0E0E0); // neutral-200
  static const Color grey300 = Color(0xFFCDCDCD); // neutral-300
  static const Color grey400 = Color(0xFFA8A8A8); // neutral-400
  static const Color grey500 = Color(0xFF878787); // neutral-500
  static const Color grey600 = Color(0xFF606060); // neutral-600
  static const Color grey700 = Color(0xFF4D4D4D); // neutral-700
  static const Color grey900 = Color(0xFF0F0F0F); // neutral-900

  // Text colors (`--text-color-*`)
  static const Color textDefault = grey900;
  static const Color textSoft = grey700;
  static const Color textInactive = grey400;
  static const Color textInvert = grey50;

  // Background colors (`--background-color-*`)
  static const Color backgroundDefault = grey50;
  static const Color backgroundSofter = grey75;
  static const Color backgroundSoft = grey100;
  static const Color backgroundMedium = grey400;
  static const Color backgroundBold = grey700;
  static const Color backgroundInactive = grey400;

  // Border colors (`--border-color-*`)
  static const Color borderDefault = grey200;
  static const Color borderSoft = grey300;
  static const Color borderMedium = grey400;
  static const Color borderBold = grey700;
  static const Color borderInactive = grey400;

  /// DS focus ring color (`.focus-ring` → info-400), 2px wide with 2px offset.
  static const Color focusRing = Color(0xFF2E91FF);

  // Legacy backgrounds (pre-DS naming)
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = grey50;
}

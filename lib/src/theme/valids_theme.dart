import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class ValidsTheme {
  ValidsTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: ValidsTypography.fontFamily,
      primaryColor: ValidsColors.primary,
      scaffoldBackgroundColor: ValidsColors.backgroundDefault,
      colorScheme: ColorScheme.light(
        primary: ValidsColors.primary,
        secondary: ValidsColors.primaryLight,
        surface: ValidsColors.surface,
        error: ValidsColors.danger,
        onPrimary: ValidsColors.textInvert,
        onSecondary: ValidsColors.textInvert,
        onSurface: ValidsColors.textDefault,
        onError: ValidsColors.textInvert,
      ),
      textTheme: const TextTheme(
        displayLarge: ValidsTypography.headingXl,
        displayMedium: ValidsTypography.headingLg,
        displaySmall: ValidsTypography.headingMd,
        headlineLarge: ValidsTypography.headingXl,
        headlineMedium: ValidsTypography.headingLg,
        headlineSmall: ValidsTypography.headingMd,
        titleLarge: ValidsTypography.headingMd,
        titleMedium: ValidsTypography.headingSm,
        titleSmall: ValidsTypography.captionMd,
        bodyLarge: ValidsTypography.bodyLg,
        bodyMedium: ValidsTypography.bodyMd,
        bodySmall: ValidsTypography.bodySm,
        labelLarge: ValidsTypography.buttonMd,
        labelMedium: ValidsTypography.captionMd,
        labelSmall: ValidsTypography.captionSm,
      ).apply(
        bodyColor: ValidsColors.textDefault,
        displayColor: ValidsColors.textDefault,
      ),
      dividerColor: ValidsColors.borderDefault,
    );
  }
}

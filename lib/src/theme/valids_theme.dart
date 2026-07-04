import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class ValidsTheme {
  ValidsTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: ValidsColors.primary,
      scaffoldBackgroundColor: ValidsColors.background,
      colorScheme: ColorScheme.light(
        primary: ValidsColors.primary,
        secondary: ValidsColors.primaryLight,
        surface: ValidsColors.surface,
        error: ValidsColors.danger,
        onPrimary: ValidsColors.white,
        onSecondary: ValidsColors.white,
        onSurface: ValidsColors.black,
        onError: ValidsColors.white,
      ),
      textTheme: TextTheme(
        displayLarge: ValidsTypography.h1,
        displayMedium: ValidsTypography.h2,
        displaySmall: ValidsTypography.h3,
        bodyLarge: ValidsTypography.body,
        labelLarge: ValidsTypography.button,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ValidsColors.primary,
          foregroundColor: ValidsColors.white,
          textStyle: ValidsTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

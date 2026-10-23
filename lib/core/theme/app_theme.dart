import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';

/// Tema global de Rómpelo construido a mano desde los tokens de `DESIGN.md`.
///
/// No usamos `ColorScheme.fromSeed` porque generaría una paleta distinta a la
/// del mockup; aquí cada rol de Material 3 apunta al token exacto.
abstract final class AppTheme {
  static const String fontFamily = 'Outfit';

  static final ColorScheme colorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    primaryFixed: AppColors.primaryFixed,
    primaryFixedDim: AppColors.primaryFixedDim,
    onPrimaryFixed: AppColors.onPrimaryFixed,
    onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
    inversePrimary: AppColors.inversePrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    secondaryFixed: AppColors.secondaryFixed,
    secondaryFixedDim: AppColors.secondaryFixedDim,
    onSecondaryFixed: AppColors.onSecondaryFixed,
    onSecondaryFixedVariant: AppColors.onSecondaryFixedVariant,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    tertiaryFixed: AppColors.tertiaryFixed,
    onTertiaryFixedVariant: AppColors.onTertiaryFixedVariant,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    surfaceDim: AppColors.surfaceDim,
    surfaceBright: AppColors.surface,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    surfaceTint: AppColors.primary,
    shadow: AppColors.ink,
    scrim: AppColors.ink,
  );

  /// Crea un estilo Outfit. Como la fuente es **variable**, el peso se aplica
  /// también como eje `wght`; si solo pusiéramos `fontWeight`, el motor de
  /// texto podría dibujar siempre el peso por defecto del archivo.
  static TextStyle outfit({
    required double size,
    required FontWeight weight,
    required double lineHeight,
    double letterSpacingEm = 0,
    Color color = AppColors.onSurface,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
      height: lineHeight / size,
      letterSpacing: letterSpacingEm * size,
      color: color,
    );
  }

  /// Cambia el peso de un estilo manteniendo sincronizado el eje variable.
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(
      fontWeight: weight,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
    );
  }

  /// Cifras tabulares (mismo ancho por dígito) para marcadores y timers:
  /// evita que el número "baile" mientras cuenta.
  static TextStyle tabular(TextStyle style) {
    return style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Escala tipográfica de DESIGN.md mapeada a los roles de Material 3.
  static final TextTheme textTheme = TextTheme(
    // headline-xl / headline-xl-mobile
    displayLarge: outfit(
        size: 40,
        weight: FontWeight.w800,
        lineHeight: 46,
        letterSpacingEm: -0.03),
    displayMedium: outfit(
        size: 32,
        weight: FontWeight.w800,
        lineHeight: 38,
        letterSpacingEm: -0.025),
    displaySmall: outfit(
        size: 28,
        weight: FontWeight.w800,
        lineHeight: 34,
        letterSpacingEm: -0.02),
    // headline-lg / md / sm
    headlineLarge: outfit(
        size: 28,
        weight: FontWeight.w700,
        lineHeight: 34,
        letterSpacingEm: -0.02),
    headlineMedium: outfit(
        size: 22,
        weight: FontWeight.w700,
        lineHeight: 28,
        letterSpacingEm: -0.015),
    headlineSmall: outfit(
        size: 19,
        weight: FontWeight.w700,
        lineHeight: 25,
        letterSpacingEm: -0.01),
    titleLarge: outfit(
        size: 19,
        weight: FontWeight.w700,
        lineHeight: 25,
        letterSpacingEm: -0.01),
    titleMedium: outfit(size: 16, weight: FontWeight.w700, lineHeight: 22),
    titleSmall: outfit(size: 14, weight: FontWeight.w600, lineHeight: 18),
    // body-lg / md / sm
    bodyLarge: outfit(size: 18, weight: FontWeight.w500, lineHeight: 26),
    bodyMedium: outfit(size: 16, weight: FontWeight.w400, lineHeight: 24),
    bodySmall: outfit(
        size: 14,
        weight: FontWeight.w400,
        lineHeight: 20,
        color: AppColors.onSurfaceVariant),
    // label-lg / md / sm
    labelLarge: outfit(size: 16, weight: FontWeight.w700, lineHeight: 22),
    labelMedium: outfit(size: 14, weight: FontWeight.w600, lineHeight: 18),
    labelSmall: outfit(size: 12, weight: FontWeight.w600, lineHeight: 16),
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: fontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.surface,
    splashFactory: NoSplash.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.headlineSmall,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.surfaceContainerHighest,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.inverseSurface,
      contentTextStyle:
          textTheme.labelMedium?.copyWith(color: AppColors.inverseOnSurface),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.inner),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      titleTextStyle: textTheme.headlineMedium,
      contentTextStyle: textTheme.bodyMedium,
    ),
  );
}

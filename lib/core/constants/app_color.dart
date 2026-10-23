import 'package:flutter/material.dart';

/// Tokens de color del sistema de diseño "Rómpelo Dynamic Party System".
///
/// Fuente de verdad: `design/stitch/DESIGN.md` y el `tailwind.config` de los
/// `code.html`. Los nombres siguen los de Material 3 para que mapeen 1 a 1
/// con el [ColorScheme] que arma `AppTheme`.
abstract final class AppColors {
  // --- Superficies -----------------------------------------------------------
  static const Color surface = Color(0xFFFDF7FF);
  static const Color surfaceDim = Color(0xFFDED6F1);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F1FF);
  static const Color surfaceContainer = Color(0xFFF2EBFF);
  static const Color surfaceContainerHigh = Color(0xFFECE4FF);
  static const Color surfaceContainerHighest = Color(0xFFE7DFF9);
  static const Color onSurface = Color(0xFF1D192C);
  static const Color onSurfaceVariant = Color(0xFF42474E);
  static const Color inverseSurface = Color(0xFF322E42);
  static const Color inverseOnSurface = Color(0xFFF5EEFF);
  static const Color outline = Color(0xFF73777F);
  static const Color outlineVariant = Color(0xFFC3C6D0);

  // --- Primario: azul cielo (ambiente, navegación) --------------------------
  static const Color primary = Color(0xFF3B608C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF95BAEB);
  static const Color onPrimaryContainer = Color(0xFF224A75);
  static const Color primaryFixed = Color(0xFFD2E4FF);
  static const Color primaryFixedDim = Color(0xFFA4C9FB);
  static const Color onPrimaryFixed = Color(0xFF001C37);
  static const Color onPrimaryFixedVariant = Color(0xFF204873);
  static const Color inversePrimary = Color(0xFFA4C9FB);

  // --- Secundario: vino (acción, tensión, Charadas) -------------------------
  static const Color secondary = Color(0xFFB62416);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFD5842);
  static const Color onSecondaryContainer = Color(0xFF5B0200);
  static const Color secondaryFixed = Color(0xFFFFDAD4);
  static const Color secondaryFixedDim = Color(0xFFFFB4A8);
  static const Color onSecondaryFixed = Color(0xFF410100);
  static const Color onSecondaryFixedVariant = Color(0xFF920400);

  /// Vino profundo de DESIGN.md para "buzzers" y timers críticos.
  static const Color wine = Color(0xFF930400);

  // --- Terciario: neutros cálidos (Trivia) ----------------------------------
  static const Color tertiary = Color(0xFF635E51);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFBEB7A8);
  static const Color onTertiaryContainer = Color(0xFF4C483C);
  static const Color tertiaryFixed = Color(0xFFE9E2D1);
  static const Color onTertiaryFixedVariant = Color(0xFF4B473A);

  // --- Error -----------------------------------------------------------------
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // --- Neutros de marca ------------------------------------------------------
  /// Leche: superficies suaves sin reflejo (cartas, reglas, inputs).
  static const Color milk = Color(0xFFFFF7E6);

  /// Marfil cálido, alternativa a [milk] para tarjetas de juego.
  static const Color ivory = Color(0xFFFDFBF7);

  /// Tinta ciruela: reemplaza al negro puro en textos y bordes.
  static const Color ink = Color(0xFF1F1B2E);

  // --- Sombras sólidas "chunky" (offset inferior sin blur) ------------------
  /// Bajo elementos azul cielo ([primaryContainer]).
  static const Color shadowSky = Color(0xFF6F97CE);

  /// Bajo botones [primary].
  static const Color shadowPrimary = Color(0xFF204873);

  /// Bajo botones vino ([secondary] / [wine]).
  static const Color shadowWine = Color(0xFF5C0200);

  /// Capa táctil estándar: tinta al 12 %.
  static const Color shadowTactile = Color(0x1F1F1B2E);

  /// Borde sutil de tarjetas: tinta al 8 %.
  static const Color borderSubtle = Color(0x141F1B2E);
}

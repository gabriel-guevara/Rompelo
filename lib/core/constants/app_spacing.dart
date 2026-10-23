import 'package:flutter/widgets.dart';

/// Escala de espaciados de `DESIGN.md` (en px lógicos).
abstract final class AppSpacing {
  static const double xs = 6; // space-xs  0.375rem
  static const double sm = 12; // space-sm 0.75rem
  static const double md = 16; // space-md / gutter 1rem
  static const double margin = 20; // margen lateral seguro 1.25rem
  static const double lg = 24; // space-lg 1.5rem
  static const double xl = 36; // space-xl 2.25rem

  /// Ancho máximo del contenido en tablet / modo mesa.
  static const double maxContentWidth = 540;

  /// Padding horizontal estándar de las pantallas.
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: margin);
}

/// Radios de esquina de `DESIGN.md`.
abstract final class AppRadius {
  static const double sm = 8; // 0.5rem
  static const double md = 16; // DEFAULT / rounded-2xl
  static const double lg = 24; // 1.5rem
  static const double xl = 32; // rounded-3xl: tarjetas principales
  static const double xxl = 48; // 3rem
  static const double full = 999; // pill

  static const BorderRadius pill = BorderRadius.all(Radius.circular(full));
  static const BorderRadius card = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius inner = BorderRadius.all(Radius.circular(md));
}

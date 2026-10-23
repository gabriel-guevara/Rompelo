import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/router/app_routes.dart';

/// Familia de color con la que se presenta un juego en el catálogo.
///
/// Centraliza los colores de etiqueta, miniatura y CTA para que una tarjeta
/// no tenga que decidir colores "a mano" (y agregar un juego sea solo datos).
enum GameAccent {
  /// Vino festivo (Charadas).
  wine(
    tagBackground: AppColors.secondaryFixed,
    tagForeground: AppColors.onSecondaryFixedVariant,
    iconColor: AppColors.secondary,
    ctaColor: AppColors.secondary,
    ctaShadow: AppColors.shadowWine,
  ),

  /// Azul cielo (Impostor).
  sky(
    tagBackground: AppColors.primaryFixed,
    tagForeground: AppColors.onPrimaryFixed,
    iconColor: AppColors.primary,
    ctaColor: AppColors.primary,
    ctaShadow: AppColors.shadowPrimary,
  ),

  /// Neutro cálido con CTA vino (Trivia).
  warm(
    tagBackground: AppColors.tertiaryFixed,
    tagForeground: AppColors.onTertiaryFixedVariant,
    iconColor: AppColors.secondary,
    ctaColor: AppColors.secondary,
    ctaShadow: AppColors.shadowWine,
  );

  const GameAccent({
    required this.tagBackground,
    required this.tagForeground,
    required this.iconColor,
    required this.ctaColor,
    required this.ctaShadow,
  });

  final Color tagBackground;
  final Color tagForeground;
  final Color iconColor;
  final Color ctaColor;
  final Color ctaShadow;
}

/// Etiqueta corta de un juego (mazos o mecánicas destacadas en la tarjeta).
@immutable
class GameChip {
  const GameChip({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Un juego del catálogo. Inmutable: es dato puro, la UI solo lo lee.
@immutable
class GameItem {
  const GameItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tag,
    required this.durationMinutes,
    required this.minPlayers,
    required this.maxPlayers,
    required this.chips,
    required this.accent,
    required this.ctaIcon,
  });

  /// Identificador estable; también es el segmento `:juego` de las rutas.
  final String id;
  final String title;
  final String description;

  /// Icono que sustituye la ilustración del mockup (no descargable offline).
  final IconData icon;

  /// Vibra del juego, p. ej. "Actuación & risas".
  final String tag;
  final int durationMinutes;
  final int minPlayers;
  final int maxPlayers;
  final List<GameChip> chips;
  final GameAccent accent;

  /// Icono del botón "Configurar y jugar".
  final IconData ctaIcon;

  /// Texto "10 min • 3-12 pers" del mockup.
  String get metaLabel => '$durationMinutes min • $minPlayers-$maxPlayers pers';

  String get configPath => AppRoutes.configureGame(id);
  String get playPath => AppRoutes.playGame(id);
}

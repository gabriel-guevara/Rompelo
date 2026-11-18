import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import 'chunky_pressable.dart';

/// Iconos de los jugadores (se repiten si hay más de 12).
const List<IconData> playerIcons = [
  Icons.star_rounded,
  Icons.pets_rounded,
  Icons.local_pizza_rounded,
  Icons.rocket_launch_rounded,
  Icons.eco_rounded,
  Icons.sports_esports_rounded,
  Icons.music_note_rounded,
  Icons.bolt_rounded,
  Icons.icecream_rounded,
  Icons.palette_rounded,
  Icons.anchor_rounded,
  Icons.wb_sunny_rounded,
];

/// Pares fondo / icono de la paleta de la app, rotando por jugador.
const List<(Color, Color)> _tones = [
  (AppColors.primaryFixed, AppColors.primary),
  (AppColors.secondaryFixed, AppColors.secondary),
  (AppColors.tertiaryFixed, AppColors.onTertiaryFixedVariant),
  (AppColors.surfaceContainerHighest, AppColors.onSurface),
];

IconData playerIcon(int index) => playerIcons[index % playerIcons.length];

/// Avatar circular de un jugador: icono propio de la app sobre un color de
/// la paleta. Reemplaza los emoji (se ven distinto en cada teléfono).
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.index,
    this.size = 40,
    this.elevated = false,
    this.border,
  });

  final int index;
  final double size;

  /// Sombra "chunky" debajo (avatares grandes de las partidas).
  final bool elevated;

  /// Borde opcional (avatares superpuestos).
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _tones[index % _tones.length];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: border == null ? null : Border.all(color: border!, width: 2),
        boxShadow: elevated ? chunkyShadow(AppColors.shadowTactile, 3) : null,
      ),
      child: Icon(playerIcon(index), size: size * 0.55, color: foreground),
    );
  }
}

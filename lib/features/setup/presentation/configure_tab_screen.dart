import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/placeholder_screen.dart';
import '../../catalog/data/games_catalog.dart';
import '../../catalog/domain/game_item.dart';

/// Tab Configurar (`/configurar`): lista de juegos → su configuración.
///
/// Placeholder de la Fase 1; la versión final llega en la Fase 5.
class ConfigureTabScreen extends StatelessWidget {
  const ConfigureTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Configurar',
      icon: Icons.tune_rounded,
      message: 'Elige un juego para ajustar jugadores, mazos y reglas.',
      children: [
        for (final game in gamesCatalog) ...[
          ChunkyButton(
            label: game.title,
            variant: ChunkyButtonVariant.sky,
            height: 48,
            depth: 4,
            leadingIcon: game.icon,
            onPressed: () => context.go(game.configPath),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

/// Configuración de un juego (`/configurar/:juego`).
///
/// Placeholder de la Fase 1; cada juego tendrá su pantalla en la Fase 3.
class GameConfigPlaceholderScreen extends StatelessWidget {
  const GameConfigPlaceholderScreen({super.key, required this.game});

  final GameItem game;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: game.title,
      icon: game.icon,
      message: '${game.description}\n\nLa configuración llega en la Fase 3.',
      children: [
        ChunkyButton(
          label: 'Empezar partida',
          trailingIcon: game.ctaIcon,
          onPressed: () => context.go(game.playPath),
        ),
      ],
    );
  }
}

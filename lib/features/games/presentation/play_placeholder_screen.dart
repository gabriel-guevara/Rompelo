import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/placeholder_screen.dart';
import '../../catalog/domain/game_item.dart';

/// Partida en vivo (`/partida/:juego`): pantalla completa, sin bottom nav.
///
/// Placeholder de la Fase 1; las partidas mock llegan en la Fase 4.
class PlayPlaceholderScreen extends StatelessWidget {
  const PlayPlaceholderScreen({super.key, required this.game});

  final GameItem game;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: game.title,
      icon: game.icon,
      message: 'Partida en vivo. Las cartas y el temporizador llegan en la '
          'Fase 4.',
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Partida en vivo'),
        actions: [
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.explore),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Salir'),
          ),
        ],
      ),
      children: [
        ChunkyButton(
          label: 'Ver resultados',
          variant: ChunkyButtonVariant.sky,
          leadingIcon: Icons.emoji_events_rounded,
          onPressed: () => context.go(AppRoutes.results),
        ),
      ],
    );
  }
}

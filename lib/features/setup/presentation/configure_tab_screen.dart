import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/placeholder_screen.dart';
import '../../catalog/data/games_catalog.dart';

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

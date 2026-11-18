import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_pressable.dart';
import '../data/games_catalog.dart';
import '../domain/game_item.dart';

/// Botón "?" de la barra superior: abre las reglas de los juegos.
///
/// Con [gameId] (dentro de una partida) muestra solo las de ese juego.
class HowToPlayButton extends StatelessWidget {
  const HowToPlayButton({super.key, this.gameId});

  final String? gameId;

  @override
  Widget build(BuildContext context) {
    return ChunkyPressable(
      key: const ValueKey('how-to-play'),
      onTap: () => showHowToPlay(context, gameId: gameId),
      semanticLabel: '¿Cómo se juega?',
      builder: (context, pressed) => AnimatedScale(
        scale: pressed ? 0.95 : 1,
        duration: kChunkyPressDuration,
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.help_outline_rounded,
              size: 24, color: AppColors.primary),
        ),
      ),
    );
  }
}

Future<void> showHowToPlay(BuildContext context, {String? gameId}) {
  final game = gameId == null ? null : gameById(gameId);
  final games = game == null ? gamesCatalog : [game];
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: games.length == 1 ? 0.6 : 0.8,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.margin, 0, AppSpacing.margin, AppSpacing.xl),
        children: [
          Text('¿Cómo se juega?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Un solo teléfono para todo el grupo, sin internet.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          for (final g in games) ...[
            const SizedBox(height: AppSpacing.lg),
            _GameRules(game: g),
          ],
        ],
      ),
    ),
  );
}

class _GameRules extends StatelessWidget {
  const _GameRules({required this.game});

  final GameItem game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = game.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.tagBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(game.icon, size: 22, color: accent.iconColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(game.title, style: textTheme.headlineSmall),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final (i, rule) in game.rules.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Text('${i + 1}', style: textTheme.labelSmall),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(rule, style: textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}

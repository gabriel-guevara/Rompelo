import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/chunky_card.dart';
import '../../../core/widgets/pill_chip.dart';
import '../domain/game_item.dart';

/// Tarjeta de un juego en el home (mockup `home`): tag, duración, título,
/// descripción, ilustración, chips y CTA "Configurar y jugar".
///
/// Es "tonta" (presentacional): recibe el juego y un callback, no sabe nada
/// de rutas ni de providers. Así se puede reutilizar y testear aislada.
class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, required this.onPlay});

  final GameItem game;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = game.accent;

    return ChunkyCard(
      borderColor: accent.cardBorder,
      shadowColor: accent.ctaColor.withValues(alpha: 0.08),
      depth: 6,
      padding: const EdgeInsets.all(AppSpacing.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        PillChip(
                          label: game.tag,
                          background: accent.tagBackground,
                          foreground: accent.tagForeground,
                        ),
                        PillChip(
                          label: game.metaLabel,
                          icon: Icons.schedule_rounded,
                          background: AppColors.surfaceContainerLow,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(game.title, style: textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(game.description, style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _Illustration(game: game),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final chip in game.chips)
                PillChip(
                  label: chip.label,
                  icon: chip.icon,
                  iconColor: accent.iconColor,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ChunkyButton(
            label: 'Configurar y jugar',
            variant: accent == GameAccent.sky
                ? ChunkyButtonVariant.primary
                : ChunkyButtonVariant.wine,
            height: 48,
            depth: 4,
            trailingIcon: game.ctaIcon,
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}

/// Sustituye la ilustración del mockup (no descargable offline) por el
/// icono del juego sobre un cuadro del color de su tag.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.game});

  final GameItem game;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: game.accent.tagBackground.withValues(alpha: 0.6),
        borderRadius: AppRadius.inner,
      ),
      child: Icon(game.icon, size: 34, color: game.accent.iconColor),
    );
  }
}

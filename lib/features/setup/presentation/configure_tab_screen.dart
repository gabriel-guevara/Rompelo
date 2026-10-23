import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/plural.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/chunky_card.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/rompelo_app_bar.dart';
import '../../catalog/data/games_catalog.dart';
import '../../catalog/domain/game_item.dart';
import '../domain/match_setup.dart';
import '../providers/match_setup_provider.dart';

/// Resumen en una línea de una configuración guardada.
///
/// El `switch` sobre la `sealed class` es **exhaustivo**: si mañana se
/// agrega un juego (una subclase nueva), esto no compila hasta cubrirlo.
String describeSetup(MatchSetup setup) {
  final decks = plural(setup.selectedDecks.length, 'mazo', 'mazos');
  final parts = switch (setup) {
    CharadesSetup(:final mode, :final turnSeconds, :final rounds) => [
        mode == CharadesMode.teams ? '2 equipos' : 'Todos vs todos',
        '$turnSeconds s por turno',
        plural(rounds, 'ronda', 'rondas'),
      ],
    TriviaSetup(:final questionSeconds, :final targetPoints) => [
        '$questionSeconds s por pregunta',
        'Meta $targetPoints pts',
      ],
    ImpostorSetup(:final impostors, :final debateMinutes) => [
        plural(impostors, 'impostor', 'impostores'),
        'Debate $debateMinutes min',
      ],
  };
  return [plural(setup.players, 'jugador', 'jugadores'), ...parts, decks]
      .join(' · ');
}

/// Tab Configurar (`/configurar`): un acceso por juego con su configuración
/// actual, para ajustarla o jugar directo con ella.
///
/// No tiene mockup: reutiliza tarjetas, chips y botones del sistema.
class ConfigureTabScreen extends StatelessWidget {
  const ConfigureTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const RompeloAppBar(subtitle: 'Configurar'),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.lg,
                AppSpacing.margin, AppSpacing.xl),
            children: [
              Text('Configurar', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ajusta jugadores, mazos y reglas. Los cambios se guardan '
                'para la próxima partida.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final game in gamesCatalog) ...[
                _GameSetupCard(
                    key: ValueKey('setup-card-${game.id}'), game: game),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de un juego: solo esta parte escucha su provider, así cambiar
/// la config de Trivia no reconstruye las tarjetas de los otros juegos.
class _GameSetupCard extends ConsumerWidget {
  const _GameSetupCard({super.key, required this.game});

  final GameItem game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final setup = ref.watch(matchSetupProvider(game.id));
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
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.tagBackground,
                  borderRadius: AppRadius.inner,
                ),
                child: Icon(game.icon, size: 28, color: accent.iconColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.title, style: textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    PillChip(
                      label: game.metaLabel,
                      icon: Icons.schedule_rounded,
                      background: AppColors.surfaceContainerLow,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            describeSetup(setup),
            key: ValueKey('setup-summary-${game.id}'),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ChunkyButton(
                  label: 'Ajustar',
                  variant: ChunkyButtonVariant.soft,
                  leadingIcon: Icons.tune_rounded,
                  height: 48,
                  depth: 4,
                  onPressed: () => context.go(game.configPath),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ChunkyButton(
                  label: 'Jugar',
                  variant: accent == GameAccent.sky
                      ? ChunkyButtonVariant.primary
                      : ChunkyButtonVariant.wine,
                  leadingIcon: Icons.play_arrow_rounded,
                  height: 48,
                  depth: 4,
                  onPressed: () => context.go(game.playPath),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

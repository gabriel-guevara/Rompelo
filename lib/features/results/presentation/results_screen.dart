import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/chunky_card.dart';
import '../../../core/widgets/rompelo_app_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../catalog/data/games_catalog.dart';
import '../../games/providers/match_result_provider.dart';
import '../widgets/award_tile.dart';
import '../widgets/confetti_backdrop.dart';
import '../widgets/podium.dart';
import '../widgets/stat_tile.dart';

/// Tab Marcador (`/resultados`, mockup `resultados`).
///
/// Es un `ConsumerWidget` sin estado propio: todo sale de
/// [lastMatchResultProvider]. Cuando una partida guarda un resultado nuevo,
/// `ref.watch` reconstruye esta pantalla sola (como un `useSelector`).
class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastMatchResultProvider);

    return Scaffold(
      appBar: const RompeloAppBar(subtitle: 'Marcador'),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.md,
                AppSpacing.margin, AppSpacing.xl),
            children: result == null
                ? const [_EmptyResults()]
                : _resultChildren(context, result),
          ),
        ),
      ),
    );
  }

  List<Widget> _resultChildren(BuildContext context, MatchResult result) {
    final game = gameById(result.gameId);
    final rest = result.scores.skip(3).toList();

    return [
      _Header(result: result),
      const SizedBox(height: AppSpacing.lg),
      Podium(scores: result.scores.take(3).toList()),
      if (rest.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.md),
        _RestOfTable(entries: rest, firstPosition: 4),
      ],
      if (result.awards.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: 'Premios de la noche',
          size: SectionHeaderSize.title,
          trailing: Text('Momentos clave',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final award in result.awards) ...[
          AwardTile(award: award),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
      const SizedBox(height: AppSpacing.lg),
      // IntrinsicHeight: las dos tarjetas miden lo mismo aunque un texto
      // ocupe más líneas (como `align-items: stretch` en un grid).
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StatTile(
                label: result.playsLabel,
                value: '${result.plays}',
                caption: durationCaption(result.elapsed),
                icon: Icons.style_outlined,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                label: 'Puntos repartidos',
                value: '${result.totalPoints}',
                caption: result.tiedAtTop
                    ? 'Empate en la cima'
                    : 'Ventaja de ${result.leadMargin} pts',
                icon: Icons.local_fire_department_outlined,
                iconColor: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      ChunkyButton(
        label: '¡Jugar revancha inmediata!',
        leadingIcon: Icons.replay_rounded,
        depth: 6,
        // Los providers de configuración no son `autoDispose`: la partida
        // nueva arranca con exactamente los mismos ajustes.
        onPressed: () => context.go(AppRoutes.playGame(result.gameId)),
      ),
      const SizedBox(height: AppSpacing.sm),
      ChunkyButton(
        label: 'Volver al catálogo de juegos',
        variant: ChunkyButtonVariant.soft,
        leadingIcon: Icons.grid_view_rounded,
        height: 52,
        depth: 4,
        onPressed: () => context.go(AppRoutes.explore),
      ),
      if (game != null) ...[
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Última partida: ${game.title}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ];
  }
}

/// "En 18 minutos" / "En menos de 1 minuto".
String durationCaption(Duration elapsed) {
  final minutes = elapsed.inMinutes;
  if (minutes < 1) return 'En menos de 1 minuto';
  return minutes == 1 ? 'En 1 minuto' : 'En $minutes minutos';
}

/// Badge "Fin del juego", título y subtítulo, con confeti detrás.
class _Header extends StatelessWidget {
  const _Header({required this.result});

  final MatchResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = [
      result.tiedAtTop ? '¡Empate en la cima!' : result.summary,
      if (result.detail.isNotEmpty) result.detail,
    ].join(' • ');

    return Stack(
      children: [
        const Positioned.fill(child: ConfettiBackdrop()),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: AppRadius.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.celebration_rounded,
                        size: 16, color: AppColors.onSecondaryFixedVariant),
                    const SizedBox(width: 6),
                    Text('Fin del juego',
                        style: textTheme.labelSmall?.copyWith(
                            color: AppColors.onSecondaryFixedVariant)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '¡Partida finalizada!',
                textAlign: TextAlign.center,
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style:
                    AppTheme.withWeight(textTheme.bodyMedium!, FontWeight.w500)
                        .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Puestos 4.º en adelante (todos vs todos o el Impostor con 6+ jugadores):
/// el RF pide el ranking completo, no solo el podio.
class _RestOfTable extends StatelessWidget {
  const _RestOfTable({required this.entries, required this.firstPosition});

  final List<ScoreEntry> entries;
  final int firstPosition;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChunkyCard(
      color: AppColors.surfaceContainerLow,
      depth: 3,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${firstPosition + i}.',
                      style: AppTheme.tabular(textTheme.labelLarge!)
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  Expanded(
                    child: Text(entries[i].name,
                        style: textTheme.labelLarge,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text('${entries[i].points} pts',
                      style: AppTheme.tabular(textTheme.labelMedium!)
                          .copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Estado vacío: todavía no se jugó ninguna partida en esta sesión.
class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text('Marcador', style: textTheme.displayMedium),
        const SizedBox(height: AppSpacing.md),
        ChunkyCard(
          color: AppColors.milk,
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    size: 40, color: AppColors.secondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Aún no hay marcador',
                  textAlign: TextAlign.center, style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Juega una partida y aquí verás el podio, los premios de la '
                'noche y las estadísticas.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ChunkyButton(
          label: 'Elegir un juego',
          variant: ChunkyButtonVariant.primary,
          leadingIcon: Icons.grid_view_rounded,
          onPressed: () => context.go(AppRoutes.explore),
        ),
      ],
    );
  }
}

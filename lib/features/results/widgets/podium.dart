import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../games/domain/match_result.dart';

/// Podio de los 3 primeros (mockup `resultados`): 2.º a la izquierda, 1.º al
/// centro y más alto en vino, 3.º a la derecha.
///
/// Recibe los puntajes ya ordenados. Con 2 participantes (dos equipos) se
/// dibujan solo plata y oro, centrados y con el mismo ancho de columna.
class Podium extends StatelessWidget {
  const Podium({super.key, required this.scores});

  final List<ScoreEntry> scores;

  @override
  Widget build(BuildContext context) {
    Widget slot(int place) => Expanded(
          child: place <= scores.length
              ? _PodiumColumn(
                  key: ValueKey('podium-$place'),
                  place: _places[place - 1],
                  entry: scores[place - 1],
                )
              : const SizedBox.shrink(),
        );

    final withBronze = scores.length >= 3;

    // Orden visual 2-1-3; `crossAxisAlignment.end` alinea los escalones
    // por la base, como un podio real.
    final podium = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (scores.length >= 2) ...[
          slot(2),
          const SizedBox(width: AppSpacing.xs),
        ],
        slot(1),
        if (withBronze) ...[
          const SizedBox(width: AppSpacing.xs),
          slot(3),
        ],
      ],
    );

    // Con menos de 3 puestos, cada columna conserva su tercio de ancho y el
    // conjunto queda centrado (un solo puesto: un tercio al centro).
    if (withBronze) return podium;
    return Center(
      child: FractionallySizedBox(
        widthFactor: scores.length == 2 ? 2 / 3 : 1 / 3,
        child: podium,
      ),
    );
  }

  static const _places = [_Place.gold, _Place.silver, _Place.bronze];
}

/// Cada puesto con su altura, colores y textos. Un enum "rico" en lugar de
/// tres `if` repartidos por el `build`.
enum _Place {
  gold(1, '¡Campeones!', '👑', 160, 80),
  silver(2, 'Plata', '🥈', 112, 64),
  bronze(3, 'Bronce', '🥉', 80, 64);

  const _Place(
      this.number, this.label, this.emoji, this.blockHeight, this.avatarSize);

  final int number;
  final String label;
  final String emoji;
  final double blockHeight;
  final double avatarSize;

  bool get isFirst => this == gold;
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({super.key, required this.place, required this.entry});

  final _Place place;
  final ScoreEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final first = place.isFirst;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (first)
          const Icon(Icons.emoji_events_rounded,
              size: 32, color: AppColors.secondaryContainer),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: place.avatarSize,
              height: place.avatarSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: first
                    ? AppColors.secondaryFixed
                    : AppColors.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceContainerLowest,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.12),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(place.emoji,
                  style: TextStyle(fontSize: place.avatarSize * 0.45)),
            ),
            if (first)
              Positioned(
                bottom: -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    '#1',
                    style: AppTheme.withWeight(
                            textTheme.labelSmall!, FontWeight.w800)
                        .copyWith(color: AppColors.onSecondary),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: first ? AppSpacing.md : AppSpacing.xs),
        Text(
          entry.name,
          textAlign: TextAlign.center,
          // 2 líneas: "Team Burbujas" no cabe en una columna de un tercio.
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: first
              ? AppTheme.withWeight(textTheme.headlineMedium!, FontWeight.w900)
                  .copyWith(color: AppColors.secondary)
              : textTheme.headlineSmall,
        ),
        Text(
          '${entry.points} pts',
          key: ValueKey('podium-points-${place.number}'),
          style: AppTheme.tabular(first
              ? textTheme.labelLarge!.copyWith(color: AppColors.secondary)
              : textTheme.labelSmall!
                  .copyWith(color: AppColors.onSurfaceVariant)),
        ),
        const SizedBox(height: AppSpacing.xs),
        _Step(place: place),
      ],
    );
  }
}

/// Escalón del podio con el número y la etiqueta del puesto.
class _Step extends StatelessWidget {
  const _Step({required this.place});

  final _Place place;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final first = place.isFirst;
    final circle = first ? 40.0 : 32.0;

    return Container(
      width: double.infinity,
      height: place.blockHeight,
      margin: EdgeInsets.only(bottom: first ? 6 : 5),
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: first ? AppColors.secondary : AppColors.surfaceContainer,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: first ? AppColors.shadowWine : AppColors.surfaceDim,
            offset: Offset(0, first ? 6 : 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (first)
            // Círculo decorativo de la esquina (como en el mockup).
            Positioned(
              right: -16,
              bottom: -16,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: circle,
                  height: circle,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${place.number}',
                    style: AppTheme.tabular(AppTheme.withWeight(
                            first
                                ? textTheme.headlineLarge!
                                : textTheme.headlineMedium!,
                            FontWeight.w800))
                        .copyWith(
                            color: first
                                ? AppColors.secondary
                                : AppColors.tertiary),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    place.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: first
                        ? AppTheme.withWeight(
                                textTheme.labelMedium!, FontWeight.w800)
                            .copyWith(color: AppColors.secondaryFixed)
                        : textTheme.labelSmall
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

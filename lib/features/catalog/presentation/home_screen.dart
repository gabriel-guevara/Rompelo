import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/counter_stepper.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/placeholder_screen.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/segmented_pills.dart';
import '../../../core/widgets/selection_tile.dart';
import '../data/games_catalog.dart';
import '../domain/game_item.dart';

/// Tab Explorar (`/`).
///
/// **Placeholder de la Fase 1**: lista los juegos del catálogo para probar la
/// navegación y muestra una vitrina de los widgets core. La Fase 2 lo
/// reemplaza por el home real del mockup.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Estado local solo para la vitrina; el estado real de la partida vivirá
  // en providers de Riverpod (Fase 3).
  int _players = 6;
  String _vibe = 'Todos';
  bool _teams = true;
  bool _deckSelected = true;

  static const _vibes = ['Todos', '🎉 Fiesta total', '🕵️ Misterio'];

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: '¿Qué jugamos hoy?',
      icon: Icons.sports_esports_rounded,
      message: 'El home completo llega en la Fase 2. '
          'Por ahora puedes ir a la configuración de cada juego.',
      children: [
        const SectionHeader(title: 'Juegos', size: SectionHeaderSize.title),
        const SizedBox(height: AppSpacing.sm),
        for (final game in gamesCatalog) ...[
          ChunkyButton(
            label: game.title,
            variant: game.accent == GameAccent.sky
                ? ChunkyButtonVariant.primary
                : ChunkyButtonVariant.wine,
            height: 48,
            depth: 4,
            trailingIcon: game.ctaIcon,
            onPressed: () => context.go(game.configPath),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(
            title: 'Componentes base', size: SectionHeaderSize.title),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final vibe in _vibes)
              PillChip(
                label: vibe,
                selected: vibe == _vibe,
                onTap: () => setState(() => _vibe = vibe),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(
          title: 'Total de jugadores',
          trailing: CounterStepper(
            value: _players,
            min: 2,
            max: 24,
            onChanged: (value) => setState(() => _players = value),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SegmentedPills<bool>(
          options: const [
            SegmentOption(
                value: true, label: 'Por equipos', icon: Icons.groups_rounded),
            SegmentOption(
                value: false,
                label: 'Todos vs todos',
                icon: Icons.celebration_rounded),
          ],
          selected: _teams,
          onChanged: (value) => setState(() => _teams = value),
        ),
        const SizedBox(height: AppSpacing.md),
        SelectionTile(
          title: 'Películas & series virales',
          subtitle: '140 cartas listas para interpretar',
          icon: Icons.movie_rounded,
          badge: 'Popular',
          selected: _deckSelected,
          onTap: () => setState(() => _deckSelected = !_deckSelected),
        ),
        const SizedBox(height: AppSpacing.md),
        ChunkyButton(
          label: '¡Elegir juego al azar!',
          leadingIcon: Icons.shuffle_rounded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        ChunkyButton(
          label: 'Botón cielo',
          variant: ChunkyButtonVariant.sky,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        ChunkyButton(
          label: 'Botón fantasma',
          variant: ChunkyButtonVariant.ghost,
          onPressed: () {},
        ),
      ],
    );
  }
}

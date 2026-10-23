import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/chunky_pressable.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/rompelo_app_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../setup/providers/player_count_provider.dart';
import '../data/games_catalog.dart';
import '../domain/game_item.dart';
import '../widgets/game_card.dart';
import '../widgets/magic_picker_card.dart';

/// Tab Explorar (`/`): mockup `design/stitch/home`.
///
/// Es `ConsumerStatefulWidget` porque mezcla dos tipos de estado:
/// - **Global** (Riverpod): el número de jugadores, que otras pantallas leen.
/// - **Local** (`setState`): la vibra filtrada y la mesa, que solo importan
///   aquí (como un `useState` en React).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// `null` = chip "Todos".
  GameVibe? _vibe;
  int _table = 4;

  void _pickRandomGame() {
    final game = pickRandomGame(players: ref.read(playerCountProvider));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('¡Tocó ${game.title}!')));
    context.go(game.configPath);
  }

  Future<void> _chooseTable() async {
    final table = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) => _TableSheet(selected: _table),
    );
    if (table != null) setState(() => _table = table);
  }

  @override
  Widget build(BuildContext context) {
    // `watch` reconstruye el home cada vez que cambia el provider.
    final players = ref.watch(playerCountProvider);
    final games = gamesByVibe(_vibe);

    return Scaffold(
      appBar: RompeloAppBar(
        actions: [
          _BellButton(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No hay novedades por ahora')),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const RompeloAvatar(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          // Sin padding horizontal en la lista: así el carrusel de vibras
          // puede llegar al borde de la pantalla, como en el mockup.
          child: ListView(
            padding: const EdgeInsets.only(
                top: AppSpacing.md, bottom: AppSpacing.xl),
            children: [
              _padded(_WelcomeBar(table: _table, onTableTap: _chooseTable)),
              const SizedBox(height: AppSpacing.margin),
              _padded(
                MagicPickerCard(
                  players: players,
                  minPlayers: PlayerCountNotifier.min,
                  maxPlayers: PlayerCountNotifier.max,
                  onPlayersChanged: ref.read(playerCountProvider.notifier).set,
                  onPickRandom: _pickRandomGame,
                ),
              ),
              const SizedBox(height: AppSpacing.margin),
              _padded(
                SectionHeader(
                  title: 'Explora por vibra',
                  size: SectionHeaderSize.title,
                  trailing: _CountBadge(count: games.length),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _VibeFilter(
                selected: _vibe,
                onSelected: (vibe) => setState(() => _vibe = vibe),
              ),
              const SizedBox(height: AppSpacing.md),
              if (games.isEmpty)
                _padded(Text(
                  'Aún no hay juegos con esta vibra.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
              for (final game in games)
                _padded(
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: GameCard(
                      key: ValueKey('game-card-${game.id}'),
                      game: game,
                      onPlay: () => context.go(game.configPath),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _padded(Widget child) =>
      Padding(padding: AppSpacing.screenPadding, child: child);
}

/// "¿Qué jugamos hoy?" + selector de mesa.
class _WelcomeBar extends StatelessWidget {
  const _WelcomeBar({required this.table, required this.onTableTap});

  final int table;
  final VoidCallback onTableTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Qué jugamos hoy?', style: textTheme.headlineMedium),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.smartphone_rounded,
                      size: 17, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text('Pasa el móvil al centro de la mesa',
                        style: textTheme.bodySmall),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ChunkyPressable(
          onTap: onTableTap,
          semanticLabel: 'Mesa $table',
          builder: (context, pressed) => AnimatedScale(
            scale: pressed ? 0.95 : 1,
            duration: kChunkyPressDuration,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.pill,
                border: Border.all(color: AppColors.surfaceContainerHighest),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Mesa $table', style: textTheme.labelMedium),
                  const SizedBox(width: 2),
                  const Icon(Icons.expand_more_rounded,
                      size: 16, color: AppColors.outline),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Hoja inferior para elegir la mesa (dato decorativo: no hay backend).
class _TableSheet extends StatelessWidget {
  const _TableSheet({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.margin, 0, AppSpacing.margin, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿En qué mesa están?',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (var table = 1; table <= 8; table++)
                  PillChip(
                    label: 'Mesa $table',
                    selected: table == selected,
                    onTap: () => Navigator.of(context).pop(table),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Carrusel horizontal de chips "Todos · 🎉 Fiesta total · …".
class _VibeFilter extends StatelessWidget {
  const _VibeFilter({required this.selected, required this.onSelected});

  final GameVibe? selected;
  final ValueChanged<GameVibe?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          PillChip(
            label: 'Todos',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final vibe in GameVibe.values) ...[
            const SizedBox(width: AppSpacing.xs),
            PillChip(
              label: vibe.chipLabel,
              selected: vibe == selected,
              onTap: () => onSelected(vibe),
            ),
          ],
        ],
      ),
    );
  }
}

/// Badge "3 juegos listos" junto a "Explora por vibra".
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 juego listo' : '$count juegos listos';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.6),
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: AppTheme.withWeight(
          Theme.of(context).textTheme.labelSmall!,
          FontWeight.w700,
        ).copyWith(color: AppColors.primary),
      ),
    );
  }
}

/// Campana del header (decorativa: la app no tiene notificaciones reales).
class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChunkyPressable(
      onTap: onTap,
      semanticLabel: 'Notificaciones',
      builder: (context, pressed) => AnimatedScale(
        scale: pressed ? 0.95 : 1,
        duration: kChunkyPressDuration,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none_rounded,
              size: 20, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

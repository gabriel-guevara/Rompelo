import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/chunky_pressable.dart';
import '../../../core/widgets/counter_stepper.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/segmented_pills.dart';
import '../../catalog/data/games_catalog.dart';
import '../data/deck_options.dart';
import '../domain/match_setup.dart';
import '../providers/match_setup_provider.dart';
import '../widgets/config_scaffold.dart';
import '../widgets/config_section.dart';
import '../widgets/deck_list.dart';
import '../widgets/game_config_hero.dart';
import '../widgets/player_names_editor.dart';
import '../widgets/team_names_row.dart';
import 'config_feedback.dart';

/// Configuración de Charadas (`/configurar/charadas`), mockup
/// `design/stitch/config_charadas`.
class CharadesConfigScreen extends ConsumerWidget {
  const CharadesConfigScreen({super.key});

  static String _turnLabel(int seconds) => switch (seconds) {
        45 => 'Ritmo exprés',
        60 => '1 minuto frenético',
        _ => 'Con calma',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(charadesSetupProvider);
    // `.notifier` da acceso a los métodos; no provoca reconstrucciones.
    final notifier = ref.read(charadesSetupProvider.notifier);
    final game = gameById(setup.gameId)!;

    return ConfigScaffold(
      cta: ChunkyButton(
        label: '¡Empezar a actuar!',
        leadingIcon: Icons.play_arrow_rounded,
        onPressed: () => context.go(game.playPath),
      ),
      children: [
        const GameConfigHero(
          title: 'Charadas alocadas',
          description: 'Coloca el móvil en la frente y adivina con tu equipo '
              'antes de que el reloj vuele.',
          tags: [
            PillChip(
              label: 'Actuación & mímica',
              icon: Icons.theater_comedy_rounded,
              background: AppColors.secondary,
              foreground: AppColors.onSecondary,
            ),
            PillChip(
              label: 'Rápido y alocado',
              icon: Icons.local_fire_department_rounded,
              background: AppColors.primaryContainer,
              foreground: AppColors.onPrimaryContainer,
            ),
          ],
          footer: _TiltTip(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Modo de juego'),
            const SizedBox(height: AppSpacing.xs),
            SegmentedPills<CharadesMode>(
              options: const [
                SegmentOption(
                  value: CharadesMode.teams,
                  label: 'Por equipos',
                  icon: Icons.groups_rounded,
                ),
                SegmentOption(
                  value: CharadesMode.freeForAll,
                  label: 'Todos vs todos',
                  icon: Icons.celebration_rounded,
                ),
              ],
              selected: setup.mode,
              onChanged: notifier.setMode,
            ),
          ],
        ),
        ConfigSection(
          children: [
            RuleRow(
              title: 'Total de jugadores',
              subtitle: 'Entre risas y caos',
              trailing: CounterStepper(
                value: setup.players,
                min: setup.minPlayers,
                max: setup.maxPlayers,
                onChanged: notifier.setPlayers,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (setup.mode == CharadesMode.teams) ...[
              const SectionHeader(title: 'Nombres de bandos rivales'),
              const SizedBox(height: AppSpacing.xs),
              TeamNamesRow(
                names: setup.teamNames,
                onRename: notifier.renameTeam,
              ),
            ] else ...[
              const SectionHeader(title: 'Nombres de jugadores'),
              const SizedBox(height: AppSpacing.xs),
              PlayerNamesEditor(
                names: setup.playerNames,
                tint: AppColors.secondaryFixed.withValues(alpha: 0.5),
                onRename: notifier.renamePlayer,
              ),
            ],
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Mazos temáticos',
              trailing: CountBadge(
                  label: '${setup.selectedDecks.length} seleccionados'),
            ),
            const SizedBox(height: AppSpacing.sm),
            DeckList(
              decks: charadesDecks,
              selected: setup.selectedDecks,
              onToggle: (id) {
                if (!notifier.toggleDeck(id)) {
                  showConfigMessage(context, 'Deja al menos un mazo activo');
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _CustomDeckTile(
              count: setup.customWords.length,
              onTap: () async {
                final words = await showModalBottomSheet<List<String>>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => _CustomDeckSheet(initial: setup.customWords),
                );
                if (words != null) notifier.setCustomWords(words);
              },
            ),
          ],
        ),
        ConfigSection(
          title: 'Reglas de la ronda',
          trailing: const Icon(Icons.tune_rounded, color: AppColors.secondary),
          children: [
            OptionLabel(
              label: 'Tiempo por turno',
              value: _turnLabel(setup.turnSeconds),
            ),
            SegmentedPills<int>(
              options: [
                for (final s in CharadesSetup.turnOptions)
                  SegmentOption(value: s, label: '$s s'),
              ],
              selected: setup.turnSeconds,
              onChanged: notifier.setTurnSeconds,
            ),
            const SizedBox(height: AppSpacing.md),
            RuleSwitch(
              title: 'Penalización al pasar',
              subtitle: 'Restar 1 punto si te rindes con una carta',
              value: setup.penaltyOnPass,
              onChanged: notifier.setPenaltyOnPass,
            ),
            const SizedBox(height: AppSpacing.md),
            RuleRow(
              title: 'Rondas por partida',
              subtitle: 'Equilibrio ideal para ${setup.players} personas',
              trailing: CounterStepper(
                key: const ValueKey('rounds-stepper'),
                value: setup.rounds,
                min: CharadesSetup.minRounds,
                max: CharadesSetup.maxRounds,
                semanticName: 'rondas',
                onChanged: notifier.setRounds,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OptionLabel(
              label: 'Dificultad de las cartas',
              value: switch (setup.difficulty) {
                CharadesDifficulty.easy => '1 punto por carta',
                CharadesDifficulty.medium => '2 puntos por carta',
                CharadesDifficulty.hard => '3 puntos por carta',
                CharadesDifficulty.mixed => '1, 2 o 3 puntos',
              },
            ),
            SegmentedPills<CharadesDifficulty>(
              key: const ValueKey('charades-difficulty'),
              options: [
                for (final d in CharadesDifficulty.values)
                  SegmentOption(value: d, label: d.label),
              ],
              selected: setup.difficulty,
              onChanged: notifier.setDifficulty,
            ),
            const SizedBox(height: AppSpacing.md),
            RuleSwitch(
              title: 'Control por inclinación',
              subtitle: 'Móvil en la frente: abajo = acierto, arriba = pasar',
              value: setup.tiltControls,
              onChanged: notifier.setTiltControls,
            ),
          ],
        ),
        const _SpaceWarning(),
      ],
    );
  }
}

/// Consejo de la cabecera: cómo marcar acierto y pasar.
class _TiltTip extends StatelessWidget {
  const _TiltTip();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final bold = style?.copyWith(fontWeight: FontWeight.w700);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        borderRadius: AppRadius.inner,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.secondaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.screen_rotation_rounded,
                color: AppColors.secondary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: style?.copyWith(color: AppColors.onSurface),
                children: [
                  const TextSpan(
                      text: 'Gira la pantalla hacia abajo para marcar '),
                  TextSpan(
                    text: 'Acierto (+1)',
                    style: bold?.copyWith(color: AppColors.secondary),
                  ),
                  const TextSpan(text: ' y hacia arriba para '),
                  TextSpan(text: 'Pasar', style: bold),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Acceso al futuro "Mazo personalizado rápido" (borde punteado en el
/// mockup; aquí borde sólido suave).
class _CustomDeckTile extends StatelessWidget {
  const _CustomDeckTile({required this.count, required this.onTap});

  /// Palabras propias ya guardadas (0 = mazo vacío).
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChunkyPressable(
      onTap: onTap,
      semanticLabel: 'Mazo personalizado rápido',
      builder: (context, pressed) => AnimatedScale(
        scale: pressed ? 0.98 : 1,
        duration: kChunkyPressDuration,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppRadius.inner,
            border: Border.all(color: AppColors.outlineVariant, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.inner,
                ),
                child: const Icon(Icons.library_add_rounded,
                    color: AppColors.secondary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        count == 0
                            ? '+ Mazo personalizado rápido'
                            : 'Mazo personalizado ($count)',
                        style: textTheme.labelLarge),
                    Text(
                        count == 0
                            ? 'Agrega chistes internos de tus amigos'
                            : 'Se mezclan con los mazos elegidos · Toca '
                                'para editar',
                        style: textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja para escribir el mazo personalizado: una palabra o frase por línea.
/// Devuelve la lista al guardar (o `null` si se cierra sin guardar).
class _CustomDeckSheet extends StatefulWidget {
  const _CustomDeckSheet({required this.initial});

  final List<String> initial;

  @override
  State<_CustomDeckSheet> createState() => _CustomDeckSheetState();
}

class _CustomDeckSheetState extends State<_CustomDeckSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial.join('\n'));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _words => _controller.text.split('\n');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      // Sube la hoja por encima del teclado.
      padding: EdgeInsets.fromLTRB(AppSpacing.margin, 0, AppSpacing.margin,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mazo personalizado', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Escribe una palabra o frase por línea (máximo '
            '${CharadesSetup.maxCustomWords}). Se guardan mientras la app '
            'esté abierta.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const ValueKey('custom-deck-field'),
            controller: _controller,
            autofocus: widget.initial.isEmpty,
            minLines: 5,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'El tío bailando\nLa profe de mate\n…',
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: AppRadius.inner,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ChunkyButton(
            label: 'Guardar mazo',
            leadingIcon: Icons.check_rounded,
            height: 52,
            onPressed: () => Navigator.of(context).pop(_words),
          ),
          if (widget.initial.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            ChunkyButton(
              label: 'Vaciar mazo',
              height: 44,
              variant: ChunkyButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(const <String>[]),
            ),
          ],
        ],
      ),
    );
  }
}

/// Aviso final sobre el espacio para actuar.
class _SpaceWarning extends StatelessWidget {
  const _SpaceWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed.withValues(alpha: 0.4),
        borderRadius: AppRadius.inner,
      ),
      child: Row(
        children: [
          const Icon(Icons.front_hand_rounded, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Asegúrate de tener espacio libre: ¡habrá saltos, gestos raros '
              'y cero palabras!',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

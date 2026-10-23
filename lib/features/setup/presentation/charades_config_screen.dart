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
              Row(
                children: [
                  Expanded(
                    child: _TeamNameCard(
                      label: 'Equipo A',
                      icon: Icons.wine_bar_rounded,
                      color: AppColors.secondary,
                      tint: AppColors.secondaryFixed,
                      name: setup.teamNames[0],
                      onChanged: (name) => notifier.renameTeam(0, name),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TeamNameCard(
                      label: 'Equipo B',
                      icon: Icons.bubble_chart_rounded,
                      color: AppColors.primary,
                      tint: AppColors.primaryFixed,
                      name: setup.teamNames[1],
                      onChanged: (name) => notifier.renameTeam(1, name),
                    ),
                  ),
                ],
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
              onTap: () => showConfigMessage(
                  context, 'Los mazos personalizados llegan pronto'),
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

/// Tarjeta "Equipo A / Team Vino" con su campo de texto.
///
/// Es `StatefulWidget` porque el `TextEditingController` debe vivir mientras
/// la tarjeta exista (si se creara en `build`, se perdería el cursor en cada
/// tecla).
class _TeamNameCard extends StatefulWidget {
  const _TeamNameCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.tint,
    required this.name,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
  final String name;
  final ValueChanged<String> onChanged;

  @override
  State<_TeamNameCard> createState() => _TeamNameCardState();
}

class _TeamNameCardState extends State<_TeamNameCard> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.name);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: widget.tint.withValues(alpha: 0.5),
        borderRadius: AppRadius.inner,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: widget.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(widget.label,
                    style: textTheme.labelSmall?.copyWith(color: widget.color)),
              ),
              Icon(widget.icon, size: 18, color: widget.color),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            maxLength: 16,
            style: textTheme.labelLarge,
            decoration: const InputDecoration(
              counterText: '',
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              contentPadding:
                  // 13 px arriba/abajo: el campo llega a 48 px de alto.
                  EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: AppRadius.pill,
                borderSide: BorderSide.none,
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
  const _CustomDeckTile({required this.onTap});

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
                    Text('+ Mazo personalizado rápido',
                        style: textTheme.labelLarge),
                    Text('Agrega chistes internos de tus amigos',
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

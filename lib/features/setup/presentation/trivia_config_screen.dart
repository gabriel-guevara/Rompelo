import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/counter_stepper.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/segmented_pills.dart';
import '../../../core/widgets/selection_tile.dart';
import '../../catalog/data/games_catalog.dart';
import '../data/deck_options.dart';
import '../domain/match_setup.dart';
import '../providers/match_setup_provider.dart';
import '../widgets/config_scaffold.dart';
import '../widgets/config_section.dart';
import '../widgets/deck_list.dart';
import '../widgets/game_config_hero.dart';
import 'config_feedback.dart';

/// Configuración de Trivia (`/configurar/trivia`), mockup
/// `design/stitch/config_trivia`.
class TriviaConfigScreen extends ConsumerWidget {
  const TriviaConfigScreen({super.key});

  /// "2 equipos de 3" en modo pulsador; turnos individuales en el otro.
  static String teamsLabel(TriviaSetup setup) {
    final n = setup.players;
    if (setup.answerMode == TriviaAnswerMode.turns) {
      return '$n turnos individuales';
    }
    final half = n ~/ 2;
    return n.isEven ? '2 equipos de $half' : '2 equipos ($half y ${n - half})';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(triviaSetupProvider);
    final notifier = ref.read(triviaSetupProvider.notifier);
    final game = gameById(setup.gameId)!;
    final textTheme = Theme.of(context).textTheme;
    final isBuzzer = setup.answerMode == TriviaAnswerMode.buzzer;

    return ConfigScaffold(
      cta: ChunkyButton(
        label: '¡Calentar pulsadores y jugar!',
        leadingIcon: Icons.play_circle_rounded,
        onPressed: () => context.go(game.playPath),
      ),
      footnote: 'Pasa el teléfono al centro de la mesa al iniciar',
      children: [
        const GameConfigHero(
          title: 'Trivia relámpago',
          description:
              'Preguntas directas al hueso, memes y cultura pop en segundos.',
          tint: AppColors.primaryFixed,
          tags: [
            PillChip(
              label: 'Modo veloz',
              icon: Icons.bolt_rounded,
              iconColor: AppColors.secondary,
              background: AppColors.tertiaryFixed,
              foreground: AppColors.onTertiaryFixedVariant,
            ),
            PillChip(
              label: 'Party casual',
              icon: Icons.local_fire_department_rounded,
              background: AppColors.surfaceContainerLowest,
              foreground: AppColors.primary,
            ),
          ],
          footer: _Recommendation(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Dinámica de respuesta',
              size: SectionHeaderSize.title,
              trailing: Text('Elige cómo tocar', style: textTheme.labelSmall),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Dos SelectionTile funcionan como "radio buttons" grandes.
            SelectionTile(
              title: 'Pulsador en pantalla',
              subtitle: 'El más rápido toca el botón central y responde '
                  'antes de que suene la alarma.',
              icon: Icons.touch_app_rounded,
              badge: 'Caos total',
              badgeColor: AppColors.secondary,
              activeColor: AppColors.primary,
              activeShadow: AppColors.shadowPrimary,
              activeTint: AppColors.primaryFixed,
              selected: isBuzzer,
              onTap: () => notifier.setAnswerMode(TriviaAnswerMode.buzzer),
            ),
            const SizedBox(height: AppSpacing.sm),
            SelectionTile(
              title: 'Por turnos rotativos',
              subtitle: 'Se pasa el teléfono en círculo. Cada persona '
                  'resuelve su propia trivia sin robo de puntos.',
              icon: Icons.autorenew_rounded,
              activeColor: AppColors.primary,
              activeShadow: AppColors.shadowPrimary,
              activeTint: AppColors.primaryFixed,
              selected: !isBuzzer,
              onTap: () => notifier.setAnswerMode(TriviaAnswerMode.turns),
            ),
          ],
        ),
        ConfigSection(
          title: 'Participantes',
          subtitle:
              'Rango ideal: ${setup.minPlayers} a ${setup.maxPlayers} jugadores',
          trailing: CountBadge(
            label: isBuzzer ? 'En grupo' : 'Individual',
            background: AppColors.primaryFixed,
            foreground: AppColors.primary,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadius.pill,
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${setup.players} jugadores',
                          style: AppTheme.withWeight(
                              textTheme.titleMedium!, FontWeight.w800),
                        ),
                        Text(
                          teamsLabel(setup),
                          style: textTheme.labelSmall
                              ?.copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  CounterStepper(
                    value: setup.players,
                    min: setup.minPlayers,
                    max: setup.maxPlayers,
                    accent: AppColors.primary,
                    accentShadow: AppColors.shadowPrimary,
                    onChanged: notifier.setPlayers,
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Packs de preguntas',
              size: SectionHeaderSize.title,
              trailing:
                  CountBadge(label: '${setup.selectedDecks.length} activos'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('Mínimo ${setup.minDecks} seleccionados',
                  style: textTheme.bodySmall),
            ),
            const SizedBox(height: AppSpacing.sm),
            DeckList(
              decks: triviaPacks,
              selected: setup.selectedDecks,
              activeColor: AppColors.primary,
              activeShadow: AppColors.shadowPrimary,
              activeTint: AppColors.primaryFixed,
              onToggle: (id) {
                if (!notifier.toggleDeck(id)) {
                  showConfigMessage(context,
                      'Necesitas al menos ${setup.minDecks} packs activos');
                }
              },
            ),
          ],
        ),
        ConfigSection(
          title: 'Reglas de la ronda',
          trailing: const Icon(Icons.tune_rounded, color: AppColors.secondary),
          children: [
            OptionLabel(
              label: 'Tiempo por pregunta',
              value: '${setup.questionSeconds} segundos',
            ),
            SegmentedPills<int>(
              options: [
                for (final s in TriviaSetup.secondsOptions)
                  SegmentOption(value: s, label: '${s}s'),
              ],
              selected: setup.questionSeconds,
              onChanged: notifier.setQuestionSeconds,
              activeColor: AppColors.primaryContainer,
              activeForeground: AppColors.ink,
              activeShadow: AppColors.shadowSky,
            ),
            const SizedBox(height: AppSpacing.md),
            RuleSwitch(
              title: 'Puntuación doble en la última ronda',
              subtitle: 'Remontadas épicas de último minuto',
              value: setup.doublePointsLastRound,
              onChanged: notifier.setDoublePointsLastRound,
            ),
            const SizedBox(height: AppSpacing.md),
            OptionLabel(
              label: 'Puntos para ganar',
              value: '${setup.targetPoints} pts',
              valueColor: AppColors.primary,
            ),
            SegmentedPills<int>(
              options: [
                for (final p in TriviaSetup.targetOptions)
                  SegmentOption(value: p, label: '$p'),
              ],
              selected: setup.targetPoints,
              onChanged: notifier.setTargetPoints,
              activeColor: AppColors.primaryContainer,
              activeForeground: AppColors.ink,
              activeShadow: AppColors.shadowSky,
            ),
          ],
        ),
      ],
    );
  }
}

/// "● Recomendado para romper el hielo y reír fuerte".
class _Recommendation extends StatelessWidget {
  const _Recommendation();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
              color: AppColors.secondary, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Recomendado para romper el hielo y reír fuerte',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

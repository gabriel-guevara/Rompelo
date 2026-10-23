import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/counter_stepper.dart';
import '../../../core/widgets/pill_chip.dart';
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

/// Configuración del Impostor (`/configurar/impostor`), mockup
/// `design/stitch/config_impostor`.
class ImpostorConfigScreen extends ConsumerWidget {
  const ImpostorConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(impostorSetupProvider);
    final notifier = ref.read(impostorSetupProvider.notifier);
    final game = gameById(setup.gameId)!;

    return ConfigScaffold(
      cta: ChunkyButton(
        label: 'Repartir identidades secretas',
        variant: ChunkyButtonVariant.sky,
        leadingIcon: Icons.key_rounded,
        trailingIcon: Icons.arrow_forward_rounded,
        onPressed: () => context.go(game.playPath),
      ),
      footnote: 'Coloca el teléfono en el centro tras mirar tu rol',
      children: [
        GameConfigHero(
          title: 'El impostor silencioso',
          description: 'Todos conocen la palabra secreta salvo uno. Descubre '
              'al farsante antes de que copie tu pista.',
          tint: AppColors.primaryFixed,
          tags: const [
            PillChip(
              label: 'Misterio & deducción',
              icon: Icons.theater_comedy_rounded,
              background: AppColors.primaryContainer,
              foreground: AppColors.onPrimaryContainer,
            ),
            PillChip(
              label: 'Sala viva',
              icon: Icons.circle,
              iconColor: AppColors.primaryContainer,
              background: AppColors.surfaceContainerLowest,
              foreground: AppColors.primary,
            ),
          ],
          footer: _ReadyAvatars(players: setup.players),
        ),
        ConfigSection(
          title: 'Jugadores en ronda',
          subtitle: 'Pasa el móvil en círculo físico',
          trailing: const Icon(Icons.groups_rounded, color: AppColors.primary),
          children: [
            Center(
              child: CounterStepper(
                value: setup.players,
                min: setup.minPlayers,
                max: setup.maxPlayers,
                accent: AppColors.primary,
                accentShadow: AppColors.shadowPrimary,
                onChanged: notifier.setPlayers,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PlayerNamesEditor(
              names: setup.playerNames,
              onRename: notifier.renamePlayer,
            ),
          ],
        ),
        ConfigSection(
          title: '¿Cuántos impostores?',
          subtitle: 'Intriga simple o conspiración doble',
          trailing: const Icon(Icons.visibility_off_rounded,
              color: AppColors.secondary),
          children: [
            SegmentedPills<int>(
              options: const [
                SegmentOption(
                    value: 1,
                    label: '1 Impostor',
                    icon: Icons.person_search_rounded),
                SegmentOption(
                    value: 2,
                    label: '2 Impostores',
                    icon: Icons.group_remove_rounded),
              ],
              selected: setup.impostors,
              onChanged: (value) {
                if (!notifier.setImpostors(value)) {
                  showConfigMessage(
                    context,
                    '2 impostores desde '
                    '${ImpostorSetup.playersForTwoImpostors} jugadores',
                  );
                }
              },
              activeColor: AppColors.primaryContainer,
              activeForeground: AppColors.ink,
              activeShadow: AppColors.shadowSky,
            ),
          ],
        ),
        ConfigSection(
          title: 'Mazos de palabras',
          subtitle: 'Selecciona uno o combina varios paquetes',
          trailing:
              const Icon(Icons.category_rounded, color: AppColors.primary),
          children: [
            DeckList(
              decks: impostorDecks,
              selected: setup.selectedDecks,
              activeColor: AppColors.primary,
              activeShadow: AppColors.shadowPrimary,
              activeTint: AppColors.primaryFixed,
              onToggle: (id) {
                if (!notifier.toggleDeck(id)) {
                  showConfigMessage(context, 'Deja al menos un mazo activo');
                }
              },
            ),
          ],
        ),
        ConfigSection(
          title: 'Dinámica de pase & debate',
          subtitle: 'Ajustes para tensión máxima',
          trailing: const Icon(Icons.tune_rounded, color: AppColors.primary),
          children: [
            RuleSwitch(
              title: 'Turno a ciegas háptico',
              subtitle:
                  'Pasa el móvil con pantalla en reposo y vibración segura',
              value: setup.blindHapticTurn,
              onChanged: notifier.setBlindHapticTurn,
              accent: AppColors.primaryContainer,
            ),
            const SizedBox(height: AppSpacing.md),
            RuleSwitch(
              title: 'Pista sutil para el impostor',
              subtitle: 'Da una temática general para que no se sienta tan '
                  'perdido',
              value: setup.hintForImpostor,
              onChanged: notifier.setHintForImpostor,
              accent: AppColors.primaryContainer,
            ),
            const SizedBox(height: AppSpacing.md),
            OptionLabel(
              label: 'Tiempo de debate y acusación',
              value: '${setup.debateMinutes} minutos',
              valueColor: AppColors.primary,
            ),
            SegmentedPills<int>(
              options: [
                for (final m in ImpostorSetup.debateOptions)
                  SegmentOption(value: m, label: '$m min'),
              ],
              selected: setup.debateMinutes,
              onChanged: notifier.setDebateMinutes,
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

/// "👑🐱🍕🚀 +4 listos en el sofá": avatares superpuestos de la cabecera.
class _ReadyAvatars extends StatelessWidget {
  const _ReadyAvatars({required this.players});

  final int players;

  static const int _shown = 4;
  static const double _size = 36;
  static const double _overlap = 10;

  @override
  Widget build(BuildContext context) {
    final shown = players < _shown ? players : _shown;
    final rest = players - shown;

    return Row(
      children: [
        SizedBox(
          width: _size + (shown - 1) * (_size - _overlap),
          height: _size,
          child: Stack(
            children: [
              for (var i = 0; i < shown; i++)
                Positioned(
                  left: i * (_size - _overlap),
                  child: Container(
                    width: _size,
                    height: _size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.surfaceContainer, width: 2),
                    ),
                    child: Text(playerEmoji(i),
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
        if (rest > 0) ...[
          const SizedBox(width: AppSpacing.xs),
          Text('+$rest listos en el sofá',
              style: Theme.of(context).textTheme.labelSmall),
        ],
      ],
    );
  }
}

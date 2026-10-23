import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/chunky_card.dart';
import '../../../core/widgets/chunky_pressable.dart';
import '../../../core/widgets/timer_bar.dart';
import '../../setup/data/deck_options.dart';
import '../../setup/domain/match_setup.dart';
import '../../setup/providers/match_setup_provider.dart';
import '../data/mock_game_content.dart';
import '../providers/match_result_provider.dart';
import '../widgets/live_game_scaffold.dart';

/// Impostores de la partida mock: deterministas (desde el final de la mesa)
/// para que los tests sepan a quién votar. Con 2, quedan separados.
Set<int> mockImpostors(int players, int impostors) => {
      for (var i = 0; i < impostors; i++) players - 1 - i * (players ~/ 2),
    };

/// Partida del Impostor (`/partida/impostor`, mockup `partida_impostor`).
///
/// La fase secreta (pasar el móvil para ver la palabra) se da por hecha:
/// esta pantalla es el **debate**. Turnos de pregunta, radar de sospechosos,
/// votación y un botón para volver a ver el rol mientras se mantiene
/// presionado.
class ImpostorPlayScreen extends ConsumerStatefulWidget {
  const ImpostorPlayScreen({super.key});

  @override
  ConsumerState<ImpostorPlayScreen> createState() => _ImpostorPlayScreenState();
}

class _ImpostorPlayScreenState extends ConsumerState<ImpostorPlayScreen> {
  late final ImpostorSetup _setup =
      ref.read(matchSetupProvider('impostor')) as ImpostorSetup;

  /// Tema del primer mazo elegido (en el orden de `deck_options.dart`).
  late final ImpostorTopic _topic = impostorTopicsByDeck[impostorDecks
      .map((deck) => deck.id)
      .firstWhere(_setup.selectedDecks.contains)]!;

  late final String _secretWord = _topic.words.first;
  late final Set<int> _impostors =
      mockImpostors(_setup.players, _setup.impostors);

  /// Arranca en el 2.º jugador, como el mockup ("Turno de Clara").
  int _asker = 1;
  final Set<int> _suspects = {};
  bool _revealing = false;
  bool _debateOver = false;

  List<String> get _names => _setup.playerNames;
  int get _target => (_asker + 1) % _names.length;

  void _nextTurn() => setState(() => _asker = _target);

  void _toggleSuspect(int player) => setState(() {
        if (!_suspects.remove(player)) _suspects.add(player);
      });

  void _onDebateFinished() {
    setState(() => _debateOver = true);
    showGameMessage(context, '¡Tiempo! Hora de votar al impostor');
  }

  Future<void> _vote() async {
    if (_suspects.isEmpty) {
      showGameMessage(context, 'Marca al menos un sospechoso en el radar');
      return;
    }
    // Ganan los ciudadanos si señalaron a todos los impostores.
    final caught = _suspects.containsAll(_impostors);
    final impostorNames = [for (final i in _impostors) _names[i]].join(' y ');

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VerdictDialog(
        caught: caught,
        impostorNames: impostorNames,
        secretWord: _secretWord,
      ),
    );
    if (!mounted) return;

    finishMatch(
      context,
      ref,
      MatchResult(
        gameId: _setup.gameId,
        scores: [
          for (var i = 0; i < _names.length; i++)
            ScoreEntry(
              name: _names[i],
              points:
                  _impostors.contains(i) ? (caught ? 0 : 2) : (caught ? 1 : 0),
            ),
        ],
        summary: caught ? '¡Atraparon al impostor!' : '¡El impostor escapó!',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timersEnabled = ref.watch(liveTimersEnabledProvider);
    final textTheme = Theme.of(context).textTheme;

    return LiveGameScaffold(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _debateOver
                    ? AppColors.outlineVariant
                    : AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                _debateOver ? 'Debate cerrado' : 'Debate en vivo',
                style: textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            CountdownBuilder(
              duration: Duration(minutes: _setup.debateMinutes),
              running: timersEnabled,
              onFinished: _onDebateFinished,
              builder: (context, remaining, _) =>
                  _DebateTimerPill(remaining: remaining, over: _debateOver),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _SecretPhaseCard(
          impostors: _setup.impostors,
          topic: _topic,
        ),
        const SizedBox(height: AppSpacing.md),
        _TurnCard(
          asker: _asker,
          askerName: _names[_asker],
          targetName: _names[_target],
          onNextTurn: _nextTurn,
        ),
        const SizedBox(height: AppSpacing.lg),
        _SuspectsRadar(
          names: _names,
          suspects: _suspects,
          onToggle: _toggleSuspect,
        ),
        const SizedBox(height: AppSpacing.lg),
        ChunkyButton(
          label: 'Votar y delatar al impostor',
          variant: ChunkyButtonVariant.sky,
          leadingIcon: Icons.gavel_rounded,
          onPressed: _vote,
        ),
        const SizedBox(height: AppSpacing.md),
        _RolePeek(
          revealing: _revealing,
          onChanged: (value) => setState(() => _revealing = value),
          playerName: _names[_asker],
          isImpostor: _impostors.contains(_asker),
          secretWord: _secretWord,
          hint: _setup.hintForImpostor ? _topic.impostorHint : null,
        ),
      ],
    );
  }
}

class _DebateTimerPill extends StatelessWidget {
  const _DebateTimerPill({required this.remaining, required this.over});

  final Duration remaining;
  final bool over;

  @override
  Widget build(BuildContext context) {
    final background = over ? AppColors.secondary : AppColors.primaryContainer;
    final foreground =
        over ? AppColors.onSecondary : AppColors.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pill,
        boxShadow:
            chunkyShadow(over ? AppColors.shadowWine : AppColors.shadowSky, 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top_rounded, size: 18, color: foreground),
          const SizedBox(width: 6),
          Text(
            formatCountdown(remaining, padMinutes: true),
            key: const ValueKey('impostor-debate-timer'),
            style: AppTheme.tabular(Theme.of(context).textTheme.labelLarge!)
                .copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

/// "Fase secreta completada" + tema común.
class _SecretPhaseCard extends StatelessWidget {
  const _SecretPhaseCard({required this.impostors, required this.topic});

  final int impostors;
  final ImpostorTopic topic;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = impostors == 1 ? '1 impostor' : '$impostors impostores';

    return ChunkyCard(
      color: AppColors.surfaceContainerLow,
      depth: 4,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: chunkyShadow(AppColors.shadowSky, 2),
                ),
                child: const Icon(Icons.visibility_off_outlined,
                    size: 22, color: AppColors.onPrimaryContainer),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fase secreta completada',
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.primary)),
                    Text(
                      'Todos ya revisaron su tarjeta secreta en privado. '
                      'Hay $count entre nosotros.',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppRadius.inner,
            ),
            child: Row(
              children: [
                Icon(topic.icon, size: 20, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text('Tema común:', style: textTheme.labelSmall),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      topic.topic,
                      style: textTheme.labelMedium
                          ?.copyWith(color: AppColors.onPrimaryContainer),
                      overflow: TextOverflow.ellipsis,
                    ),
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

/// Avatar emoji de un jugador (sustituye las ilustraciones del mockup).
class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.index, this.size = 40});

  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        shape: BoxShape.circle,
        boxShadow: chunkyShadow(AppColors.shadowTactile, 3),
      ),
      child: Text(playerEmoji(index), style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

/// "Ronda de preguntas": quién pregunta y a quién.
class _TurnCard extends StatelessWidget {
  const _TurnCard({
    required this.asker,
    required this.askerName,
    required this.targetName,
    required this.onNextTurn,
  });

  final int asker;
  final String askerName;
  final String targetName;
  final VoidCallback onNextTurn;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChunkyCard(
      depth: 6,
      shadowColor: AppColors.ink.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: AppRadius.pill,
                ),
                child: Text('Ronda de preguntas', style: textTheme.labelSmall),
              ),
              const Spacer(),
              const Icon(Icons.psychology_alt_rounded,
                  size: 20, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('¿Quién empieza la sospecha?', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Haz una pregunta capciosa sobre el tema sin revelar tu palabra '
            'clave.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppRadius.inner,
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _PlayerAvatar(index: asker, size: 56),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_rounded,
                            size: 14, color: AppColors.onSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Turno de $askerName',
                        key: const ValueKey('impostor-turn'),
                        style: textTheme.labelLarge,
                      ),
                      Text.rich(
                        TextSpan(children: [
                          const TextSpan(text: 'pregunta directo a '),
                          TextSpan(
                            text: targetName,
                            style: AppTheme.withWeight(
                                    textTheme.labelMedium!, FontWeight.w700)
                                .copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                              decorationThickness: 2,
                            ),
                          ),
                        ]),
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: ChunkyButton(
              label: 'Siguiente turno',
              variant: ChunkyButtonVariant.ghost,
              trailingIcon: Icons.arrow_forward_rounded,
              height: 44,
              expand: false,
              onPressed: onNextTurn,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Radar de sospechosos": tocar un jugador lo marca o desmarca.
class _SuspectsRadar extends StatelessWidget {
  const _SuspectsRadar({
    required this.names,
    required this.suspects,
    required this.onToggle,
  });

  final List<String> names;
  final Set<int> suspects;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget cell(int i) => i < names.length
        ? _SuspectTile(
            key: ValueKey('suspect-$i'),
            index: i,
            name: names[i],
            marked: suspects.contains(i),
            onTap: () => onToggle(i),
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.fingerprint_rounded,
                size: 22, color: AppColors.secondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Radar de sospechosos',
                  style: textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis),
            ),
            Text('Toca para marcar',
                style: textTheme.labelSmall
                    ?.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Señala en secreto a quién notas nervioso o titubeando:',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        // Grid de 2 columnas armado con filas: vive dentro de un ListView y
        // así no necesita un GridView anidado con `shrinkWrap`.
        for (var i = 0; i < names.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: cell(i)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: cell(i + 1)),
            ],
          ),
        ],
      ],
    );
  }
}

class _SuspectTile extends StatelessWidget {
  const _SuspectTile({
    super.key,
    required this.index,
    required this.name,
    required this.marked,
    required this.onTap,
  });

  final int index;
  final String name;
  final bool marked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ChunkyPressable(
        onTap: onTap,
        selected: marked,
        semanticLabel: name,
        builder: (context, pressed) => AnimatedContainer(
          duration: kChunkyPressDuration,
          padding: const EdgeInsets.all(AppSpacing.sm),
          transform: Matrix4.translationValues(0, pressed ? 4 : 0, 0),
          decoration: BoxDecoration(
            color: marked
                ? AppColors.secondaryFixed
                : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.inner,
            border: Border.all(
              color: marked ? AppColors.secondary : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: chunkyShadow(
                marked ? AppColors.secondaryFixedDim : AppColors.borderSubtle,
                pressed ? 0 : 4),
          ),
          child: Row(
            children: [
              _PlayerAvatar(index: index),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      marked ? 'Sospechoso' : 'Inocente',
                      style: textTheme.labelSmall?.copyWith(
                          color: marked
                              ? AppColors.secondary
                              : AppColors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      marked ? AppColors.secondary : AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  marked
                      ? Icons.priority_high_rounded
                      : Icons.help_outline_rounded,
                  size: 16,
                  color: marked
                      ? AppColors.onSecondary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Mantén presionado para ver tu rol": el rol se ve **solo** mientras el
/// dedo está apoyado, para que nadie más alcance a leerlo. Aparece encima del
/// botón: al final de la lista, debajo quedaría fuera de la pantalla.
///
/// Usa un `Listener` (eventos crudos de puntero) y no un `GestureDetector`:
/// el detector de toques espera a saber si el gesto es un scroll antes de
/// avisar, y aquí queremos mostrar el rol en el instante en que se apoya.
class _RolePeek extends StatelessWidget {
  const _RolePeek({
    required this.revealing,
    required this.onChanged,
    required this.playerName,
    required this.isImpostor,
    required this.secretWord,
    required this.hint,
  });

  final bool revealing;
  final ValueChanged<bool> onChanged;
  final String playerName;
  final bool isImpostor;
  final String secretWord;

  /// Pista para el impostor si el ajuste está activo.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChunkyCard(
      color: AppColors.surfaceContainerHigh,
      borderColor: Colors.transparent,
      shadowColor: AppColors.ink.withValues(alpha: 0.06),
      depth: 3,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          if (revealing) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppRadius.inner,
              ),
              child: Column(
                children: [
                  Text(
                    isImpostor
                        ? 'Rol de $playerName'
                        : 'Palabra secreta de $playerName',
                    style: textTheme.labelSmall
                        ?.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isImpostor ? '🤫 Eres el impostor' : secretWord,
                    key: const ValueKey('impostor-role'),
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                  Text(
                    isImpostor
                        ? (hint == null
                            ? 'Disimula y descubre la palabra'
                            : 'Pista: $hint')
                        : 'Eres un ciudadano auténtico',
                    textAlign: TextAlign.center,
                    style: AppTheme.withWeight(
                            textTheme.bodySmall!, FontWeight.w500)
                        .copyWith(color: AppColors.secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Listener(
            onPointerDown: (_) => onChanged(true),
            onPointerUp: (_) => onChanged(false),
            onPointerCancel: (_) => onChanged(false),
            child: AnimatedContainer(
              key: const ValueKey('impostor-role-peek'),
              duration: kChunkyPressDuration,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              transform: Matrix4.translationValues(0, revealing ? 2 : 0, 0),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: AppRadius.pill,
                boxShadow:
                    chunkyShadow(AppColors.shadowTactile, revealing ? 1 : 3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app_outlined,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Mantén presionado para ver tu rol',
                      style: textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Veredicto de la votación antes de ir al marcador.
class _VerdictDialog extends StatelessWidget {
  const _VerdictDialog({
    required this.caught,
    required this.impostorNames,
    required this.secretWord,
  });

  final bool caught;
  final String impostorNames;
  final String secretWord;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Text(caught ? '🕵️' : '🎭', style: const TextStyle(fontSize: 40)),
      title: Text(
        caught ? '¡Atraparon al impostor!' : '¡El impostor escapó!',
        textAlign: TextAlign.center,
      ),
      content: Text(
        '${impostorNames.contains(' y ') ? 'Los impostores eran' : 'El impostor era'} '
        '$impostorNames. La palabra secreta: $secretWord.',
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      actions: [
        ChunkyButton(
          label: 'Ver resultados',
          leadingIcon: Icons.emoji_events_rounded,
          height: 52,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

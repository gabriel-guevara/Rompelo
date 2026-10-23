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

/// Cartas que actúa cada equipo/jugador por turno en la partida mock (el
/// turno también termina si se acaba el tiempo).
const int kCharadesCardsPerTurn = 3;

/// Partida de Charadas (`/partida/charadas`, mockup `partida_charadas`).
///
/// Es un `ConsumerStatefulWidget`: lee providers con `ref` (como un
/// componente con `useContext`) y guarda el estado **efímero** de la partida
/// (carta, turno, marcador) en su `State` con `setState`. Ese estado no le
/// importa a otra pantalla; solo el resultado final sube a un provider.
class CharadesPlayScreen extends ConsumerStatefulWidget {
  const CharadesPlayScreen({super.key});

  @override
  ConsumerState<CharadesPlayScreen> createState() => _CharadesPlayScreenState();
}

class _CharadesPlayScreenState extends ConsumerState<CharadesPlayScreen> {
  // `ref.read` (no `watch`): la configuración se "congela" al empezar; si
  // cambiara a mitad de partida, el marcador perdería sentido.
  late final CharadesSetup _setup =
      ref.read(matchSetupProvider('charadas')) as CharadesSetup;

  late final List<CharadesCard> _cards = interleaveDecks(
    charadesCardsByDeck,
    charadesDecks.map((deck) => deck.id),
    _setup.selectedDecks,
  );

  /// Equipos (modo equipos) o jugadores (todos vs todos).
  late final List<String> _participants =
      _setup.mode == CharadesMode.teams ? _setup.teamNames : _setup.playerNames;

  late final List<int> _scores = List.filled(_participants.length, 0);

  int _cardIndex = 0;
  int _turn = 0;
  int _cardsThisTurn = 0;
  bool _paused = false;

  int get _totalTurns => _setup.rounds * _participants.length;
  int get _round => _turn ~/ _participants.length + 1;
  int get _current => _turn % _participants.length;
  CharadesCard get _card => _cards[_cardIndex % _cards.length];

  void _correct() {
    setState(() => _scores[_current]++);
    _nextCard();
  }

  void _pass() {
    if (_setup.penaltyOnPass && _scores[_current] > 0) {
      setState(() => _scores[_current]--);
    }
    _nextCard();
  }

  void _nextCard() {
    setState(() {
      _cardIndex++;
      _cardsThisTurn++;
    });
    if (_cardsThisTurn >= kCharadesCardsPerTurn) _endTurn();
  }

  void _endTurn() {
    if (_turn + 1 >= _totalTurns) return _finish();
    setState(() {
      _turn++;
      _cardsThisTurn = 0;
    });
    showGameMessage(context, '¡Turno de ${_participants[_current]}!');
  }

  void _finish() {
    finishMatch(
      context,
      ref,
      MatchResult(
        gameId: _setup.gameId,
        scores: [
          for (var i = 0; i < _participants.length; i++)
            ScoreEntry(name: _participants[i], points: _scores[i]),
        ],
        summary: '¡Se acabaron las rondas!',
      ),
    );
  }

  Future<void> _pause() async {
    setState(() => _paused = true);
    final endTurn = await showDialog<bool>(
      context: context,
      builder: (context) => const _PauseDialog(),
    );
    if (!mounted) return;
    setState(() => _paused = false);
    if (endTurn == true) _endTurn();
  }

  @override
  Widget build(BuildContext context) {
    final timersEnabled = ref.watch(liveTimersEnabledProvider);

    return LiveGameScaffold(
      bottom: Row(
        children: [
          Expanded(
            child: _ActionTile(
              key: const ValueKey('charades-pass'),
              icon: Icons.skip_next_rounded,
              iconColor: AppColors.secondary,
              title: 'Pasar',
              subtitle: _setup.penaltyOnPass ? '-1 punto' : 'Siguiente carta',
              background: AppColors.surfaceContainerHigh,
              foreground: AppColors.onSurface,
              subtitleColor: AppColors.outline,
              shadow: AppColors.ink.withValues(alpha: 0.18),
              onTap: _pass,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _ActionTile(
              key: const ValueKey('charades-correct'),
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.onSecondary,
              title: '¡Acierto!',
              subtitle: '+1 punto',
              background: AppColors.secondary,
              foreground: AppColors.onSecondary,
              subtitleColor: AppColors.secondaryFixed,
              shadow: AppColors.shadowWine,
              depth: 6,
              onTap: _correct,
            ),
          ),
        ],
      ),
      children: [
        _ScoreRibbon(
          round: _round,
          rounds: _setup.rounds,
          participants: _participants,
          scores: _scores,
          current: _current,
          teams: _setup.mode == CharadesMode.teams,
          onPause: _pause,
        ),
        const SizedBox(height: AppSpacing.sm),
        TimerBar(
          // Key nueva por turno = State nuevo = el reloj vuelve a empezar.
          key: ValueKey('charades-timer-$_turn'),
          duration: Duration(seconds: _setup.turnSeconds),
          running: timersEnabled && !_paused,
          onFinished: _endTurn,
        ),
        const SizedBox(height: AppSpacing.md),
        _WordCard(card: _card),
      ],
    );
  }
}

/// Franja "Ronda 2/3 · Vino: 4 vs Burbujas: 3 · pausa".
class _ScoreRibbon extends StatelessWidget {
  const _ScoreRibbon({
    required this.round,
    required this.rounds,
    required this.participants,
    required this.scores,
    required this.current,
    required this.teams,
    required this.onPause,
  });

  final int round;
  final int rounds;
  final List<String> participants;
  final List<int> scores;
  final int current;
  final bool teams;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // En equipos se ven los dos marcadores; en todos vs todos, solo el de
    // quien actúa (con 12 jugadores no cabrían).
    final visible =
        teams ? [for (var i = 0; i < participants.length; i++) i] : [current];

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
      child: Row(
        children: [
          Text(
            'Ronda $round/$rounds',
            key: const ValueKey('charades-round'),
            style: AppTheme.tabular(
                    AppTheme.withWeight(textTheme.labelSmall!, FontWeight.w800))
                .copyWith(color: AppColors.secondary),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: 4,
              children: [
                for (final i in visible) ...[
                  if (i != visible.first)
                    Text('vs',
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.outline)),
                  _ScorePill(
                    key: ValueKey('charades-score-$i'),
                    name: shortTeamName(participants[i]),
                    points: scores[i],
                    color: i.isEven ? AppColors.secondary : AppColors.primary,
                    active: i == current,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          ChunkyPressable(
            onTap: onPause,
            semanticLabel: 'Pausar',
            builder: (context, pressed) => Container(
              width: 32,
              height: 32,
              transform: Matrix4.translationValues(0, pressed ? 2 : 0, 0),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
                boxShadow:
                    chunkyShadow(AppColors.shadowTactile, pressed ? 0 : 2),
              ),
              child: const Icon(Icons.pause_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Team Vino" → "Vino": el mockup muestra el nombre corto en la franja.
String shortTeamName(String name) =>
    name.replaceFirst(RegExp(r'^Team\s+', caseSensitive: false), '');

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    super.key,
    required this.name,
    required this.points,
    required this.color,
    required this.active,
  });

  final String name;
  final int points;
  final Color color;

  /// Quien está actuando se resalta; el rival queda atenuado.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall!;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: active ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: active ? color.withValues(alpha: 0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$name: '),
                  TextSpan(
                    text: '$points',
                    style: AppTheme.tabular(
                            AppTheme.withWeight(style, FontWeight.w800))
                        .copyWith(color: color),
                  ),
                ]),
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carta gigante: categoría, dificultad, icono, palabra e indicación.
class _WordCard extends StatelessWidget {
  const _WordCard({required this.card});

  final CharadesCard card;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChunkyCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 300),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _Tag(
                  icon: Icons.movie_outlined,
                  label: card.category,
                  background: AppColors.primaryFixed,
                  foreground: AppColors.onPrimaryFixed,
                  iconColor: AppColors.primary,
                  style: textTheme.labelMedium!,
                ),
                _Tag(
                  icon: Icons.local_fire_department_outlined,
                  label: '1 punto • ${card.difficulty.label}',
                  background: AppColors.tertiaryFixed,
                  foreground: AppColors.onTertiaryFixedVariant,
                  style: textTheme.labelSmall!,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(card.icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            // AnimatedSwitcher hace un fundido al cambiar de carta (la key
            // con la palabra le indica que el contenido es otro).
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                card.word,
                key: ValueKey(card.word),
                textAlign: TextAlign.center,
                style: textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              card.hint,
              textAlign: TextAlign.center,
              style: AppTheme.withWeight(textTheme.bodyMedium!, FontWeight.w500)
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _GestureHints(),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.style,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color? iconColor;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration:
          BoxDecoration(color: background, borderRadius: AppRadius.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(label,
                style: style.copyWith(color: foreground),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// "Arriba: Pasar | Abajo: Acierto" (decorativo: en esta fase no se usa el
/// giroscopio; los botones de abajo hacen lo mismo).
class _GestureHints extends StatelessWidget {
  const _GestureHints();

  @override
  Widget build(BuildContext context) {
    Widget hint(IconData icon, Color color, String direction, String action) {
      final style = Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: AppColors.onSurfaceVariant);
      return Flexible(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$direction: '),
                  TextSpan(
                    text: action,
                    style: AppTheme.withWeight(style!, FontWeight.w800),
                  ),
                ]),
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          hint(Icons.arrow_upward_rounded, AppColors.secondary, 'Arriba',
              'Pasar'),
          Container(
              width: 1,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: AppColors.surfaceContainerHighest),
          hint(Icons.arrow_downward_rounded, AppColors.primary, 'Abajo',
              'Acierto'),
        ],
      ),
    );
  }
}

/// Botón dividido "Pasar" / "¡Acierto!" (DESIGN.md › Pass-Fail Split Trigger).
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.foreground,
    required this.subtitleColor,
    required this.shadow,
    required this.onTap,
    this.depth = 5,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;
  final Color subtitleColor;
  final Color shadow;
  final double depth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: depth),
      child: ChunkyPressable(
        onTap: onTap,
        semanticLabel: title,
        builder: (context, pressed) => AnimatedContainer(
          duration: kChunkyPressDuration,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(AppSpacing.sm),
          transform: Matrix4.translationValues(0, pressed ? depth - 1 : 0, 0),
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
            boxShadow: chunkyShadow(shadow, pressed ? 1 : depth),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: iconColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(title,
                        style:
                            textTheme.labelLarge?.copyWith(color: foreground),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              Text(subtitle,
                  style: textTheme.labelSmall?.copyWith(color: subtitleColor),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Partida en pausa": el reloj se detiene mientras está abierto.
/// Devuelve `true` si se elige terminar el turno.
class _PauseDialog extends StatelessWidget {
  const _PauseDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.pause_circle_rounded, size: 40),
      title: const Text('Partida en pausa'),
      content: const Text(
        'Tómate un respiro o acomoda el teléfono en la frente para continuar '
        'la diversión.',
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChunkyButton(
              label: 'Reanudar ronda',
              leadingIcon: Icons.play_arrow_rounded,
              height: 52,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: AppSpacing.xs),
            ChunkyButton(
              label: 'Terminar turno',
              height: 44,
              variant: ChunkyButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ],
    );
  }
}

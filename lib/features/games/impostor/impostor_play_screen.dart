import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/feedback/game_feedback.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/plural.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/chunky_card.dart';
import '../../../core/widgets/chunky_pressable.dart';
import '../../../core/widgets/player_avatar.dart';
import '../../../core/widgets/timer_bar.dart';
import '../../setup/data/deck_options.dart';
import '../../setup/domain/match_setup.dart';
import '../../setup/providers/match_setup_provider.dart';
import '../data/mock_game_content.dart';
import '../providers/match_result_provider.dart';
import '../providers/shuffled_deck.dart';
import '../widgets/live_game_scaffold.dart';

/// Puntos por ronda.
const int kCitizenWinPoints = 1;
const int kImpostorEscapePoints = 2;
const int kImpostorGuessPoints = 3;

/// Fases de cada ronda.
enum ImpostorPhase {
  /// Pasar el celular: cada jugador ve su rol en privado.
  deal,

  /// Turnos de preguntas con el reloj del debate.
  debate,

  /// El grupo elige a quién acusa.
  vote,

  /// Resultado de un voto que no cierra la ronda: el acusado era inocente
  /// (queda eliminado) o era uno de varios impostores. Se vuelve a debatir.
  voteResult,

  /// Atraparon al impostor: puede intentar adivinar la palabra.
  lastChance,

  /// Resultado de la ronda y marcador acumulado.
  verdict,
}

/// Partida del Impostor (`/partida/impostor`, mockup `partida_impostor`).
///
/// Cada ronda: palabra e impostor(es) al azar → se pasa el celular para que
/// cada uno vea su rol en secreto → debate por turnos → votación → veredicto.
/// Se juegan las rondas que el grupo quiera; el marcador final suma todas.
///
/// En cada votación se acusa a **una** persona:
/// - Si es inocente, queda eliminada y se sigue debatiendo sin ella.
/// - Si es impostor y ya no queda ninguno, tiene la última oportunidad de
///   adivinar la palabra. Con varios impostores se sigue hasta atraparlos.
/// - Si los impostores que quedan igualan o superan a los ciudadanos que
///   quedan, los impostores escapan y ganan la ronda.
class ImpostorPlayScreen extends ConsumerStatefulWidget {
  const ImpostorPlayScreen({super.key});

  @override
  ConsumerState<ImpostorPlayScreen> createState() => _ImpostorPlayScreenState();
}

class _ImpostorPlayScreenState extends ConsumerState<ImpostorPlayScreen> {
  late final ImpostorSetup _setup =
      ref.read(matchSetupProvider('impostor')) as ImpostorSetup;
  late final Random _random = ref.read(gameRandomProvider);
  late final ShuffledDeck<ImpostorWord> _deck = ref.read(impostorDeckProvider);
  late final GameFeedback _fx = ref.read(gameFeedbackProvider);

  late final List<String> _names = displayPlayerNames(_setup.playerNames);
  int get _players => _names.length;

  // --- Estado acumulado de la partida ---------------------------------------
  late final List<int> _scores = List.filled(_players, 0);
  late final List<int> _escapes = List.filled(_players, 0);
  late final List<int> _citizenWins = List.filled(_players, 0);
  late final List<int> _falseAccusations = List.filled(_players, 0);
  late final List<int> _questionsAsked = List.filled(_players, 0);
  final DateTime _startedAt = DateTime.now();
  int _round = 0;

  // --- Estado de la ronda ---------------------------------------------------
  ImpostorPhase _phase = ImpostorPhase.deal;
  late ImpostorTopic _topic;
  late ImpostorWord _word;
  Set<int> _impostors = {};
  late int _starter;
  int _asker = 0;
  int _dealIndex = 0;
  bool _revealing = false;
  bool _seenRole = false;
  bool _debateOver = false;
  final Set<int> _accused = {};

  /// Inocentes acusados por error: ya no juegan esta ronda.
  final Set<int> _eliminated = {};

  /// Impostores ya descubiertos (con varios, se atrapan de a uno).
  final Set<int> _caughtImpostors = {};

  /// Último acusado (para la tarjeta de [ImpostorPhase.voteResult]).
  int? _lastAccused;

  /// Votaciones hechas en la ronda: reinicia el reloj de cada debate.
  int _votes = 0;
  bool _caught = false;
  bool _guessed = false;
  List<int> _roundPoints = const [];

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  /// Sortea mazo, palabra, impostores y quién empieza. No llama a
  /// `setState`: se usa en `initState` y dentro de [_nextRound].
  void _newRound() {
    final decks = [
      for (final deck in impostorDecks)
        if (_setup.selectedDecks.contains(deck.id)) deck.id,
    ];
    final deckId = decks[_random.nextInt(decks.length)];
    _topic = impostorTopicsByDeck[deckId]!;
    _word = _deck.draw({deckId}, count: 1).single;

    final order = List.generate(_players, (i) => i)..shuffle(_random);
    _impostors = order.take(_setup.impostors).toSet();
    _starter = _random.nextInt(_players);
    _asker = _starter;

    _round++;
    _phase = ImpostorPhase.deal;
    _dealIndex = 0;
    _revealing = false;
    _seenRole = false;
    _debateOver = false;
    _accused.clear();
    _eliminated.clear();
    _caughtImpostors.clear();
    _lastAccused = null;
    _votes = 0;
    _caught = false;
    _guessed = false;
    _roundPoints = List.filled(_players, 0);
  }

  /// Fuera de juego esta ronda (eliminado o impostor ya atrapado).
  bool _isOut(int player) =>
      _eliminated.contains(player) || _caughtImpostors.contains(player);

  int get _impostorsLeft => _impostors.length - _caughtImpostors.length;

  int get _citizensLeft =>
      _players - _impostors.length - _eliminated.length;

  // --- Reparto ---------------------------------------------------------------

  void _setRevealing(bool value) {
    if (value && _setup.blindHapticTurn) _fx.vibrate(Haptic.heavy);
    setState(() {
      _revealing = value;
      if (value) _seenRole = true;
    });
  }

  void _nextDeal() {
    if (!_seenRole) return;
    _fx.sound(GameSound.tap);
    setState(() {
      _revealing = false;
      _seenRole = false;
      if (_dealIndex + 1 < _players) {
        _dealIndex++;
      } else {
        _phase = ImpostorPhase.debate;
        _questionsAsked[_asker]++;
      }
    });
    if (_phase == ImpostorPhase.deal && _setup.blindHapticTurn) {
      // Vibra para avisar que el celular ya puede pasar al siguiente.
      _fx.vibrate(Haptic.medium);
    }
  }

  // --- Debate ----------------------------------------------------------------

  /// Siguiente jugador en la mesa que sigue en juego.
  int _nextActive(int from) {
    var i = from;
    do {
      i = (i + 1) % _players;
    } while (_isOut(i) && i != from);
    return i;
  }

  int get _target => _nextActive(_asker);

  void _nextTurn() => setState(() {
        _asker = _target;
        _questionsAsked[_asker]++;
      });

  void _onDebateFinished() {
    if (!mounted || _phase != ImpostorPhase.debate) return;
    _fx.both(GameSound.timeUp, Haptic.heavy);
    setState(() {
      _debateOver = true;
      _phase = ImpostorPhase.vote;
    });
    showGameMessage(context, '¡Tiempo! Hora de votar al impostor');
  }

  void _goVote() => setState(() => _phase = ImpostorPhase.vote);

  Future<void> _forgotWord() async {
    final player = await showDialog<int>(
      context: context,
      builder: (context) => _PickPlayerDialog(names: _names),
    );
    if (player == null || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _PrivatePeekDialog(
        name: _names[player],
        isImpostor: _impostors.contains(player),
        word: _word.word,
        hint: _setup.hintForImpostor ? _word.hint : null,
        onPeek: () => _fx.vibrate(Haptic.selection),
      ),
    );
  }

  // --- Votación --------------------------------------------------------------

  /// Se acusa a una sola persona por votación: tocar a otra cambia la
  /// acusación. Los que ya están fuera no se pueden acusar.
  void _toggleAccused(int player) {
    if (_isOut(player)) return;
    setState(() {
      if (_accused.remove(player)) return;
      _accused
        ..clear()
        ..add(player);
    });
  }

  void _reveal() {
    if (_accused.isEmpty) {
      showGameMessage(context, 'Elijan a una persona para acusar');
      return;
    }
    _fx.both(GameSound.reveal, Haptic.heavy);
    final accused = _accused.single;
    _accused.clear();
    _votes++;
    _lastAccused = accused;

    if (_impostors.contains(accused)) {
      _caughtImpostors.add(accused);
      if (_impostorsLeft == 0) {
        _caught = true;
        setState(() => _phase = ImpostorPhase.lastChance);
        return;
      }
    } else {
      _eliminated.add(accused);
      _falseAccusations[accused]++;
    }

    // Quedan tantos impostores como ciudadanos: ya no se los puede ganar.
    if (_impostorsLeft >= _citizensLeft) {
      _caught = false;
      _closeRound(guessed: false);
      return;
    }
    setState(() => _phase = ImpostorPhase.voteResult);
  }

  /// Tras un voto que no cierra la ronda: nuevo debate con reloj nuevo,
  /// empezando por el siguiente jugador que sigue en juego.
  void _continueDebate() {
    _fx.sound(GameSound.tap);
    setState(() {
      _debateOver = false;
      if (_isOut(_asker)) _asker = _nextActive(_asker);
      _questionsAsked[_asker]++;
      _phase = ImpostorPhase.debate;
    });
  }

  /// Reparte los puntos de la ronda y pasa al veredicto.
  void _closeRound({required bool guessed}) {
    setState(() {
      _guessed = guessed;
      final impostorsWin = !_caught || guessed;
      for (var i = 0; i < _players; i++) {
        final isImpostor = _impostors.contains(i);
        final points = isImpostor
            ? (!_caught
                ? kImpostorEscapePoints
                : guessed
                    ? kImpostorGuessPoints
                    : 0)
            : (impostorsWin ? 0 : kCitizenWinPoints);
        _roundPoints[i] = points;
        _scores[i] += points;
        if (isImpostor && impostorsWin) _escapes[i]++;
        if (!isImpostor && !impostorsWin) _citizenWins[i]++;
      }
      _phase = ImpostorPhase.verdict;
    });
  }

  void _nextRound() => setState(_newRound);

  // --- Final -----------------------------------------------------------------

  String _namesOf(Iterable<int> indexes) {
    final names = [for (final i in indexes) _names[i]];
    if (names.length <= 1) return names.join();
    return '${names.sublist(0, names.length - 1).join(', ')} y ${names.last}';
  }

  void _finish() {
    final escaped = _escapes.fold(0, (a, b) => a + b);
    final citizens = _citizenWins.fold(0, (a, b) => a + b);
    finishMatch(
      context,
      ref,
      MatchResult(
        gameId: _setup.gameId,
        scores: [
          for (var i = 0; i < _players; i++)
            ScoreEntry(name: _names[i], points: _scores[i]),
        ],
        summary: _round == 1
            ? (_caught && !_guessed
                ? '¡Atraparon al impostor!'
                : '¡El impostor escapó!')
            : escaped > citizens
                ? '¡Noche de farsantes!'
                : '¡Detectives implacables!',
        detail: plural(_round, 'ronda', 'rondas'),
        plays: _round,
        playsLabel: 'Rondas jugadas',
        elapsed: DateTime.now().difference(_startedAt),
        awards: _awards(),
      ),
    );
  }

  List<MatchAward> _awards() {
    final faker = bestIndex(_escapes);
    final detective = bestIndex(_citizenWins);
    final innocent = bestIndex(_falseAccusations);
    final asker = bestIndex(_questionsAsked);
    return [
      if (faker != null)
        MatchAward(
          title: 'El mejor farsante',
          description: 'Impostor que se salió con la suya',
          winner: _names[faker],
          caption: plural(_escapes[faker], 'ronda ganada', 'rondas ganadas'),
          icon: Icons.theater_comedy_rounded,
        ),
      if (detective != null)
        MatchAward(
          title: 'Detective estrella',
          description: 'Más rondas ganadas como ciudadano',
          winner: _names[detective],
          caption: plural(_citizenWins[detective], 'caso resuelto',
              'casos resueltos'),
          icon: Icons.search_rounded,
          tone: AwardTone.warm,
        ),
      if (innocent != null)
        MatchAward(
          title: 'Falsa alarma',
          description: 'Acusado sin tener culpa',
          winner: _names[innocent],
          caption: plural(_falseAccusations[innocent], 'acusación injusta',
              'acusaciones injustas'),
          icon: Icons.priority_high_rounded,
          tone: AwardTone.wine,
        ),
      if (asker != null)
        MatchAward(
          title: 'Interrogador estrella',
          description: 'Quien más preguntó',
          winner: _names[asker],
          caption: plural(_questionsAsked[asker], 'pregunta', 'preguntas'),
          icon: Icons.record_voice_over_rounded,
          tone: AwardTone.warm,
        ),
    ].take(4).toList();
  }

  // --- UI --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final timersEnabled = ref.watch(liveTimersEnabledProvider);
    final impostorText =
        _setup.impostors == 1 ? '1 impostor' : '${_setup.impostors} impostores';

    return LiveGameScaffold(
      bottom: switch (_phase) {
        ImpostorPhase.deal => ChunkyButton(
            key: const ValueKey('impostor-deal-next'),
            label: _dealIndex + 1 < _players
                ? 'Listo, ocultar y pasar'
                : 'Empezar el debate',
            variant: ChunkyButtonVariant.sky,
            leadingIcon: _seenRole
                ? Icons.visibility_off_rounded
                : Icons.touch_app_rounded,
            onPressed: _seenRole ? _nextDeal : null,
          ),
        ImpostorPhase.debate => ChunkyButton(
            key: const ValueKey('impostor-go-vote'),
            label: 'Ir a votar',
            variant: ChunkyButtonVariant.sky,
            leadingIcon: Icons.how_to_vote_rounded,
            onPressed: _goVote,
          ),
        ImpostorPhase.vote => ChunkyButton(
            key: const ValueKey('impostor-reveal'),
            label: 'Revelar al impostor',
            variant: ChunkyButtonVariant.sky,
            leadingIcon: Icons.gavel_rounded,
            onPressed: _reveal,
          ),
        ImpostorPhase.voteResult => ChunkyButton(
            key: const ValueKey('impostor-continue'),
            label: 'Seguir debatiendo',
            variant: ChunkyButtonVariant.sky,
            leadingIcon: Icons.forum_rounded,
            onPressed: _continueDebate,
          ),
        ImpostorPhase.lastChance => null,
        ImpostorPhase.verdict => Row(
            children: [
              Expanded(
                child: ChunkyButton(
                  key: const ValueKey('impostor-finish'),
                  label: 'Ver marcador',
                  variant: ChunkyButtonVariant.ghost,
                  leadingIcon: Icons.emoji_events_rounded,
                  onPressed: _finish,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ChunkyButton(
                  key: const ValueKey('impostor-next-round'),
                  label: 'Otra ronda',
                  variant: ChunkyButtonVariant.sky,
                  leadingIcon: Icons.replay_rounded,
                  onPressed: _nextRound,
                ),
              ),
            ],
          ),
      },
      children: [
        _RoundHeader(
          round: _round,
          label: switch (_phase) {
            ImpostorPhase.deal => 'Reparto secreto',
            ImpostorPhase.debate => 'Debate en vivo',
            ImpostorPhase.vote => 'Votación',
            ImpostorPhase.voteResult => 'Resultado del voto',
            ImpostorPhase.lastChance => 'Última oportunidad',
            ImpostorPhase.verdict => 'Veredicto',
          },
          live: _phase == ImpostorPhase.debate,
          trailing: _phase == ImpostorPhase.debate
              ? CountdownBuilder(
                  // Key nueva por debate (tras cada voto) = reloj desde cero.
                  key: ValueKey('impostor-debate-$_round-$_votes'),
                  duration: Duration(minutes: _setup.debateMinutes),
                  running: timersEnabled,
                  onFinished: _onDebateFinished,
                  builder: (context, remaining, _) => _DebateTimerPill(
                      remaining: remaining, over: _debateOver),
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        ...switch (_phase) {
          ImpostorPhase.deal => [
              _DealCard(
                index: _dealIndex,
                total: _players,
                name: _names[_dealIndex],
                revealing: _revealing,
                seen: _seenRole,
                isImpostor: _impostors.contains(_dealIndex),
                word: _word.word,
                topic: _topic,
                hint: _setup.hintForImpostor ? _word.hint : null,
                onRevealChanged: _setRevealing,
              ),
            ],
          ImpostorPhase.debate => [
              _SecretPhaseCard(impostorText: impostorText, topic: _topic),
              const SizedBox(height: AppSpacing.md),
              _TurnCard(
                asker: _asker,
                askerName: _names[_asker],
                targetName: _names[_target],
                onNextTurn: _nextTurn,
              ),
              const SizedBox(height: AppSpacing.md),
              ChunkyButton(
                key: const ValueKey('impostor-forgot'),
                label: '¿Olvidaste tu palabra?',
                variant: ChunkyButtonVariant.ghost,
                leadingIcon: Icons.lock_outline_rounded,
                height: 48,
                onPressed: _forgotWord,
              ),
            ],
          ImpostorPhase.vote => [
              _SuspectsGrid(
                names: _names,
                accused: _accused,
                eliminated: _eliminated,
                caught: _caughtImpostors,
                impostorsLeft: _impostorsLeft,
                onToggle: _toggleAccused,
              ),
            ],
          ImpostorPhase.voteResult => [
              _VoteResultCard(
                index: _lastAccused!,
                name: _names[_lastAccused!],
                wasImpostor: _impostors.contains(_lastAccused),
                impostorsLeft: _impostorsLeft,
                playersLeft: _citizensLeft + _impostorsLeft,
              ),
            ],
          ImpostorPhase.lastChance => [
              _LastChanceCard(
                impostorNames: _namesOf(_impostors),
                plural: _setup.impostors > 1,
                onAnswer: (guessed) {
                  _fx.both(guessed ? GameSound.pass : GameSound.correct,
                      Haptic.medium);
                  _closeRound(guessed: guessed);
                },
              ),
            ],
          ImpostorPhase.verdict => [
              _VerdictCard(
                impostorsWin: !_caught || _guessed,
                caught: _caught,
                guessed: _guessed,
                impostorNames: _namesOf(_impostors),
                plural: _setup.impostors > 1,
                word: _word.word,
              ),
              const SizedBox(height: AppSpacing.md),
              _Scoreboard(
                names: _names,
                scores: _scores,
                roundPoints: _roundPoints,
                round: _round,
              ),
            ],
        },
      ],
    );
  }
}

/// "Ronda 2 · Debate en vivo" + reloj opcional.
class _RoundHeader extends StatelessWidget {
  const _RoundHeader({
    required this.round,
    required this.label,
    required this.live,
    this.trailing,
  });

  final int round;
  final String label;
  final bool live;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color:
                live ? AppColors.secondaryContainer : AppColors.outlineVariant,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Ronda $round · $label',
            key: const ValueKey('impostor-phase'),
            style: textTheme.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing!,
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

/// Pantalla de "pasar el celular": nombre del jugador y botón para ver el
/// rol **solo** mientras se mantiene presionado.
class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.index,
    required this.total,
    required this.name,
    required this.revealing,
    required this.seen,
    required this.isImpostor,
    required this.word,
    required this.topic,
    required this.hint,
    required this.onRevealChanged,
  });

  final int index;
  final int total;
  final String name;
  final bool revealing;
  final bool seen;
  final bool isImpostor;
  final String word;
  final ImpostorTopic topic;
  final String? hint;
  final ValueChanged<bool> onRevealChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChunkyCard(
      child: Column(
        children: [
          Text('Jugador ${index + 1} de $total',
              style: textTheme.labelSmall
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          _PlayerAvatar(index: index, size: 72),
          const SizedBox(height: AppSpacing.sm),
          Text('Pasa el teléfono a',
              style: textTheme.labelMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
          Text(
            name,
            key: const ValueKey('impostor-deal-name'),
            textAlign: TextAlign.center,
            style: textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          // Zona del rol: altura fija para que nada salte al revelar.
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: revealing
                  ? (isImpostor
                      ? AppColors.secondaryFixed
                      : AppColors.primaryFixed)
                  : AppColors.surfaceContainer,
              borderRadius: AppRadius.inner,
            ),
            child: revealing
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isImpostor ? 'Tu rol' : 'Tema: ${topic.topic}',
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      if (isImpostor)
                        const _ImpostorRoleText(
                            textKey: ValueKey('impostor-role'))
                      else
                        Text(
                          word,
                          key: const ValueKey('impostor-role'),
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        isImpostor
                            ? (hint == null
                                ? 'Tema: ${topic.topic}. Disimula y descubre '
                                    'la palabra'
                                : 'Tema: ${topic.topic} · Pista: $hint')
                            : 'Eres ciudadano: encuentra al impostor',
                        textAlign: TextAlign.center,
                        style: AppTheme.withWeight(
                                textTheme.bodySmall!, FontWeight.w500)
                            .copyWith(color: AppColors.secondary),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.visibility_off_rounded,
                          size: 36, color: AppColors.outline),
                      const SizedBox(height: 4),
                      Text(
                        seen
                            ? 'Listo. Toca el botón de abajo y pasa el '
                                'teléfono.'
                            : 'Solo $name debe mirar la pantalla.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Listener (eventos crudos de puntero): el rol aparece en el
          // instante en que se apoya el dedo y desaparece al soltar.
          Listener(
            onPointerDown: (_) => onRevealChanged(true),
            onPointerUp: (_) => onRevealChanged(false),
            onPointerCancel: (_) => onRevealChanged(false),
            child: AnimatedContainer(
              key: const ValueKey('impostor-role-peek'),
              duration: kChunkyPressDuration,
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              transform: Matrix4.translationValues(0, revealing ? 3 : 0, 0),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.pill,
                boxShadow:
                    chunkyShadow(AppColors.shadowSky, revealing ? 1 : 4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fingerprint_rounded,
                      size: 24, color: AppColors.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Mantén presionado para ver tu rol',
                      style: textTheme.labelLarge
                          ?.copyWith(color: AppColors.onPrimaryContainer),
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

/// "Fase secreta completada" + tema común.
class _SecretPhaseCard extends StatelessWidget {
  const _SecretPhaseCard({required this.impostorText, required this.topic});

  final String impostorText;
  final ImpostorTopic topic;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                      'Todos ya vieron su rol en privado. Hay $impostorText '
                      'entre ustedes.',
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

/// Avatar de un jugador con la sombra "chunky" de las partidas.
class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.index, this.size = 40});

  final int index;
  final double size;

  @override
  Widget build(BuildContext context) =>
      PlayerAvatar(index: index, size: size, elevated: true);
}

/// Icono grande dentro de un círculo de color (veredictos y roles).
class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  static const double size = 72;

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: chunkyShadow(color.withValues(alpha: 0.35), 4),
      ),
      child: Icon(icon, size: size * 0.55, color: color),
    );
  }
}

/// "Eres el impostor" con el antifaz: se usa en el reparto y en el visor.
class _ImpostorRoleText extends StatelessWidget {
  const _ImpostorRoleText({required this.textKey});

  final Key textKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.theater_comedy_rounded,
            size: 30, color: AppColors.secondary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Eres el impostor',
            key: textKey,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
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
            'Haz una pregunta capciosa sobre la palabra sin decirla. El '
            'impostor intentará disimular.',
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

/// Cuadrícula de votación: el grupo marca a quién acusa.
class _SuspectsGrid extends StatelessWidget {
  const _SuspectsGrid({
    required this.names,
    required this.accused,
    required this.eliminated,
    required this.caught,
    required this.impostorsLeft,
    required this.onToggle,
  });

  final List<String> names;
  final Set<int> accused;
  final Set<int> eliminated;
  final Set<int> caught;
  final int impostorsLeft;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget cell(int i) => i < names.length
        ? _SuspectTile(
            key: ValueKey('suspect-$i'),
            index: i,
            name: names[i],
            marked: accused.contains(i),
            status: eliminated.contains(i)
                ? 'Eliminado: era inocente'
                : caught.contains(i)
                    ? 'Atrapado: era impostor'
                    : null,
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
              child: Text('¿A quién acusan?',
                  style: textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis),
            ),
            Text('${accused.length}/1',
                key: const ValueKey('impostor-accused-count'),
                style: AppTheme.tabular(textTheme.labelLarge!)
                    .copyWith(color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Discutan y voten en voz alta. Marquen a la persona más votada: si '
          'es inocente, queda eliminada y siguen jugando.'
          '${impostorsLeft > 1 ? ' Quedan $impostorsLeft impostores.' : ''}',
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
    this.status,
  });

  final int index;
  final String name;
  final bool marked;
  final VoidCallback onTap;

  /// Si no es `null`, el jugador ya está fuera de esta ronda: la tarjeta se
  /// atenúa, muestra el motivo y no se puede acusar.
  final String? status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (status != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Opacity(
          opacity: 0.5,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppRadius.inner,
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
                          style: textTheme.labelMedium?.copyWith(
                              decoration: TextDecoration.lineThrough),
                          overflow: TextOverflow.ellipsis),
                      Text(status!,
                          style: textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.block_rounded,
                    size: 20, color: AppColors.outline),
              ],
            ),
          ),
        ),
      );
    }

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
                      marked ? 'Acusado' : 'Sin votos',
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
                  marked ? Icons.gavel_rounded : Icons.help_outline_rounded,
                  size: 14,
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

/// Resultado de un voto que no termina la ronda.
class _VoteResultCard extends StatelessWidget {
  const _VoteResultCard({
    required this.index,
    required this.name,
    required this.wasImpostor,
    required this.impostorsLeft,
    required this.playersLeft,
  });

  final int index;
  final String name;
  final bool wasImpostor;
  final int impostorsLeft;
  final int playersLeft;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final left = impostorsLeft == 1
        ? 'Aún queda 1 impostor'
        : 'Aún quedan $impostorsLeft impostores';

    return ChunkyCard(
      color: wasImpostor ? AppColors.primaryFixed : AppColors.secondaryFixed,
      child: Column(
        children: [
          _PlayerAvatar(index: index, size: 72),
          const SizedBox(height: AppSpacing.sm),
          Text(
            wasImpostor
                ? '¡$name era impostor!'
                : '$name era inocente',
            key: const ValueKey('impostor-vote-result'),
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            wasImpostor
                ? '$left entre los $playersLeft que siguen. ¡No se confíen!'
                : 'Queda eliminado de esta ronda. $left entre los '
                    '$playersLeft que siguen: debatan otra vez y voten de '
                    'nuevo.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// "¡Lo atraparon! Última oportunidad": el impostor dice la palabra en voz
/// alta y el grupo juzga si acertó.
class _LastChanceCard extends StatelessWidget {
  const _LastChanceCard({
    required this.impostorNames,
    required this.plural,
    required this.onAnswer,
  });

  final String impostorNames;
  final bool plural;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChunkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: _BadgeIcon(
              icon: Icons.search_rounded,
              color: AppColors.primary,
              background: AppColors.primaryFixed,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            plural
                ? '¡Atraparon a los impostores!'
                : '¡Atraparon al impostor!',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$impostorNames ${plural ? 'eran' : 'era'} '
            '${plural ? 'los impostores' : 'el impostor'}. Última '
            'oportunidad: ${plural ? 'pueden' : 'puede'} ganar la ronda si '
            '${plural ? 'adivinan' : 'adivina'} la palabra secreta. '
            '¡Dila en voz alta!',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('¿Adivinó la palabra?',
              textAlign: TextAlign.center, style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ChunkyButton(
                  key: const ValueKey('impostor-guess-no'),
                  label: 'No',
                  variant: ChunkyButtonVariant.ghost,
                  leadingIcon: Icons.close_rounded,
                  onPressed: () => onAnswer(false),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ChunkyButton(
                  key: const ValueKey('impostor-guess-yes'),
                  label: 'Sí, acertó',
                  leadingIcon: Icons.check_rounded,
                  onPressed: () => onAnswer(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Resultado de la ronda.
class _VerdictCard extends StatelessWidget {
  const _VerdictCard({
    required this.impostorsWin,
    required this.caught,
    required this.guessed,
    required this.impostorNames,
    required this.plural,
    required this.word,
  });

  final bool impostorsWin;
  final bool caught;
  final bool guessed;
  final String impostorNames;
  final bool plural;
  final String word;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = !caught
        ? (plural ? '¡Los impostores escaparon!' : '¡El impostor escapó!')
        : guessed
            ? '¡Lo atraparon, pero adivinó!'
            : '¡Ganan los ciudadanos!';

    return ChunkyCard(
      color: impostorsWin ? AppColors.secondaryFixed : AppColors.primaryFixed,
      child: Column(
        children: [
          _BadgeIcon(
            icon: impostorsWin
                ? Icons.theater_comedy_rounded
                : Icons.verified_rounded,
            color: impostorsWin ? AppColors.secondary : AppColors.primary,
            background: AppColors.surfaceContainerLowest,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            key: const ValueKey('impostor-verdict'),
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${plural ? 'Los impostores eran' : 'El impostor era'} '
            '$impostorNames.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.pill,
            ),
            child: Text('Palabra secreta: $word',
                style: textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}

/// Marcador acumulado con los puntos ganados en la ronda.
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({
    required this.names,
    required this.scores,
    required this.roundPoints,
    required this.round,
  });

  final List<String> names;
  final List<int> scores;
  final List<int> roundPoints;
  final int round;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final order = List.generate(names.length, (i) => i)
      ..sort((a, b) => scores[b].compareTo(scores[a]));

    return ChunkyCard(
      depth: 4,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Marcador tras ${plural(round, 'ronda', 'rondas')}',
              style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          for (final i in order)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  _PlayerAvatar(index: i, size: 32),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(names[i],
                        style: textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (roundPoints[i] > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Text('+${roundPoints[i]}',
                          style: textTheme.labelSmall
                              ?.copyWith(color: AppColors.secondary)),
                    ),
                  Text(
                    '${scores[i]}',
                    key: ValueKey('impostor-score-$i'),
                    style: AppTheme.tabular(textTheme.labelLarge!),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// "¿Quién olvidó su palabra?": elige al jugador.
class _PickPlayerDialog extends StatelessWidget {
  const _PickPlayerDialog({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('¿Quién quiere ver su rol?'),
      children: [
        for (var i = 0; i < names.length; i++)
          SimpleDialogOption(
            key: ValueKey('forgot-$i'),
            onPressed: () => Navigator.of(context).pop(i),
            child: Row(
              children: [
                _PlayerAvatar(index: i, size: 32),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(names[i])),
              ],
            ),
          ),
      ],
    );
  }
}

/// Visor privado: el rol se ve solo mientras se mantiene presionado.
class _PrivatePeekDialog extends StatefulWidget {
  const _PrivatePeekDialog({
    required this.name,
    required this.isImpostor,
    required this.word,
    required this.hint,
    required this.onPeek,
  });

  final String name;
  final bool isImpostor;
  final String word;
  final String? hint;

  /// Se llama al apoyar el dedo (vibración según los ajustes).
  final VoidCallback onPeek;

  @override
  State<_PrivatePeekDialog> createState() => _PrivatePeekDialogState();
}

class _PrivatePeekDialogState extends State<_PrivatePeekDialog> {
  bool _revealing = false;

  void _set(bool value) {
    if (value) widget.onPeek();
    setState(() => _revealing = value);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text('Solo ${widget.name}', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 90,
            child: Center(
              child: _revealing
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isImpostor)
                          const _ImpostorRoleText(
                              textKey: ValueKey('impostor-private-role'))
                        else
                          Text(
                            widget.word,
                            key: const ValueKey('impostor-private-role'),
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium,
                          ),
                        if (widget.isImpostor && widget.hint != null)
                          Text('Pista: ${widget.hint}',
                              style: textTheme.bodySmall),
                      ],
                    )
                  : const Icon(Icons.visibility_off_rounded,
                      size: 40, color: AppColors.outline),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Listener(
            onPointerDown: (_) => _set(true),
            onPointerUp: (_) => _set(false),
            onPointerCancel: (_) => _set(false),
            child: Container(
              key: const ValueKey('impostor-private-peek'),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.pill,
              ),
              child: Text('Mantén presionado',
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge
                      ?.copyWith(color: AppColors.onPrimaryContainer)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

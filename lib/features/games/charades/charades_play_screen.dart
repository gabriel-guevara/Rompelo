import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/feedback/game_feedback.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/plural.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/chunky_card.dart';
import '../../../core/widgets/chunky_pressable.dart';
import '../../../core/widgets/timer_bar.dart';
import '../../setup/domain/match_setup.dart';
import '../../setup/providers/match_setup_provider.dart';
import '../data/mock_game_content.dart';
import '../providers/match_result_provider.dart';
import '../providers/shuffled_deck.dart';
import '../widgets/live_game_scaffold.dart';
import 'tilt_detector.dart';

/// Si el filtro de dificultad deja menos cartas que esto, se juega con
/// todas las dificultades (para no repetir cartas en la misma partida).
const int kMinCharadesCards = 10;

/// Frase final del marcador: cambia en cada partida.
const List<String> kCharadesSummaries = [
  'Risas garantizadas',
  '¡Qué nivel de actuación!',
  '¡Dignos de un Óscar!',
  '¡Mímica de otro planeta!',
];

/// Fases de cada turno.
enum CharadesPhase {
  /// "Pasa el teléfono a…": el reloj aún no corre.
  ready,

  /// Cuenta regresiva 3-2-1 para acomodarse el móvil en la frente.
  countdown,

  /// Cartas en juego hasta que se acabe el tiempo.
  playing,

  /// Resumen del turno: cartas acertadas y pasadas.
  summary,
}

/// Una carta jugada en el turno actual.
typedef PlayedCard = ({CharadesCard card, bool correct, int points});

/// Partida de Charadas (`/partida/charadas`, mockup `partida_charadas`).
///
/// Cada turno dura todo el temporizador: el equipo (o jugador) en turno
/// juega tantas cartas como pueda. Acierto y Pasar se marcan con los
/// botones o, si está activo, inclinando el móvil en la frente.
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

  late final ShuffledDeck<CharadesCard> _deck = ref.read(charadesDeckProvider);
  late final GameFeedback _fx = ref.read(gameFeedbackProvider);
  late final List<CharadesCard> _cards = _drawCards();

  /// Equipos (modo equipos) o jugadores (todos vs todos).
  late final List<String> _participants =
      _setup.mode == CharadesMode.teams
          ? displayTeamNames(_setup.teamNames)
          : displayPlayerNames(_setup.playerNames);

  late final List<int> _scores = List.filled(_participants.length, 0);

  // Estadísticas para los "premios de la noche" del marcador.
  late final List<int> _corrects = List.filled(_participants.length, 0);
  late final List<int> _passes = List.filled(_participants.length, 0);
  late final List<int> _hardCorrects = List.filled(_participants.length, 0);
  late final List<int> _bestTurn = List.filled(_participants.length, 0);
  final DateTime _startedAt = DateTime.now();

  final List<PlayedCard> _turnLog = [];
  CharadesPhase _phase = CharadesPhase.ready;
  int _cardIndex = 0;
  int _turn = 0;
  bool _paused = false;

  /// Cambia en cada Acierto/Pasar para disparar el destello de color.
  int _flashId = 0;
  bool _flashCorrect = true;

  int get _totalTurns => _setup.rounds * _participants.length;
  int get _round => _turn ~/ _participants.length + 1;
  int get _current => _turn % _participants.length;
  bool get _isLastTurn => _turn + 1 >= _totalTurns;
  CharadesCard get _card => _cards[_cardIndex];
  int get _turnPoints => _turnLog.fold(0, (sum, c) => sum + c.points);

  @override
  void initState() {
    super.initState();
    // La partida gira sola a horizontal (lo natural con el móvil en la
    // frente). Los dos lados valen; inclinar la pantalla no la da la vuelta.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  bool _isCustom(CharadesCard card) => card.category == 'Mazo personalizado';

  bool _matchesDifficulty(CharadesCard card) =>
      _setup.difficulty == CharadesDifficulty.mixed ||
      _isCustom(card) ||
      card.difficulty.name == _setup.difficulty.name;

  /// Saca todas las cartas de los mazos elegidos (+ las propias), barajadas
  /// y priorizando las que no salieron en la sesión.
  List<CharadesCard> _drawCards() {
    final extra = [
      for (final word in _setup.customWords) customCharadesCard(word),
    ];
    final filtered = _deck.draw(_setup.selectedDecks,
        extra: extra, where: _matchesDifficulty);
    if (filtered.length >= kMinCharadesCards) return filtered;
    return _deck.draw(_setup.selectedDecks, extra: extra);
  }

  // --- Flujo del turno -------------------------------------------------------

  void _startTurn() {
    // En los tests los timers están apagados: se salta el 3-2-1.
    final countdown = ref.read(liveTimersEnabledProvider);
    if (countdown) _fx.sound(GameSound.countdown);
    setState(() {
      _turnLog.clear();
      _phase = countdown ? CharadesPhase.countdown : CharadesPhase.playing;
    });
  }

  void _beginPlaying() {
    if (!mounted || _phase != CharadesPhase.countdown) return;
    _fx.vibrate(Haptic.medium);
    setState(() => _phase = CharadesPhase.playing);
  }

  void _correct() {
    if (_phase != CharadesPhase.playing) return;
    final points = _card.difficulty.points;
    setState(() {
      _scores[_current] += points;
      _corrects[_current]++;
      if (_card.difficulty == CardDifficulty.hard) _hardCorrects[_current]++;
      _turnLog.add((card: _card, correct: true, points: points));
      _flash(correct: true);
    });
    _fx.both(GameSound.correct, Haptic.medium);
    _nextCard();
  }

  void _pass() {
    if (_phase != CharadesPhase.playing) return;
    final penalty = _setup.penaltyOnPass && _scores[_current] > 0 ? 1 : 0;
    setState(() {
      _passes[_current]++;
      _scores[_current] -= penalty;
      _turnLog.add((card: _card, correct: false, points: -penalty));
      _flash(correct: false);
    });
    _fx.both(GameSound.pass, Haptic.light);
    _nextCard();
  }

  void _flash({required bool correct}) {
    _flashId++;
    _flashCorrect = correct;
  }

  void _nextCard() {
    setState(() {
      _cardIndex++;
      // Se acabaron las cartas: el mazo de la sesión rebaraja y sigue.
      if (_cardIndex >= _cards.length) _cards.addAll(_drawCards());
    });
  }

  /// Se acabó el tiempo (o se terminó el turno desde la pausa).
  void _endTurn() {
    if (_phase == CharadesPhase.summary) return;
    if (_phase == CharadesPhase.playing) {
      _fx.both(GameSound.timeUp, Haptic.heavy);
    }
    setState(() {
      _bestTurn[_current] =
          _turnPoints > _bestTurn[_current] ? _turnPoints : _bestTurn[_current];
      _phase = CharadesPhase.summary;
    });
  }

  void _afterSummary() {
    if (_isLastTurn) return _finish();
    setState(() {
      _turn++;
      _phase = CharadesPhase.ready;
    });
  }

  /// El sonido y la vibración de [_correct]/[_pass] confirman el gesto
  /// aunque el jugador no vea la pantalla (está en su frente).
  void _onTilt(bool correct) => correct ? _correct() : _pass();

  // --- Final -----------------------------------------------------------------

  void _finish() {
    final summaryIndex = DateTime.now().millisecond % kCharadesSummaries.length;
    finishMatch(
      context,
      ref,
      MatchResult(
        gameId: _setup.gameId,
        scores: [
          for (var i = 0; i < _participants.length; i++)
            ScoreEntry(name: _participants[i], points: _scores[i]),
        ],
        summary: kCharadesSummaries[summaryIndex],
        detail: plural(_setup.rounds, 'ronda intensa', 'rondas intensas'),
        plays: _corrects.fold(0, (a, b) => a + b) +
            _passes.fold(0, (a, b) => a + b),
        playsLabel: 'Tarjetas jugadas',
        elapsed: DateTime.now().difference(_startedAt),
        awards: _awards(),
      ),
    );
  }

  List<MatchAward> _awards() {
    final ace = bestIndex(_corrects);
    final fixed = [
      if (ace != null)
        MatchAward(
          title: 'Máquina de aciertos',
          description: 'Más cartas adivinadas',
          winner: _participants[ace],
          caption: plural(_corrects[ace], 'acierto', 'aciertos'),
          icon: Icons.bolt_rounded,
          tone: AwardTone.wine,
        ),
    ];

    final star = bestIndex(_bestTurn);
    final hard = bestIndex(_hardCorrects);
    final passer = bestIndex(_passes);
    final extras = [
      if (star != null)
        MatchAward(
          title: 'Turno estrella',
          description: 'Más puntos en un solo turno',
          winner: _participants[star],
          caption: plural(_bestTurn[star], 'punto', 'puntos'),
          icon: Icons.star_rounded,
        ),
      if (hard != null)
        MatchAward(
          title: 'Rey de lo difícil',
          description: 'Más cartas difíciles adivinadas',
          winner: _participants[hard],
          caption: plural(_hardCorrects[hard], 'carta difícil',
              'cartas difíciles'),
          icon: Icons.local_fire_department_rounded,
          tone: AwardTone.warm,
        ),
      if (passer != null)
        MatchAward(
          title: 'Mímica más confusa',
          description: '¿Un perro o una tostadora?',
          winner: _participants[passer],
          caption: plural(_passes[passer], 'carta pasada', 'cartas pasadas'),
          icon: Icons.gesture_rounded,
          tone: AwardTone.warm,
        ),
    ]..shuffle();

    // Máximo 4: el marcador se mantiene corto y cambia en cada partida.
    return [...fixed, ...extras].take(4).toList();
  }

  Future<void> _pause() async {
    setState(() => _paused = true);
    final endTurn = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _PauseDialog(canEndTurn: _phase == CharadesPhase.playing),
    );
    if (!mounted) return;
    setState(() => _paused = false);
    if (endTurn == true) _endTurn();
  }

  // --- UI --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final timersEnabled = ref.watch(liveTimersEnabledProvider);
    final tiltOn = _setup.tiltControls && ref.watch(tiltSensorEnabledProvider);
    final playing = _phase == CharadesPhase.playing;
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    final ribbon = _ScoreRibbon(
      round: _round,
      rounds: _setup.rounds,
      participants: _participants,
      scores: _scores,
      current: _current,
      teams: _setup.mode == CharadesMode.teams,
      onPause: _pause,
    );
    final timer = TimerBar(
      // Key nueva por turno = State nuevo = reloj desde cero.
      key: ValueKey('charades-timer-$_turn'),
      duration: Duration(seconds: _setup.turnSeconds),
      style: landscape ? TimerBarStyle.compact : TimerBarStyle.card,
      running: timersEnabled && !_paused,
      onFinished: _endTurn,
    );

    final readyButton = ChunkyButton(
      key: const ValueKey('charades-ready'),
      label: '¡Estoy listo!',
      leadingIcon: Icons.play_arrow_rounded,
      onPressed: _startTurn,
    );

    return TiltDetector(
      enabled: tiltOn && playing && !_paused,
      onDown: () => _onTilt(true),
      onUp: () => _onTilt(false),
      child: Stack(
        children: [
          if (landscape && playing)
            // Horizontal en juego: todo cabe sin desplazar. Marcador y reloj
            // en una fila, la carta ocupa el resto y los botones van al
            // costado (Pasar arriba / Acierto abajo, como el gesto).
            LiveGameScaffold(
              fill: true,
              maxWidth: 1000,
              children: [
                Row(
                  children: [
                    Expanded(child: ribbon),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: timer),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _WordCard(card: _card, tilt: tiltOn)),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 168,
                        child: _PlayButtons(
                          vertical: true,
                          penaltyOnPass: _setup.penaltyOnPass,
                          points: _card.difficulty.points,
                          onPass: _pass,
                          onCorrect: _correct,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
          LiveGameScaffold(
            maxWidth: landscape ? 900 : AppSpacing.maxContentWidth,
            bottom: switch (_phase) {
              // En horizontal el botón va dentro de la tarjeta.
              CharadesPhase.ready => landscape ? null : readyButton,
              CharadesPhase.countdown => null,
              CharadesPhase.playing => _PlayButtons(
                  penaltyOnPass: _setup.penaltyOnPass,
                  points: _card.difficulty.points,
                  onPass: _pass,
                  onCorrect: _correct,
                ),
              CharadesPhase.summary => ChunkyButton(
                  key: const ValueKey('charades-next-turn'),
                  label: _isLastTurn
                      ? 'Ver resultados'
                      : 'Siguiente: '
                          '${_participants[(_turn + 1) % _participants.length]}',
                  leadingIcon: _isLastTurn
                      ? Icons.emoji_events_rounded
                      : Icons.arrow_forward_rounded,
                  onPressed: _afterSummary,
                ),
            },
            children: [
              ribbon,
              const SizedBox(height: AppSpacing.sm),
              ...switch (_phase) {
                CharadesPhase.ready => [
                    _ReadyCard(
                      name: _participants[_current],
                      round: _round,
                      teams: _setup.mode == CharadesMode.teams,
                      tilt: tiltOn,
                      seconds: _setup.turnSeconds,
                      action: landscape ? readyButton : null,
                    ),
                  ],
                CharadesPhase.countdown => [
                    _CountdownCard(onFinished: _beginPlaying),
                  ],
                CharadesPhase.playing => [
                    timer,
                    const SizedBox(height: AppSpacing.md),
                    _WordCard(card: _card, tilt: tiltOn),
                  ],
                CharadesPhase.summary => [
                    _TurnSummary(
                      name: _participants[_current],
                      log: _turnLog,
                      points: _turnPoints,
                    ),
                  ],
              },
            ],
          ),
          // Destello verde (acierto) o vino (pasar): se ve aunque el móvil
          // esté en la frente y nadie lea el texto.
          if (_flashId > 0)
            IgnorePointer(
              child: TweenAnimationBuilder<double>(
                key: ValueKey('charades-flash-$_flashId'),
                tween: Tween(begin: 0.45, end: 0),
                duration: const Duration(milliseconds: 450),
                builder: (context, opacity, _) => ColoredBox(
                  color: (_flashCorrect
                          ? const Color(0xFF2E9E5B)
                          : AppColors.secondary)
                      .withValues(alpha: opacity),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Pasa el teléfono a…": arranque de cada turno.
class _ReadyCard extends StatelessWidget {
  const _ReadyCard({
    required this.name,
    required this.round,
    required this.teams,
    required this.tilt,
    required this.seconds,
    this.action,
  });

  final String name;
  final int round;
  final bool teams;
  final bool tilt;
  final int seconds;

  /// Botón "¡Estoy listo!" dentro de la tarjeta (solo en horizontal).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final who = [
      Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: AppColors.secondaryFixed,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.theater_comedy_rounded,
            size: 40, color: AppColors.secondary),
      ),
      const SizedBox(height: AppSpacing.md),
      Text('Ronda $round · Pasa el teléfono a',
          textAlign: TextAlign.center,
          style:
              textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 4),
      Text(
        name,
        key: const ValueKey('charades-ready-name'),
        textAlign: TextAlign.center,
        style: textTheme.displaySmall,
      ),
    ];
    final how = [
      Text(
        tilt
            ? 'Ponte el móvil en la frente con la pantalla hacia '
                '${teams ? 'tu equipo' : 'el grupo'}. Ellos actúan o dan '
                'pistas sin decir la palabra.'
            : '${teams ? 'Un jugador del equipo' : 'Tú'} actúa la palabra '
                'sin hablar; ${teams ? 'su equipo' : 'el resto'} '
                'adivina.',
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium,
      ),
      const SizedBox(height: AppSpacing.md),
      if (tilt) const _GestureHints(),
      const SizedBox(height: AppSpacing.sm),
      Text('Tienen $seconds segundos: ¡todas las cartas que puedan!',
          textAlign: TextAlign.center,
          style: textTheme.labelSmall?.copyWith(color: AppColors.secondary)),
    ];

    // Horizontal: quién juega + botón a la izquierda (sin el icono, para que
    // quepa sin desplazar), instrucciones a la derecha.
    if (MediaQuery.orientationOf(context) == Orientation.landscape) {
      return ChunkyCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  ...who.skip(2),
                  if (action != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    action!,
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Column(children: how)),
          ],
        ),
      );
    }

    return ChunkyCard(
      child: Column(
        children: [
          ...who,
          const SizedBox(height: AppSpacing.md),
          ...how,
        ],
      ),
    );
  }
}

/// 3-2-1 grande antes de que corra el reloj.
class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.onFinished});

  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return ChunkyCard(
      child: SizedBox(
        height: landscape ? 180 : 320,
        child: CountdownBuilder(
          duration: const Duration(seconds: 3),
          onFinished: onFinished,
          builder: (context, remaining, _) {
            final n = (remaining.inMilliseconds / 1000).ceil().clamp(1, 3);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¡Prepárense!',
                    style: textTheme.headlineSmall
                        ?.copyWith(color: AppColors.onSurfaceVariant)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    '$n',
                    key: ValueKey(n),
                    style: textTheme.displayLarge?.copyWith(
                        fontSize: landscape ? 88 : 120,
                        color: AppColors.secondary),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Cartas del turno (acertadas y pasadas) con los puntos ganados.
class _TurnSummary extends StatelessWidget {
  const _TurnSummary({
    required this.name,
    required this.log,
    required this.points,
  });

  final String name;
  final List<PlayedCard> log;
  final int points;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hits = log.where((c) => c.correct).length;

    Widget row(PlayedCard played) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            children: [
              Icon(
                played.correct
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: played.correct
                    ? const Color(0xFF2E9E5B)
                    : AppColors.outline,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  played.card.word,
                  style: textTheme.bodyLarge?.copyWith(
                    decoration:
                        played.correct ? null : TextDecoration.lineThrough,
                    color: played.correct
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                played.points > 0 ? '+${played.points}' : '${played.points}',
                style: AppTheme.tabular(textTheme.labelLarge!),
              ),
            ],
          ),
        );

    // Horizontal: la lista se reparte en dos columnas para no desplazar tanto.
    final twoColumns =
        MediaQuery.orientationOf(context) == Orientation.landscape &&
            log.length > 1;
    final half = (log.length + 1) ~/ 2;

    return ChunkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('¡Tiempo!',
              textAlign: TextAlign.center, style: textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(
            '$name: ${plural(hits, 'acierto', 'aciertos')} · '
            '${points >= 0 ? '+' : ''}${plural(points, 'punto', 'puntos')}',
            key: const ValueKey('charades-turn-summary'),
            textAlign: TextAlign.center,
            style: textTheme.labelLarge?.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: AppSpacing.md),
          if (log.isEmpty)
            Text('No se jugó ninguna carta en este turno.',
                textAlign: TextAlign.center, style: textTheme.bodyMedium)
          else if (twoColumns)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                        children: [for (final p in log.take(half)) row(p)])),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                    child: Column(
                        children: [for (final p in log.skip(half)) row(p)])),
              ],
            )
          else
            for (final played in log) row(played),
        ],
      ),
    );
  }
}

/// Botones "Pasar" / "¡Acierto!" fijos en la zona del pulgar.
class _PlayButtons extends StatelessWidget {
  const _PlayButtons({
    required this.penaltyOnPass,
    required this.points,
    required this.onPass,
    required this.onCorrect,
    this.vertical = false,
  });

  final bool penaltyOnPass;
  final int points;
  final VoidCallback onPass;
  final VoidCallback onCorrect;

  /// Apilados (Pasar arriba, Acierto abajo) llenando el alto: columna
  /// lateral de Charadas en horizontal.
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: vertical ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment:
          vertical ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _ActionTile(
            key: const ValueKey('charades-pass'),
            icon: Icons.skip_next_rounded,
            iconColor: AppColors.secondary,
            title: 'Pasar',
            subtitle: penaltyOnPass ? '-1 punto' : 'Siguiente carta',
            background: AppColors.surfaceContainerHigh,
            foreground: AppColors.onSurface,
            subtitleColor: AppColors.outline,
            shadow: AppColors.ink.withValues(alpha: 0.18),
            onTap: onPass,
          ),
        ),
        const SizedBox(width: AppSpacing.sm, height: AppSpacing.sm),
        Expanded(
          child: _ActionTile(
            key: const ValueKey('charades-correct'),
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.onSecondary,
            title: '¡Acierto!',
            subtitle: '+${plural(points, 'punto', 'puntos')}',
            background: AppColors.secondary,
            foreground: AppColors.onSecondary,
            subtitleColor: AppColors.secondaryFixed,
            shadow: AppColors.shadowWine,
            depth: 6,
            onTap: onCorrect,
          ),
        ),
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

    // En horizontal cada píxel de alto cuenta: franja más baja.
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: landscape ? 2 : AppSpacing.sm),
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
  const _WordCard({required this.card, required this.tilt});

  final CharadesCard card;

  /// Muestra la guía de inclinación debajo de la palabra.
  final bool tilt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // En horizontal la carta llena el alto que le dan (sin desplazar): la
    // palabra crece todo lo posible para leerse desde lejos y se encoge
    // sola si es larga o la pantalla es baja.
    if (MediaQuery.orientationOf(context) == Orientation.landscape) {
      return ChunkyCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(card.icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    '${card.category} · '
                    '${plural(card.difficulty.points, 'punto', 'puntos')}'
                    ' • ${card.difficulty.label}',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Center(
                  key: ValueKey('charades-word-${card.word}'),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      card.word,
                      textAlign: TextAlign.center,
                      style: textTheme.displayLarge?.copyWith(fontSize: 96),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              card.hint,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.withWeight(textTheme.bodyMedium!, FontWeight.w500)
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

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
                  label: '${plural(card.difficulty.points, 'punto', 'puntos')}'
                      ' • ${card.difficulty.label}',
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
                key: ValueKey('charades-word-${card.word}'),
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
            if (tilt) ...[
              const SizedBox(height: AppSpacing.lg),
              const _GestureHints(),
            ],
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

/// "Abajo: Acierto | Arriba: Pasar" (con el móvil en la frente).
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
          hint(Icons.arrow_downward_rounded, AppColors.primary, 'Abajo',
              'Acierto'),
          Container(
              width: 1,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: AppColors.surfaceContainerHighest),
          hint(Icons.arrow_upward_rounded, AppColors.secondary, 'Arriba',
              'Pasar'),
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
            // Centrado cuando el botón ocupa un alto fijo (columna lateral).
            mainAxisAlignment: MainAxisAlignment.center,
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
  const _PauseDialog({required this.canEndTurn});

  final bool canEndTurn;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // En horizontal la altura no alcanza: el diálogo desplaza.
      scrollable: true,
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
              label: 'Reanudar',
              leadingIcon: Icons.play_arrow_rounded,
              height: 52,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            if (canEndTurn) ...[
              const SizedBox(height: AppSpacing.xs),
              ChunkyButton(
                label: 'Terminar turno',
                height: 44,
                variant: ChunkyButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

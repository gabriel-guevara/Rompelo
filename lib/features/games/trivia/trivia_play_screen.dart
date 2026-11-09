import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:math';
import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
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
import '../widgets/live_game_scaffold.dart';
import '../providers/trivia_deck_provider.dart';

/// Preguntas de la partida mock (el contador "7 / 12" del mockup).
const int kTriviaQuestions = 12;
const int kTriviaPoints = 50;

/// Penalización por robar turno y fallar ("-20 pts si fallas").
const int kStealPenalty = 20;

/// Equipos del modo "Pulsador en pantalla" (en grupo).
const List<String> kTriviaTeams = ['Team Vino', 'Team Burbujas'];
/// Frase final del marcador: cambia en cada partida.
const List<String> kTriviaSummaries = [
  '¡Cerebros en llamas!',
  '¡Qué nivel de cultura general!',
  '¡Neuronas a toda máquina!',
  '¡Sabiduría en estado puro!',
];

/// Partida de Trivia (`/partida/trivia`, mockup `partida_trivia`).
///
/// Flujo mock de cada pregunta: tocar una opción la **resalta**;
/// "Confirmar respuesta" revela la correcta y suma puntos a quien responde;
/// "Siguiente pregunta" avanza. "¡Robar turno!" pasa la respuesta al rival
/// (una vez por pregunta) con riesgo de perder puntos.
class TriviaPlayScreen extends ConsumerStatefulWidget {
  const TriviaPlayScreen({super.key});

  @override
  ConsumerState<TriviaPlayScreen> createState() => _TriviaPlayScreenState();
}

class _TriviaPlayScreenState extends ConsumerState<TriviaPlayScreen> {
  late final TriviaSetup _setup =
      ref.read(matchSetupProvider('trivia')) as TriviaSetup;

  late final List<TriviaQuestion> _questions = ref
      .read(triviaDeckProvider)
      .draw(_setup.selectedDecks, kTriviaQuestions);

  late final bool _teams = _setup.answerMode == TriviaAnswerMode.buzzer;

  /// En grupo: 2 equipos. Por turnos: cada jugador suma para sí.
  late final List<String> _participants =
      _teams ? kTriviaTeams : _setup.playerNames;

  late final List<int> _scores = List.filled(_participants.length, 0);

  // Estadísticas para los "premios de la noche" del marcador.
  late final List<int> _corrects = List.filled(_participants.length, 0);
  late final List<int> _steals = List.filled(_participants.length, 0);
  late final List<int> _stealTries = List.filled(_participants.length, 0);
  late final List<int> _streak = List.filled(_participants.length, 0);
  late final List<int> _bestStreak = List.filled(_participants.length, 0);

  /// Mayor desventaja que tuvo cada uno frente al líder (para "Remontada").
  late final List<int> _maxDeficit = List.filled(_participants.length, 0);

  /// Respuesta correcta más rápida de cada uno.
  late final List<Duration?> _fastest =
      List<Duration?>.filled(_participants.length, null);

  /// Aciertos por categoría de cada participante.
  late final List<Map<String, int>> _byCategory = [
    for (var i = 0; i < _participants.length; i++) <String, int>{},
  ];

  final Stopwatch _questionClock = Stopwatch()..start();
  final DateTime _startedAt = DateTime.now();

  int _index = 0;
  int _answering = 0;
  int? _selected;
  bool _revealed = false;
  bool _stolen = false;

  TriviaQuestion get _question => _questions[_index % _questions.length];
  bool get _isLast => _index == kTriviaQuestions - 1;
  int get _points => _isLast && _setup.doublePointsLastRound
      ? kTriviaPoints * 2
      : kTriviaPoints;

  void _select(int option) {
    if (_revealed) return;
    setState(() => _selected = option);
  }

  void _confirm() {
    if (_selected == null || _revealed) return;
    final correct = _selected == _question.correctIndex;
    final who = _answering;
    final elapsed = _questionClock.elapsed;

    setState(() {
      _revealed = true;
      if (correct) {
        _scores[who] += _points;
        _corrects[who]++;
        if (_stolen) _steals[who]++;
        _streak[who]++;
        _bestStreak[who] = max(_bestStreak[who], _streak[who]);
        final fastest = _fastest[who];
        if (fastest == null || elapsed < fastest) _fastest[who] = elapsed;
        final category = _question.category;
        _byCategory[who][category] = (_byCategory[who][category] ?? 0) + 1;
      } else {
        _streak[who] = 0;
        if (_stolen) _scores[who] -= kStealPenalty;
      }
      _trackDeficits();
    });

    final name = _participants[who];
    showGameMessage(
      context,
      correct
          ? _streak[who] >= 3
              ? '¡Racha de ${_streak[who]}! $name sumó +$_points puntos'
              : '¡Respuesta correcta! $name sumó +$_points puntos'
          : _stolen
              ? 'Robo fallido: $name pierde $kStealPenalty puntos'
              : 'Casi… la respuesta era ${_question.options[_question.correctIndex]}',
    );
  }

  void _steal() {
    if (_stolen || _revealed) return;
    setState(() {
      _stolen = true;
      _answering = (_answering + 1) % _participants.length;
      _stealTries[_answering]++;
    });
    showGameMessage(context, '¡${_participants[_answering]} roba el turno!');
  }

  /// Se acabó el tiempo: se revela sin sumar puntos y se corta la racha.
  void _timeUp() {
    if (_revealed) return;
    setState(() {
      _revealed = true;
      _streak[_answering] = 0;
    });
    showGameMessage(context, '¡Tiempo! Nadie suma en esta pregunta');
  }

  void _next() {
    final reachedTarget = _scores.any((s) => s >= _setup.targetPoints);
    if (_index + 1 >= kTriviaQuestions || reachedTarget) return _finish();
    setState(() {
      _index++;
      // Por turnos rotativos: cada pregunta le toca a alguien distinto.
      _answering = _index % _participants.length;
      _selected = null;
      _revealed = false;
      _stolen = false;
      _questionClock.reset();
    });
  }

  /// Guarda cuánto llegó a ir perdiendo cada uno frente al líder.
  void _trackDeficits() {
    final leader = _scores.reduce(max);
    for (var i = 0; i < _scores.length; i++) {
      _maxDeficit[i] = max(_maxDeficit[i], leader - _scores[i]);
    }
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
        summary: kTriviaSummaries[Random().nextInt(kTriviaSummaries.length)],
        detail: plural(_index + 1, 'pregunta', 'preguntas'),
        plays: _index + 1,
        playsLabel: 'Preguntas jugadas',
        elapsed: DateTime.now().difference(_startedAt),
        awards: _awards(),
      ),
    );
  }

  // --- Premios de la noche ---------------------------------------------------

  /// Índices empatados en el valor más alto; vacío si no llega a [atLeast].
  List<int> _leaders(List<int> values, {int atLeast = 1}) {
    final top = values.fold<int>(0, max);
    if (top < atLeast) return const [];
    return [
      for (var i = 0; i < values.length; i++)
        if (values[i] == top) i,
    ];
  }

  /// "Ana", "Ana y Lucas" o "Ana, Lucas y Sofi".
  String _namesAt(List<int> indexes) {
    final names = [for (final i in indexes) _participants[i]];
    if (names.length == 1) return names.first;
    return '${names.sublist(0, names.length - 1).join(', ')} y ${names.last}';
  }

  List<MatchAward> _awards() {
    // Fijos: siempre arriba si aplican.
    final fixed = <MatchAward>[];
    final brains = _leaders(_corrects);
    if (brains.isNotEmpty) {
      fixed.add(MatchAward(
        title: brains.length > 1 ? 'Cerebros empatados' : 'Cerebro de la noche',
        description: 'Más respuestas correctas',
        winner: _namesAt(brains),
        caption: plural(_corrects[brains.first], 'acierto', 'aciertos'),
        icon: Icons.psychology_rounded,
      ));
    }
    final comeback = _comebackAward();
    if (comeback != null) fixed.add(comeback);

    // Variables: se barajan para que cada partida muestre premios distintos.
    final extras = <MatchAward>[];
    final streakers = _leaders(_bestStreak, atLeast: 3);
    if (streakers.isNotEmpty) {
      extras.add(MatchAward(
        title: 'Racha imparable',
        description: 'Más aciertos seguidos',
        winner: _namesAt(streakers),
        caption: '${_bestStreak[streakers.first]} seguidas',
        icon: Icons.local_fire_department_rounded,
        tone: AwardTone.warm,
      ));
    }
    final fastest = _fastestAward();
    if (fastest != null) extras.add(fastest);
    final expert = _expertAward();
    if (expert != null) extras.add(expert);

    final thieves = _leaders(_steals);
    final brave = _leaders(_stealTries);
    if (thieves.isNotEmpty) {
      extras.add(MatchAward(
        title: 'Ladrón de turnos',
        description: 'Robos que salieron bien',
        winner: _namesAt(thieves),
        caption: plural(_steals[thieves.first], 'robo', 'robos'),
        icon: Icons.bolt_rounded,
        tone: AwardTone.wine,
      ));
    } else if (brave.isNotEmpty) {
      extras.add(MatchAward(
        title: 'Corazón valiente',
        description: 'Se atrevió a robar aunque fallara',
        winner: _namesAt(brave),
        caption: plural(_stealTries[brave.first], 'intento', 'intentos'),
        icon: Icons.favorite_rounded,
        tone: AwardTone.wine,
      ));
    }
    extras.shuffle();

    // Máximo 4: el marcador se mantiene corto y sorprende en cada partida.
    return [...fixed, ...extras].take(4).toList();
  }

  MatchAward? _comebackAward() {
    final winners = _leaders(_scores);
    if (winners.length != 1) return null;
    final w = winners.first;
    if (_maxDeficit[w] < kTriviaPoints * 2) return null;
    return MatchAward(
      title: 'Remontada épica',
      description: 'Ganó después de ir perdiendo',
      winner: _participants[w],
      caption: 'Iba ${_maxDeficit[w]} pts abajo',
      icon: Icons.trending_up_rounded,
      tone: AwardTone.wine,
    );
  }

  MatchAward? _fastestAward() {
    int? best;
    for (var i = 0; i < _fastest.length; i++) {
      final time = _fastest[i];
      if (time != null && (best == null || time < _fastest[best]!)) best = i;
    }
    if (best == null) return null;
    final seconds = (_fastest[best]!.inMilliseconds / 1000)
        .toStringAsFixed(1)
        .replaceAll('.', ',');
    return MatchAward(
      title: 'Rayo veloz',
      description: 'La respuesta correcta más rápida',
      winner: _participants[best],
      caption: 'En $seconds s',
      icon: Icons.flash_on_rounded,
    );
  }

  MatchAward? _expertAward() {
    var bestCount = 1; // pide al menos 2 aciertos en la misma categoría
    int? who;
    var category = '';
    for (var i = 0; i < _byCategory.length; i++) {
      for (final MapEntry(key: cat, value: count) in _byCategory[i].entries) {
        if (count > bestCount) {
          bestCount = count;
          who = i;
          category = cat;
        }
      }
    }
    if (who == null) return null;
    return MatchAward(
      title: 'Especialista',
      description: 'Dominó $category',
      winner: _participants[who],
      caption: plural(bestCount, 'acierto', 'aciertos'),
      icon: Icons.school_rounded,
      tone: AwardTone.warm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timersEnabled = ref.watch(liveTimersEnabledProvider);
    final question = _question;

    return LiveGameScaffold(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selected != null || _revealed) ...[
            ChunkyButton(
              label: _revealed ? 'Siguiente pregunta' : 'Confirmar respuesta',
              variant: ChunkyButtonVariant.sky,
              trailingIcon:
                  _revealed ? Icons.arrow_forward_rounded : Icons.check_rounded,
              onPressed: _revealed ? _next : _confirm,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _StealButton(onPressed: _stolen || _revealed ? null : _steal),
        ],
      ),
      children: [
        _Scoreboard(
          participants: _participants,
          scores: _scores,
          answering: _answering,
          teams: _teams,
          counter: '${_index + 1} / $kTriviaQuestions',
        ),
        const SizedBox(height: AppSpacing.sm),
        TimerBar(
          key: ValueKey('trivia-timer-$_index'),
          duration: Duration(seconds: _setup.questionSeconds),
          style: TimerBarStyle.compact,
          running: timersEnabled && !_revealed,
          onFinished: _timeUp,
        ),
        const SizedBox(height: AppSpacing.md),
        _QuestionCard(
          question: question,
          points: _points,
          footer: _teams
              ? '¡El que responde primero suma!'
              : 'Responde ${_participants[_answering]}',
        ),
        const SizedBox(height: AppSpacing.xs),
        _OptionsGrid(
          options: question.options,
          selected: _selected,
          correct: _revealed ? question.correctIndex : null,
          onSelect: _select,
        ),
      ],
    );
  }
}

/// Marcador "Team Vino 280 · 7 / 12 · Team Burbujas 310".
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({
    required this.participants,
    required this.scores,
    required this.answering,
    required this.teams,
    required this.counter,
  });

  final List<String> participants;
  final List<int> scores;
  final int answering;
  final bool teams;
  final String counter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // En equipos se ven ambos fijos; por turnos, quien responde y quien
    // sigue (con muchos jugadores no cabrían todos).
    final left = teams ? 0 : answering;
    final right = teams ? 1 : (answering + 1) % participants.length;

    return Row(
      children: [
        Expanded(
          child: _TeamScore(
            key: const ValueKey('trivia-score-left'),
            name: participants[left],
            points: scores[left],
            wine: true,
            active: answering == left,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: AppRadius.pill,
            boxShadow: chunkyShadow(AppColors.surfaceDim, 2),
          ),
          child: Text(
            counter,
            key: const ValueKey('trivia-counter'),
            style: AppTheme.tabular(
                    AppTheme.withWeight(textTheme.labelSmall!, FontWeight.w700))
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _TeamScore(
            key: const ValueKey('trivia-score-right'),
            name: participants[right],
            points: scores[right],
            wine: false,
            active: answering == right,
          ),
        ),
      ],
    );
  }
}

class _TeamScore extends StatelessWidget {
  const _TeamScore({
    super.key,
    required this.name,
    required this.points,
    required this.wine,
    required this.active,
  });

  final String name;
  final int points;

  /// Vino a la izquierda, azul a la derecha (como el mockup).
  final bool wine;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = wine ? AppColors.secondary : AppColors.primary;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: active ? 1 : 0.6,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: wine ? AppColors.secondaryFixed : AppColors.primaryFixed,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
          boxShadow: chunkyShadow(
              wine ? AppColors.secondaryFixedDim : AppColors.primaryFixedDim,
              3),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                name,
                style: textTheme.labelSmall?.copyWith(
                    color: wine
                        ? AppColors.onSecondaryFixed
                        : AppColors.onPrimaryFixed),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$points',
              style: AppTheme.tabular(AppTheme.withWeight(
                      textTheme.headlineSmall!, FontWeight.w800))
                  .copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carta de la pregunta en tono leche.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.points,
    required this.footer,
  });

  final TriviaQuestion question;
  final int points;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChunkyCard(
      color: AppColors.milk,
      shadowColor: AppColors.shadowTactile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixedDim,
                    borderRadius: AppRadius.pill,
                    boxShadow: chunkyShadow(AppColors.primaryContainer, 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_outlined,
                          size: 16, color: AppColors.onPrimaryFixed),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          question.category,
                          style: AppTheme.withWeight(
                                  textTheme.labelSmall!, FontWeight.w700)
                              .copyWith(color: AppColors.onPrimaryFixed),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.bolt_rounded,
                  size: 18, color: AppColors.secondary),
              Text(
                '+$points pts',
                key: const ValueKey('trivia-points'),
                style:
                    AppTheme.withWeight(textTheme.labelSmall!, FontWeight.w700)
                        .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            question.question,
            style:
                AppTheme.withWeight(textTheme.headlineSmall!, FontWeight.w800)
                    .copyWith(height: 1.35),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.campaign_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  footer,
                  style: textTheme.labelSmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDim.withValues(alpha: 0.4),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  question.tag,
                  style: AppTheme.withWeight(
                          textTheme.labelSmall!, FontWeight.w700)
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Grid 2 × 2 de opciones A–D (pulsadores de arcade).
class _OptionsGrid extends StatelessWidget {
  const _OptionsGrid({
    required this.options,
    required this.selected,
    required this.correct,
    required this.onSelect,
  });

  final List<String> options;
  final int? selected;

  /// Índice correcto una vez revelada la respuesta; `null` antes.
  final int? correct;
  final ValueChanged<int> onSelect;

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    Widget option(int i) => _OptionButton(
          key: ValueKey('trivia-option-$i'),
          letter: _letters[i],
          text: options[i],
          state: _stateFor(i),
          onTap: correct == null ? () => onSelect(i) : null,
        );

    // Dos filas con `IntrinsicHeight` en vez de `GridView`: las celdas de
    // una fila miden lo mismo aunque una respuesta ocupe dos líneas.
    Widget row(int a, int b) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: option(a)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: option(b)),
            ],
          ),
        );

    return Column(
      children: [
        row(0, 1),
        if (options.length > 2) ...[
          const SizedBox(height: AppSpacing.sm),
          row(2, 3),
        ],
      ],
    );
  }

  _OptionState _stateFor(int i) {
    if (correct != null) {
      if (i == correct) return _OptionState.correct;
      if (i == selected) return _OptionState.wrong;
      return _OptionState.idle;
    }
    return i == selected ? _OptionState.selected : _OptionState.idle;
  }
}

/// Estados visuales de una opción. Un enum con los colores evita un
/// `if/else` de estilos repartido por el `build`.
enum _OptionState {
  idle(AppColors.surfaceContainerLowest, AppColors.onSurface,
      AppColors.shadowTactile, null),
  selected(AppColors.primaryFixed, AppColors.onPrimaryFixed,
      AppColors.shadowSky, Icons.stars_rounded),
  correct(AppColors.primaryContainer, AppColors.onPrimaryFixed,
      AppColors.shadowSky, Icons.check_circle_rounded),
  wrong(AppColors.secondaryFixed, AppColors.onSecondaryFixed,
      AppColors.secondaryFixedDim, Icons.cancel_rounded);

  const _OptionState(this.background, this.foreground, this.shadow, this.icon);

  final Color background;
  final Color foreground;
  final Color shadow;
  final IconData? icon;
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final highlighted = state != _OptionState.idle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: ChunkyPressable(
        onTap: onTap,
        selected: state == _OptionState.selected,
        semanticLabel: '$letter: $text',
        builder: (context, pressed) => AnimatedContainer(
          duration: kChunkyPressDuration,
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(AppSpacing.md),
          transform: Matrix4.translationValues(0, pressed ? 4 : 0, 0),
          decoration: BoxDecoration(
            color: state.background,
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
            boxShadow: chunkyShadow(state.shadow, pressed ? 1 : 5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: highlighted
                          ? AppColors.surfaceContainerLowest
                          : AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      letter,
                      style: AppTheme.withWeight(
                              textTheme.labelMedium!, FontWeight.w800)
                          .copyWith(
                              color: highlighted
                                  ? state.foreground
                                  : AppColors.primary),
                    ),
                  ),
                  const Spacer(),
                  if (state.icon != null)
                    Icon(state.icon, size: 20, color: state.foreground),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: AppTheme.withWeight(
                        textTheme.headlineMedium!, FontWeight.w800)
                    .copyWith(color: state.foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Buzzer "¡Robar turno!" en vino.
class _StealButton extends StatelessWidget {
  const _StealButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ChunkyPressable(
          onTap: onPressed,
          semanticLabel: '¡Robar turno!',
          builder: (context, pressed) => AnimatedContainer(
            duration: kChunkyPressDuration,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            transform: Matrix4.translationValues(0, pressed ? 5 : 0, 0),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: AppRadius.pill,
              boxShadow:
                  chunkyShadow(AppColors.onSecondaryContainer, pressed ? 1 : 6),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.onSecondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eject_rounded,
                      size: 26, color: AppColors.onSecondary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // El mockup lo escribe en mayúsculas; DESIGN.md lo
                      // prohíbe, así que va en tipo oración.
                      Text(
                        '¡Robar turno!',
                        style: AppTheme.withWeight(
                                textTheme.headlineSmall!, FontWeight.w800)
                            .copyWith(
                                color: AppColors.onSecondary, height: 1.1),
                      ),
                      Text(
                        'Buzzer ultra rápido (-$kStealPenalty pts si fallas)',
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.secondaryFixed),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.notifications_active_outlined,
                    size: 22, color: AppColors.onSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/plural.dart';
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

/// Preguntas de la partida mock (el contador "7 / 12" del mockup).
const int kTriviaQuestions = 12;
const int kTriviaPoints = 50;

/// Penalización por robar turno y fallar ("-20 pts si fallas").
const int kStealPenalty = 20;

/// Equipos del modo "Pulsador en pantalla" (en grupo).
const List<String> kTriviaTeams = ['Team Vino', 'Team Burbujas'];

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

  late final List<TriviaQuestion> _questions = interleaveDecks(
    triviaQuestionsByPack,
    triviaPacks.map((pack) => pack.id),
    _setup.selectedDecks,
  );

  late final bool _teams = _setup.answerMode == TriviaAnswerMode.buzzer;

  /// En grupo: 2 equipos. Por turnos: cada jugador suma para sí.
  late final List<String> _participants =
      _teams ? kTriviaTeams : _setup.playerNames;

  late final List<int> _scores = List.filled(_participants.length, 0);

  // Estadísticas para los "premios de la noche" del marcador.
  late final List<int> _corrects = List.filled(_participants.length, 0);
  late final List<int> _steals = List.filled(_participants.length, 0);
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
    setState(() {
      _revealed = true;
      if (correct) {
        _scores[_answering] += _points;
        _corrects[_answering]++;
        if (_stolen) _steals[_answering]++;
      } else if (_stolen) {
        _scores[_answering] -= kStealPenalty;
      }
    });
    final who = _participants[_answering];
    showGameMessage(
      context,
      correct
          ? '¡Respuesta correcta! $who sumó +$_points puntos'
          : _stolen
              ? 'Robo fallido: $who pierde $kStealPenalty puntos'
              : 'Casi… la respuesta era ${_question.options[_question.correctIndex]}',
    );
  }

  void _steal() {
    if (_stolen || _revealed) return;
    setState(() {
      _stolen = true;
      _answering = (_answering + 1) % _participants.length;
    });
    showGameMessage(context, '¡${_participants[_answering]} roba el turno!');
  }

  /// Se acabó el tiempo: se revela sin sumar puntos.
  void _timeUp() {
    if (_revealed) return;
    setState(() => _revealed = true);
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
    });
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
        summary: '¡Cerebros en llamas!',
        detail: plural(_index + 1, 'pregunta', 'preguntas'),
        plays: _index + 1,
        playsLabel: 'Preguntas jugadas',
        elapsed: DateTime.now().difference(_startedAt),
        awards: _awards(),
      ),
    );
  }

  List<MatchAward> _awards() {
    final brain = bestIndex(_corrects);
    final thief = bestIndex(_steals);
    return [
      if (brain != null)
        MatchAward(
          title: 'Cerebro de la noche',
          description: 'Más respuestas correctas',
          winner: _participants[brain],
          caption: plural(_corrects[brain], 'acierto', 'aciertos'),
          icon: Icons.psychology_rounded,
        ),
      if (thief != null)
        MatchAward(
          title: 'Ladrón de turnos',
          description: 'Robos que salieron bien',
          winner: _participants[thief],
          caption: plural(_steals[thief], 'robo', 'robos'),
          icon: Icons.bolt_rounded,
          tone: AwardTone.wine,
        ),
    ];
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
        const SizedBox(height: AppSpacing.sm),
        row(2, 3),
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

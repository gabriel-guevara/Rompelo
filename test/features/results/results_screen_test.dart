import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';
import 'package:rompelo_app/features/results/presentation/results_screen.dart';

import '../../test_utils.dart';

MatchResult sampleResult({
  String gameId = 'trivia',
  List<ScoreEntry>? scores,
}) =>
    MatchResult(
      gameId: gameId,
      scores: scores ??
          const [
            ScoreEntry(name: 'Team Burbujas', points: 310),
            ScoreEntry(name: 'Team Vino', points: 280),
          ],
      summary: '¡Cerebros en llamas!',
      detail: '12 preguntas',
      plays: 12,
      playsLabel: 'Preguntas jugadas',
      elapsed: const Duration(minutes: 18),
      awards: const [
        MatchAward(
          title: 'Cerebro de la noche',
          description: 'Más respuestas correctas',
          winner: 'Team Burbujas',
          caption: '7 aciertos',
          icon: Icons.psychology_rounded,
        ),
      ],
    );

/// Abre `/resultados` con [result] ya guardado (o vacío si es `null`).
Future<ProviderContainer> pumpResults(
        WidgetTester tester, MatchResult? result) =>
    pumpAppAt(
      tester,
      '/resultados',
      prepare: (c) {
        if (result != null) {
          c.read(lastMatchResultProvider.notifier).save(result);
        }
      },
    );

Finder inPodium(int place, String text) => find.descendant(
    of: find.byKey(ValueKey('podium-$place')), matching: find.text(text));

void main() {
  testWidgets('sin partidas muestra el estado vacío con CTA al catálogo',
      (tester) async {
    final container = await pumpResults(tester, null);

    expect(find.text('Aún no hay marcador'), findsOneWidget);
    expect(find.text('¡Partida finalizada!'), findsNothing);

    await tester.tap(find.text('Elegir un juego'));
    await tester.pumpAndSettle();
    expect(currentPath(container), '/');
  });

  testWidgets('muestra podio ordenado, premios y estadísticas', (tester) async {
    await pumpResults(tester, sampleResult());

    expect(find.text('Fin del juego'), findsOneWidget);
    expect(find.text('¡Partida finalizada!'), findsOneWidget);
    expect(find.text('¡Cerebros en llamas! • 12 preguntas'), findsOneWidget);
    expect(inPodium(1, 'Team Burbujas'), findsOneWidget);
    expect(inPodium(1, '310 pts'), findsOneWidget);
    expect(inPodium(1, '¡Campeones!'), findsOneWidget);
    expect(inPodium(2, 'Team Vino'), findsOneWidget);
    expect(find.byKey(const ValueKey('podium-3')), findsNothing);

    expect(find.text('Premios de la noche'), findsOneWidget);
    expect(find.text('Cerebro de la noche'), findsOneWidget);
    expect(find.text('Preguntas jugadas'), findsOneWidget);
    expect(find.text('En 18 minutos'), findsOneWidget);
    expect(find.text('590'), findsOneWidget); // puntos repartidos
    expect(find.text('Ventaja de 30 pts'), findsOneWidget);
  });

  testWidgets('del 4.º en adelante aparece la tabla y el empate se avisa',
      (tester) async {
    await pumpResults(
      tester,
      sampleResult(scores: const [
        ScoreEntry(name: 'Mateo', points: 3),
        ScoreEntry(name: 'Clara', points: 3),
        ScoreEntry(name: 'David', points: 2),
        ScoreEntry(name: 'Sofi', points: 1),
        ScoreEntry(name: 'Lucas', points: 0),
      ]),
    );

    expect(inPodium(3, 'David'), findsOneWidget);
    expect(find.text('4.'), findsOneWidget);
    expect(find.text('Sofi'), findsOneWidget);
    expect(find.text('5.'), findsOneWidget);
    expect(find.textContaining('¡Empate en la cima!'), findsOneWidget);
    expect(find.text('Empate en la cima'), findsOneWidget);
  });

  testWidgets('"¡Jugar revancha inmediata!" vuelve a la partida',
      (tester) async {
    final container =
        await pumpResults(tester, sampleResult(gameId: 'charadas'));

    await tester.tap(find.text('¡Jugar revancha inmediata!'));
    await tester.pumpAndSettle();

    expect(currentPath(container), '/partida/charadas');
    expect(find.text('Partida en vivo'), findsOneWidget);
  });

  testWidgets('"Volver al catálogo de juegos" vuelve al home', (tester) async {
    final container = await pumpResults(tester, sampleResult());

    await tester.tap(find.text('Volver al catálogo de juegos'));
    await tester.pumpAndSettle();

    expect(currentPath(container), '/');
    expect(find.text('¿Qué jugamos hoy?'), findsOneWidget);
  });

  test('durationCaption', () {
    expect(
        durationCaption(const Duration(seconds: 40)), 'En menos de 1 minuto');
    expect(
        durationCaption(const Duration(minutes: 1, seconds: 5)), 'En 1 minuto');
    expect(durationCaption(const Duration(minutes: 18)), 'En 18 minutos');
  });

  test('MatchResult ordena puntajes y calcula totales', () {
    final result = MatchResult(
      gameId: 'trivia',
      scores: const [
        ScoreEntry(name: 'A', points: 10),
        ScoreEntry(name: 'B', points: 40),
        ScoreEntry(name: 'C', points: 25),
      ],
      summary: '',
    );
    expect(result.scores.map((s) => s.name), ['B', 'C', 'A']);
    expect(result.totalPoints, 75);
    expect(result.leadMargin, 15);
    expect(result.tiedAtTop, isFalse);
    expect(bestIndex([0, 2, 5, 5]), 2);
    expect(bestIndex([0, 0]), isNull);
  });
}

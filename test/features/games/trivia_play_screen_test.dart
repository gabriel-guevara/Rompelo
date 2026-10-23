import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';
import 'package:rompelo_app/features/games/trivia/trivia_play_screen.dart';

import 'game_test_utils.dart';

Finder option(int i) => find.byKey(ValueKey('trivia-option-$i'));

Finder scoreText(String side, String text) => find.descendant(
      of: find.byKey(ValueKey('trivia-score-$side')),
      matching: find.text(text),
    );

void main() {
  testWidgets('muestra marcador, contador y la primera pregunta',
      (tester) async {
    await pumpGame(tester, 'trivia');

    expect(find.text('Team Vino'), findsOneWidget);
    expect(find.text('Team Burbujas'), findsOneWidget);
    expect(find.text('1 / $kTriviaQuestions'), findsOneWidget);
    expect(find.textContaining('Gasolina'), findsOneWidget);
    expect(find.text('¡Robar turno!'), findsOneWidget);
  });

  testWidgets('tocar una opción la resalta; confirmar suma puntos',
      (tester) async {
    await pumpGame(tester, 'trivia');
    expect(find.text('Confirmar respuesta'), findsNothing);

    await tester.tap(option(1)); // 2004, la correcta
    await tester.pumpAndSettle();
    expect(
      find.descendant(
          of: option(1), matching: find.byIcon(Icons.stars_rounded)),
      findsOneWidget,
    );

    // Cambiar de idea mueve el resaltado.
    await tester.tap(option(0));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.stars_rounded), findsOneWidget);
    expect(
      find.descendant(
          of: option(0), matching: find.byIcon(Icons.stars_rounded)),
      findsOneWidget,
    );
    await tester.tap(option(1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirmar respuesta'));
    await tester.pumpAndSettle();
    expect(scoreText('left', '$kTriviaPoints'), findsOneWidget);

    await tester.tap(find.text('Siguiente pregunta'));
    await tester.pumpAndSettle();
    expect(find.text('2 / $kTriviaQuestions'), findsOneWidget);
  });

  testWidgets('robar turno y fallar resta puntos al ladrón', (tester) async {
    await pumpGame(tester, 'trivia');

    await tester.tap(find.text('¡Robar turno!'));
    await tester.pumpAndSettle();
    await tester.tap(option(3)); // 2008, incorrecta
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar respuesta'));
    await tester.pumpAndSettle();

    expect(scoreText('right', '-$kStealPenalty'), findsOneWidget);
    expect(scoreText('left', '0'), findsOneWidget);
  });

  testWidgets('al terminar las preguntas va a resultados', (tester) async {
    final container = await pumpGame(tester, 'trivia');

    for (var i = 0; i < kTriviaQuestions; i++) {
      await tester.tap(option(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar respuesta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente pregunta'));
      await tester.pumpAndSettle();
    }

    expect(currentPath(container), '/resultados');
    expect(container.read(lastMatchResultProvider)?.gameId, 'trivia');
  });

  testWidgets('"Salir" pide confirmación y vuelve al home', (tester) async {
    final container = await pumpGame(tester, 'trivia');
    await expectExitWithConfirmation(tester, container);
  });
}

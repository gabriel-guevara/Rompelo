import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';
import 'package:rompelo_app/features/setup/providers/match_setup_provider.dart';

import 'game_test_utils.dart';

Finder scoreOf(int team, String text) => find.descendant(
      of: find.byKey(ValueKey('charades-score-$team')),
      matching: find.text(text),
    );

void main() {
  testWidgets('muestra ronda, marcador, tiempo y la primera carta',
      (tester) async {
    await pumpGame(tester, 'charadas');

    expect(find.text('Partida en vivo'), findsOneWidget);
    expect(find.text('Ronda 1/3'), findsOneWidget);
    expect(scoreOf(0, 'Vino: 0'), findsOneWidget);
    expect(scoreOf(1, 'Burbujas: 0'), findsOneWidget);
    expect(find.text('1:00'), findsOneWidget); // 60 s por defecto
    // Mazos por defecto: viral + memes, intercalados.
    expect(find.text('Titanic'), findsOneWidget);
    expect(find.text('Explorar'), findsNothing); // sin bottom nav
  });

  testWidgets('¡Acierto! suma un punto y avanza la carta', (tester) async {
    await pumpGame(tester, 'charadas');

    await tester.tap(find.byKey(const ValueKey('charades-correct')));
    await tester.pumpAndSettle();

    expect(scoreOf(0, 'Vino: 1'), findsOneWidget);
    expect(find.text('Titanic'), findsNothing);
    expect(find.text('Bailar como robot'), findsOneWidget);
  });

  testWidgets('Pasar avanza la carta y aplica la penalización', (tester) async {
    await pumpGame(tester, 'charadas');
    final correct = find.byKey(const ValueKey('charades-correct'));
    final pass = find.byKey(const ValueKey('charades-pass'));

    await tester.tap(correct);
    await tester.pumpAndSettle();
    await tester.tap(pass);
    await tester.pumpAndSettle();

    // Penalización activa por defecto: 1 - 1 = 0.
    expect(scoreOf(0, 'Vino: 0'), findsOneWidget);
    expect(find.text('Darth Vader'), findsOneWidget);
  });

  testWidgets('tras 3 cartas el turno pasa al otro equipo', (tester) async {
    await pumpGame(tester, 'charadas');
    final correct = find.byKey(const ValueKey('charades-correct'));

    for (var i = 0; i < 4; i++) {
      await tester.tap(correct);
      await tester.pumpAndSettle();
    }

    expect(scoreOf(0, 'Vino: 3'), findsOneWidget);
    expect(scoreOf(1, 'Burbujas: 1'), findsOneWidget);
    expect(find.text('Ronda 1/3'), findsOneWidget);
  });

  testWidgets('pausa → "Terminar turno" cede el turno', (tester) async {
    await pumpGame(tester, 'charadas');

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Partida en pausa'), findsOneWidget);
    await tester.tap(find.text('Terminar turno'));
    await tester.pumpAndSettle();

    expect(find.text('¡Turno de Team Burbujas!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('charades-correct')));
    await tester.pumpAndSettle();
    expect(scoreOf(1, 'Burbujas: 1'), findsOneWidget);
  });

  testWidgets('al terminar las rondas va a resultados y guarda el marcador',
      (tester) async {
    final container = await pumpGame(
      tester,
      'charadas',
      prepare: (c) => c.read(charadesSetupProvider.notifier).setRounds(1),
    );
    final correct = find.byKey(const ValueKey('charades-correct'));

    // 1 ronda × 2 equipos × 3 cartas.
    for (var i = 0; i < 6; i++) {
      await tester.tap(correct);
      await tester.pumpAndSettle();
    }

    expect(currentPath(container), '/resultados');
    final result = container.read(lastMatchResultProvider)!;
    expect(result.gameId, 'charadas');
    expect(result.scores.map((s) => s.points), [3, 3]);
    expect(result.plays, 6);
    expect(result.awards.first.title, 'Máquina de aciertos');
    expect(find.text('¡Partida finalizada!'), findsOneWidget);
    expect(find.text('Máquina de aciertos'), findsOneWidget);
  });

  testWidgets('"Salir" pide confirmación y vuelve al home', (tester) async {
    final container = await pumpGame(tester, 'charadas');
    await expectExitWithConfirmation(tester, container);
  });
}

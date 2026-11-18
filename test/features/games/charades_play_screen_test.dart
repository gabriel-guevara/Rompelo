import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';
import 'package:rompelo_app/features/setup/domain/match_setup.dart';
import 'package:rompelo_app/features/setup/providers/match_setup_provider.dart';

import 'game_test_utils.dart';

Finder scoreOf(int team, String text) => find.descendant(
      of: find.byKey(ValueKey('charades-score-$team')),
      matching: find.text(text),
    );

/// Palabra de la carta en pantalla (su key es `charades-word-<palabra>`).
String currentWord(WidgetTester tester) {
  final key = tester
      .widgetList(find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('charades-word-')))
      .single
      .key! as ValueKey<String>;
  return key.value.substring('charades-word-'.length);
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
}

/// Pausa → "Terminar turno" (en los tests el reloj no corre).
Future<void> endTurn(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.pause_rounded));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Terminar turno'));
  await tester.pumpAndSettle();
}

/// Solo cartas fáciles: cada acierto vale 1 punto.
void easyCards(ProviderContainer container) => container
    .read(charadesSetupProvider.notifier)
    .setDifficulty(CharadesDifficulty.easy);

void main() {
  testWidgets('empieza en "Pasa el teléfono a…" sin reloj', (tester) async {
    await pumpGame(tester, 'charadas');

    expect(find.text('Partida en vivo'), findsOneWidget);
    expect(find.text('Ronda 1/3'), findsOneWidget);
    expect(scoreOf(0, 'Vino: 0'), findsOneWidget);
    expect(scoreOf(1, 'Burbujas: 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('charades-ready-name')), findsOneWidget);
    expect(find.text('Team Vino'), findsOneWidget);
    expect(find.text('1:00'), findsNothing);
    expect(find.text('Explorar'), findsNothing); // sin bottom nav
  });

  testWidgets('"¡Estoy listo!" muestra el reloj y una carta', (tester) async {
    await pumpGame(tester, 'charadas');
    await tapKey(tester, 'charades-ready');

    expect(find.text('1:00'), findsOneWidget); // 60 s por defecto
    expect(currentWord(tester), isNotEmpty);
    expect(find.byKey(const ValueKey('charades-correct')), findsOneWidget);
    expect(find.byKey(const ValueKey('charades-pass')), findsOneWidget);
  });

  testWidgets('¡Acierto! suma según la dificultad y cambia la carta',
      (tester) async {
    await pumpGame(tester, 'charadas', prepare: easyCards);
    await tapKey(tester, 'charades-ready');
    final first = currentWord(tester);

    await tapKey(tester, 'charades-correct');

    expect(scoreOf(0, 'Vino: 1'), findsOneWidget);
    expect(currentWord(tester), isNot(first));
  });

  testWidgets('las cartas difíciles valen 3 puntos', (tester) async {
    await pumpGame(
      tester,
      'charadas',
      prepare: (c) => c
          .read(charadesSetupProvider.notifier)
          .setDifficulty(CharadesDifficulty.hard),
    );
    await tapKey(tester, 'charades-ready');
    await tapKey(tester, 'charades-correct');

    expect(scoreOf(0, 'Vino: 3'), findsOneWidget);
  });

  testWidgets('Pasar avanza la carta y aplica la penalización', (tester) async {
    await pumpGame(tester, 'charadas', prepare: easyCards);
    await tapKey(tester, 'charades-ready');

    await tapKey(tester, 'charades-correct');
    final before = currentWord(tester);
    await tapKey(tester, 'charades-pass');

    // Penalización activa por defecto: 1 - 1 = 0.
    expect(scoreOf(0, 'Vino: 0'), findsOneWidget);
    expect(currentWord(tester), isNot(before));
  });

  testWidgets('el turno dura todo el tiempo: se juegan muchas cartas',
      (tester) async {
    await pumpGame(tester, 'charadas', prepare: easyCards);
    await tapKey(tester, 'charades-ready');

    for (var i = 0; i < 6; i++) {
      await tapKey(tester, 'charades-correct');
    }
    expect(scoreOf(0, 'Vino: 6'), findsOneWidget);
    expect(find.byKey(const ValueKey('charades-correct')), findsOneWidget);
  });

  testWidgets('fin del turno → resumen → turno del otro equipo',
      (tester) async {
    await pumpGame(tester, 'charadas', prepare: easyCards);
    await tapKey(tester, 'charades-ready');
    final word = currentWord(tester);
    await tapKey(tester, 'charades-correct');
    await endTurn(tester);

    expect(find.text('¡Tiempo!'), findsOneWidget);
    expect(find.text(word), findsOneWidget); // listada en el resumen
    expect(find.text('Team Vino: 1 acierto · +1 punto'), findsOneWidget);

    await tapKey(tester, 'charades-next-turn');
    expect(find.text('Team Burbujas'), findsOneWidget);
    await tapKey(tester, 'charades-ready');
    await tapKey(tester, 'charades-correct');
    expect(scoreOf(1, 'Burbujas: 1'), findsOneWidget);
  });

  testWidgets('todos vs todos: suma el actor del turno', (tester) async {
    await pumpGame(tester, 'charadas', prepare: (c) {
      easyCards(c);
      c.read(charadesSetupProvider.notifier).setMode(CharadesMode.freeForAll);
    });

    expect(find.text('Mateo'), findsOneWidget);
    await tapKey(tester, 'charades-ready');
    await tapKey(tester, 'charades-correct');
    expect(scoreOf(0, 'Mateo: 1'), findsOneWidget);
  });

  testWidgets('al terminar las rondas va a resultados y guarda el marcador',
      (tester) async {
    final container = await pumpGame(tester, 'charadas', prepare: (c) {
      easyCards(c);
      c.read(charadesSetupProvider.notifier).setRounds(1);
    });

    await tapKey(tester, 'charades-ready');
    await tapKey(tester, 'charades-correct');
    await tapKey(tester, 'charades-correct');
    await endTurn(tester);
    await tapKey(tester, 'charades-next-turn');

    await tapKey(tester, 'charades-ready');
    await tapKey(tester, 'charades-correct');
    await endTurn(tester);
    expect(find.text('Ver resultados'), findsOneWidget);
    await tapKey(tester, 'charades-next-turn');

    expect(currentPath(container), '/resultados');
    final result = container.read(lastMatchResultProvider)!;
    expect(result.gameId, 'charadas');
    expect(result.scores.map((s) => s.points), [2, 1]);
    expect(result.plays, 3);
    expect(result.awards.first.title, 'Máquina de aciertos');
    expect(find.text('¡Partida finalizada!'), findsOneWidget);
  });

  testWidgets('las palabras del mazo personalizado entran a la partida',
      (tester) async {
    await pumpGame(tester, 'charadas', prepare: (c) {
      // 30 palabras propias entre ~84 de los mazos: alguna sale pronto.
      c.read(charadesSetupProvider.notifier).setCustomWords(
          [for (var i = 0; i < 30; i++) 'Propia $i']);
    });
    await tapKey(tester, 'charades-ready');

    var sawCustom = false;
    for (var i = 0; i < 40 && !sawCustom; i++) {
      sawCustom = currentWord(tester).startsWith('Propia');
      if (!sawCustom) await tapKey(tester, 'charades-correct');
    }
    expect(sawCustom, isTrue);
  });

  testWidgets('en horizontal todo el turno se ve sin desbordes',
      (tester) async {
    await pumpAppAt(tester, '/partida/charadas',
        prepare: easyCards, size: const Size(2400, 1100));

    expect(find.byKey(const ValueKey('charades-ready-name')), findsOneWidget);
    await tapKey(tester, 'charades-ready');
    expect(currentWord(tester), isNotEmpty);
    await tapKey(tester, 'charades-pass');
    await tapKey(tester, 'charades-correct');
    await endTurn(tester);
    expect(find.text('¡Tiempo!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('"Salir" pide confirmación y vuelve al home', (tester) async {
    final container = await pumpGame(tester, 'charadas');
    await expectExitWithConfirmation(tester, container);
  });
}

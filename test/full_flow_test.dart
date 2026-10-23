import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';
import 'package:rompelo_app/features/setup/providers/match_setup_provider.dart';

import 'test_utils.dart';

/// Recorrido completo de un grupo real, solo con toques:
/// Explorar → configurar Charadas → jugar → marcador → revancha → marcador →
/// volver al catálogo. Cubre el RF "repetir o cambiar de juego sin reiniciar".
void main() {
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    // Las listas son perezosas: se desplaza hasta que el widget existe.
    await tester.scrollUntilVisible(finder, 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// 1 ronda × 2 equipos × 3 cartas = 6 aciertos para terminar.
  Future<void> playCharadesRound(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byKey(const ValueKey('charades-correct')));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('home → config → partida → resultados → revancha → catálogo',
      (tester) async {
    final container = await pumpAppAt(tester, '/');

    // 1. Explorar: "Configurar y jugar" de Charadas.
    await tapVisible(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('game-card-charadas')),
        matching: find.text('Configurar y jugar'),
      ),
    );
    expect(currentPath(container), '/configurar/charadas');

    // 2. Configuración: se baja a 1 ronda con el stepper y se empieza.
    await tapVisible(tester, find.bySemanticsLabel('Disminuir rondas'));
    await tester.tap(find.bySemanticsLabel('Disminuir rondas'));
    await tester.pumpAndSettle();
    expect(container.read(charadesSetupProvider).rounds, 1);
    await tapVisible(tester, find.text('¡Empezar a actuar!'));
    expect(currentPath(container), '/partida/charadas');
    expect(find.text('Ronda 1/1'), findsOneWidget);

    // 3. Partida → marcador.
    await playCharadesRound(tester);
    expect(currentPath(container), '/resultados');
    expect(find.text('¡Partida finalizada!'), findsOneWidget);
    final first = container.read(lastMatchResultProvider)!;
    expect(first.scores.map((s) => s.points), [3, 3]);

    // 4. Revancha: misma configuración (1 ronda), marcador nuevo.
    await tapVisible(tester, find.text('¡Jugar revancha inmediata!'));
    expect(currentPath(container), '/partida/charadas');
    expect(find.text('Ronda 1/1'), findsOneWidget);
    await playCharadesRound(tester);
    expect(currentPath(container), '/resultados');
    expect(container.read(lastMatchResultProvider), isNot(same(first)));

    // 5. Volver al catálogo.
    await tapVisible(tester, find.text('Volver al catálogo de juegos'));
    expect(currentPath(container), '/');
    expect(find.text('¿Qué jugamos hoy?'), findsOneWidget);
  });
}

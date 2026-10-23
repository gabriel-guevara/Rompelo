import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/impostor/impostor_play_screen.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';
import 'package:rompelo_app/features/setup/providers/match_setup_provider.dart';

import 'game_test_utils.dart';

void main() {
  testWidgets('muestra debate, tema común, turno y radar', (tester) async {
    await pumpGame(tester, 'impostor');

    expect(find.text('Debate en vivo'), findsOneWidget);
    expect(find.text('03:00'), findsOneWidget); // 3 min por defecto
    expect(find.text('Gastronomía & Fiesta'), findsOneWidget);
    expect(find.text('Turno de Clara'), findsOneWidget);
    expect(find.text('Inocente'), findsNWidgets(6));
  });

  testWidgets('"Siguiente turno" rota quién pregunta', (tester) async {
    await pumpGame(tester, 'impostor');

    await tester.tap(find.text('Siguiente turno'));
    await tester.pumpAndSettle();
    expect(find.text('Turno de David'), findsOneWidget);
  });

  testWidgets('el rol solo se ve mientras se mantiene presionado',
      (tester) async {
    await pumpGame(tester, 'impostor');
    final role = find.byKey(const ValueKey('impostor-role'));
    expect(role, findsNothing);

    final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('impostor-role-peek'))));
    await tester.pump();
    expect(find.text('Guacamole casero'), findsOneWidget);

    await gesture.up();
    await tester.pump();
    expect(role, findsNothing);
  });

  testWidgets('tocar un jugador lo marca como sospechoso', (tester) async {
    await pumpGame(tester, 'impostor');

    await tester.tap(find.byKey(const ValueKey('suspect-0')));
    await tester.pumpAndSettle();
    expect(find.text('Sospechoso'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('suspect-0')));
    await tester.pumpAndSettle();
    expect(find.text('Sospechoso'), findsNothing);
  });

  testWidgets('votar sin sospechosos muestra un aviso', (tester) async {
    final container = await pumpGame(tester, 'impostor');

    await tester.tap(find.text('Votar y delatar al impostor'));
    await tester.pumpAndSettle();
    expect(
        find.text('Marca al menos un sospechoso en el radar'), findsOneWidget);
    expect(currentPath(container), '/partida/impostor');
  });

  testWidgets('delatar al impostor termina en resultados', (tester) async {
    final container = await pumpGame(tester, 'impostor');
    final setup = container.read(impostorSetupProvider);
    final impostor = mockImpostors(setup.players, setup.impostors).single;

    await tester.tap(find.byKey(ValueKey('suspect-$impostor')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Votar y delatar al impostor'));
    await tester.pumpAndSettle();

    expect(find.text('¡Atraparon al impostor!'), findsOneWidget);
    await tester.tap(find.text('Ver resultados'));
    await tester.pumpAndSettle();

    expect(currentPath(container), '/resultados');
    final result = container.read(lastMatchResultProvider)!;
    expect(result.summary, '¡Atraparon al impostor!');
    expect(result.scores.first.points, 1);
  });

  testWidgets('"Salir" pide confirmación y vuelve al home', (tester) async {
    final container = await pumpGame(tester, 'impostor');
    await expectExitWithConfirmation(tester, container);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/app.dart';
import 'package:rompelo_app/core/router/app_router.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';
import 'package:rompelo_app/features/setup/domain/match_setup.dart';
import 'package:rompelo_app/features/setup/providers/match_setup_provider.dart';

/// Abre la app directamente en [location] con un viewport alto, para que
/// toda la configuración se construya sin scroll (ver nota de la fuente de
/// test en `home_screen_test.dart`).
Future<ProviderContainer> pumpAt(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(800, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // Timers de partida apagados: el CTA abre la partida y `pumpAndSettle`
  // esperaría a que se agote cada turno.
  await tester.pumpWidget(ProviderScope(
    overrides: [liveTimersEnabledProvider.overrideWithValue(false)],
    child: const RompeloApp(),
  ));
  final container =
      ProviderScope.containerOf(tester.element(find.byType(RompeloApp)));
  container.read(appRouterProvider).go(location);
  await tester.pumpAndSettle();
  return container;
}

String currentPath(ProviderContainer container) =>
    container.read(appRouterProvider).state.uri.path;

void main() {
  const ctas = {
    'charadas': '¡Empezar a actuar!',
    'trivia': '¡Calentar pulsadores y jugar!',
    'impostor': 'Repartir identidades secretas',
  };

  for (final MapEntry(key: gameId, value: cta) in ctas.entries) {
    testWidgets('$gameId: muestra su CTA y lleva a la partida', (tester) async {
      final container = await pumpAt(tester, '/configurar/$gameId');

      expect(find.text(cta), findsOneWidget);
      await tester.tap(find.text(cta));
      await tester.pumpAndSettle();

      expect(currentPath(container), '/partida/$gameId');
    });
  }

  testWidgets('charadas: tiempo, modo y mazos cambian el estado',
      (tester) async {
    final container = await pumpAt(tester, '/configurar/charadas');

    await tester.tap(find.text('90 s'));
    await tester.pump();
    expect(container.read(charadesSetupProvider).turnSeconds, 90);
    expect(find.text('Con calma'), findsOneWidget);

    // "Todos vs todos" cambia los equipos por los nombres de jugadores.
    expect(find.text('Nombres de bandos rivales'), findsOneWidget);
    await tester.tap(find.text('Todos vs todos'));
    await tester.pumpAndSettle();
    expect(find.text('Nombres de jugadores'), findsOneWidget);

    await tester.tap(find.text('Acciones imposibles & mímica extrema'));
    await tester.pump();
    expect(find.text('3 seleccionados'), findsOneWidget);
  });

  testWidgets('charadas: no deja quitar el último mazo', (tester) async {
    final container = await pumpAt(tester, '/configurar/charadas');

    await tester.tap(find.text('Películas & series virales'));
    await tester.pump();
    await tester.tap(find.text('Famosos & memes absurdos'));
    await tester.pumpAndSettle();

    expect(container.read(charadesSetupProvider).selectedDecks, {'memes'});
    expect(find.text('Deja al menos un mazo activo'), findsOneWidget);
  });

  testWidgets('impostor: renombrar un jugador desde su chip', (tester) async {
    final container = await pumpAt(tester, '/configurar/impostor');

    await tester.tap(find.byKey(const ValueKey('player-chip-0')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Gabo');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(container.read(impostorSetupProvider).playerNames.first, 'Gabo');
    expect(find.text('Gabo'), findsOneWidget);
  });

  testWidgets('trivia: dinámica por turnos cambia el texto de equipos',
      (tester) async {
    final container = await pumpAt(tester, '/configurar/trivia');

    expect(find.text('2 equipos de 3'), findsOneWidget);
    await tester.tap(find.text('Por turnos rotativos'));
    await tester.pump();

    expect(
        container.read(triviaSetupProvider).answerMode, TriviaAnswerMode.turns);
    expect(find.text('6 turnos individuales'), findsOneWidget);
  });
}

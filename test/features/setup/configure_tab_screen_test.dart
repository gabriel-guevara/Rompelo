import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/core/router/app_router.dart';
import 'package:rompelo_app/features/setup/domain/match_setup.dart';
import 'package:rompelo_app/features/setup/presentation/configure_tab_screen.dart';
import 'package:rompelo_app/features/setup/providers/match_setup_provider.dart';

import '../../test_utils.dart';

Finder inCard(String gameId, String text) => find.descendant(
    of: find.byKey(ValueKey('setup-card-$gameId')), matching: find.text(text));

void main() {
  test('describeSetup resume cada configuración', () {
    expect(
      describeSetup(CharadesSetup.initial(6)),
      '6 jugadores · 2 equipos · 60 s por turno · 3 rondas · 2 mazos',
    );
    expect(
      describeSetup(TriviaSetup.initial(6)),
      '6 jugadores · 15 s por pregunta · Meta 500 pts · 3 mazos',
    );
    expect(
      describeSetup(ImpostorSetup.initial(4)),
      '4 jugadores · 1 impostor · Debate 3 min · 2 mazos',
    );
  });

  testWidgets('lista los 3 juegos con su configuración actual', (tester) async {
    await pumpAppAt(
      tester,
      '/configurar',
      prepare: (c) => c.read(charadesSetupProvider.notifier).setRounds(5),
    );

    for (final id in ['charadas', 'trivia', 'impostor']) {
      expect(find.byKey(ValueKey('setup-card-$id')), findsOneWidget);
    }
    expect(find.textContaining('5 rondas'), findsOneWidget);
  });

  testWidgets('"Ajustar" abre la configuración y "Jugar" la partida',
      (tester) async {
    final container = await pumpAppAt(tester, '/configurar');

    await tester.tap(inCard('trivia', 'Ajustar'));
    await tester.pumpAndSettle();
    expect(currentPath(container), '/configurar/trivia');

    container.read(appRouterProvider).go('/configurar');
    await tester.pumpAndSettle();
    await tester.tap(inCard('impostor', 'Jugar'));
    await tester.pumpAndSettle();
    expect(currentPath(container), '/partida/impostor');
  });
}

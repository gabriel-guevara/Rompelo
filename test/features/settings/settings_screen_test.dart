import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';
import 'package:rompelo_app/features/settings/providers/app_settings_provider.dart';

import '../../test_utils.dart';

void main() {
  testWidgets('los interruptores cambian las preferencias', (tester) async {
    final container = await pumpAppAt(tester, '/ajustes');
    expect(container.read(appSettingsProvider).sounds, isTrue);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(container.read(appSettingsProvider).sounds, isFalse);
    expect(find.textContaining('100 % offline'), findsOneWidget);
  });

  testWidgets('"Borrar el último marcador" vacía el marcador', (tester) async {
    final container = await pumpAppAt(
      tester,
      '/ajustes',
      prepare: (c) => c.read(lastMatchResultProvider.notifier).save(
            MatchResult(
              gameId: 'trivia',
              scores: const [ScoreEntry(name: 'Team Vino', points: 50)],
              summary: '',
            ),
          ),
    );
    expect(
        find.text('Hay una partida guardada en el marcador'), findsOneWidget);

    await tester.tap(find.text('Borrar el último marcador'));
    await tester.pumpAndSettle();

    expect(container.read(lastMatchResultProvider), isNull);
    expect(find.text('Todavía no hay partidas guardadas'), findsOneWidget);
  });
}

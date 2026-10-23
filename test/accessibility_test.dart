import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';

import 'test_utils.dart';

/// Guías de accesibilidad de `flutter_test` sobre todas las rutas:
/// - `androidTapTargetGuideline`: todo lo tocable mide al menos 48 × 48.
/// - `labeledTapTargetGuideline`: todo lo tocable tiene etiqueta para
///   TalkBack.
/// - `textContrastGuideline`: contraste de texto según WCAG (4.5 : 1, o
///   3 : 1 en textos grandes).
///
/// Viewport de 600 px de ancho: la fuente de test (Ahem) dibuja cada letra
/// de 1 em y desbordaría las filas a 390 px aunque en el dispositivo caben;
/// el ancho móvil se valida con capturas web.
void main() {
  const routes = [
    '/',
    '/configurar',
    '/configurar/charadas',
    '/configurar/trivia',
    '/configurar/impostor',
    '/partida/charadas',
    '/partida/trivia',
    '/partida/impostor',
    '/resultados',
    '/ajustes',
  ];

  final guidelines = {
    'áreas táctiles ≥ 48 px': androidTapTargetGuideline,
    'controles con etiqueta': labeledTapTargetGuideline,
    'contraste de texto': textContrastGuideline,
  };

  for (final route in routes) {
    for (final MapEntry(key: name, value: guideline) in guidelines.entries) {
      testWidgets('$route: $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpAppAt(
          tester,
          route,
          size: const Size(600, 3200),
          // El marcador se revisa con una partida guardada (podio y botones).
          prepare: (c) => c.read(lastMatchResultProvider.notifier).save(
                MatchResult(
                  gameId: 'trivia',
                  scores: const [
                    ScoreEntry(name: 'Team Vino', points: 350),
                    ScoreEntry(name: 'Team Burbujas', points: 300),
                  ],
                  summary: '¡Cerebros en llamas!',
                  awards: const [
                    MatchAward(
                      title: 'Cerebro de la noche',
                      description: 'Más respuestas correctas',
                      winner: 'Team Vino',
                      caption: '7 aciertos',
                      icon: Icons.psychology_rounded,
                    ),
                  ],
                ),
              ),
        );

        await expectLater(tester, meetsGuideline(guideline));
        semantics.dispose();
      });
    }
  }
}

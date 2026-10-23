import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/core/widgets/chunky_pressable.dart';

Future<void> pumpIn(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: child))),
    );

void main() {
  testWidgets('un control pequeño se dibuja igual pero se toca en 48 px',
      (tester) async {
    var taps = 0;
    await pumpIn(
      tester,
      ChunkyPressable(
        onTap: () => taps++,
        builder: (_, __) =>
            const SizedBox(key: ValueKey('visual'), width: 32, height: 32),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey('visual'))),
        const Size(32, 32));
    expect(tester.getSize(find.byType(ChunkyPressable)), const Size(48, 48));

    // Un toque a 22 px del centro (fuera del dibujo de 32) también cuenta.
    final center = tester.getCenter(find.byType(ChunkyPressable));
    await tester.tapAt(center + const Offset(22, 0));
    expect(taps, 1);
  });

  // Regresión de la Fase 6: el área mínima no debe aflojar las
  // restricciones del padre (los botones de Charadas dejaban de estirarse).
  testWidgets('dentro de un Expanded el hijo sigue ocupando todo el ancho',
      (tester) async {
    await pumpIn(
      tester,
      SizedBox(
        width: 300,
        child: Row(
          children: [
            Expanded(
              child: ChunkyPressable(
                onTap: () {},
                // Como el botón real: sin ancho propio y con un hijo
                // pequeño (con restricciones flojas se encogería a él).
                builder: (_, __) => Container(
                  key: const ValueKey('tile'),
                  height: 64,
                  color: Colors.red,
                  child: const Text('Pasar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey('tile'))).width, 300);
  });

  testWidgets('con semanticLabel se lee una sola vez y conserva la acción',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpIn(
      tester,
      ChunkyPressable(
        onTap: () {},
        semanticLabel: 'Por equipos',
        builder: (_, __) => const Text('Por equipos'),
      ),
    );

    expect(
      tester.getSemantics(find.byType(ChunkyPressable)),
      matchesSemantics(
        label: 'Por equipos',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}

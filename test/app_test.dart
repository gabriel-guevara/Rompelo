import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/app.dart';
import 'package:rompelo_app/core/router/app_router.dart';

/// Monta la app real (tema + router) dentro de un ProviderScope nuevo.
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: RompeloApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la app arranca en Explorar y muestra la bottom nav',
      (tester) async {
    await pumpApp(tester);

    for (final label in ['Explorar', 'Configurar', 'Marcador', 'Ajustes']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('¿Qué jugamos hoy?'), findsOneWidget);
  });

  testWidgets('tocar una tab cambia de pantalla', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.textContaining('100 % offline'), findsOneWidget);

    await tester.tap(find.text('Marcador'));
    await tester.pumpAndSettle();
    expect(find.textContaining('podio'), findsOneWidget);
  });

  testWidgets('la partida se abre a pantalla completa, sin bottom nav',
      (tester) async {
    await pumpApp(tester);

    // Explorar → "Configurar y jugar" de Charadas → partida.
    final charadesCta = find.descendant(
      of: find.byKey(const ValueKey('game-card-charadas')),
      matching: find.text('Configurar y jugar'),
    );
    // La lista es perezosa: la tarjeta solo existe cuando entra en pantalla.
    await tester.scrollUntilVisible(charadesCta, 200,
        scrollable: find.byType(Scrollable).first);
    // Lo sube al borde superior para que la bottom nav no tape el botón.
    await tester.ensureVisible(charadesCta);
    await tester.pumpAndSettle();
    await tester.tap(charadesCta);
    await tester.pumpAndSettle();
    // CTA real de la configuración de Charadas (al final de la lista).
    final startCta = find.text('¡Empezar a actuar!');
    await tester.scrollUntilVisible(startCta, 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(startCta);
    await tester.pumpAndSettle();
    await tester.tap(startCta);
    await tester.pumpAndSettle();

    expect(find.text('Partida en vivo'), findsOneWidget);
    expect(find.text('Explorar'), findsNothing);

    // "Salir" vuelve al home con la barra inferior.
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();
    expect(find.text('Explorar'), findsOneWidget);
  });

  testWidgets('un juego desconocido redirige a Explorar', (tester) async {
    await pumpApp(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(RompeloApp)));

    container.read(appRouterProvider).go('/partida/no-existe');
    await tester.pumpAndSettle();

    expect(find.text('¿Qué jugamos hoy?'), findsOneWidget);
    expect(find.text('Partida en vivo'), findsNothing);
  });
}

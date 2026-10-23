import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/app.dart';
import 'package:rompelo_app/core/router/app_router.dart';
import 'package:rompelo_app/features/setup/providers/player_count_provider.dart';

/// Monta la app en un viewport alto (800 × 2400) para que las tres GameCards
/// y todos los chips de vibra se construyan sin hacer scroll en cada test.
///
/// No usamos 390 px de ancho: la fuente de test (Ahem) dibuja cada letra
/// como un cuadrado de 1 em, mucho más ancha que Outfit, y desbordaría
/// layouts que en el dispositivo sí caben. El ancho móvil real se valida con
/// las capturas web (ver docs/progreso.md).
Future<ProviderContainer> pumpHome(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const ProviderScope(child: RompeloApp()));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(RompeloApp)));
}

String currentPath(ProviderContainer container) =>
    container.read(appRouterProvider).state.uri.path;

Finder ctaOf(String gameId) => find.descendant(
      of: find.byKey(ValueKey('game-card-$gameId')),
      matching: find.text('Configurar y jugar'),
    );

void main() {
  testWidgets('el home muestra los 3 juegos y el selector mágico',
      (tester) async {
    await pumpHome(tester);

    for (final title in [
      'Charadas alocadas',
      'El impostor silencioso',
      'Trivia relámpago',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('Configurar y jugar'), findsNWidgets(3));
    expect(find.text('¿No saben qué elegir?'), findsOneWidget);
    expect(find.text('3 juegos listos'), findsOneWidget);
    expect(find.text('Mesa 4'), findsOneWidget);
  });

  testWidgets('"Configurar y jugar" navega a la configuración del juego',
      (tester) async {
    final container = await pumpHome(tester);

    await tester.tap(ctaOf('impostor'));
    await tester.pumpAndSettle();

    expect(currentPath(container), '/configurar/impostor');
    expect(find.text('¿Cuántos impostores?'), findsOneWidget);
  });

  testWidgets('los chips de vibra filtran el catálogo', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('🕵️ Misterio'));
    await tester.pumpAndSettle();
    expect(find.text('El impostor silencioso'), findsOneWidget);
    expect(find.text('Charadas alocadas'), findsNothing);
    expect(find.text('1 juego listo'), findsOneWidget);

    await tester.tap(find.text('Todos'));
    await tester.pumpAndSettle();
    expect(find.text('3 juegos listos'), findsOneWidget);
  });

  testWidgets('el stepper guarda los jugadores en el provider', (tester) async {
    final container = await pumpHome(tester);

    await tester.tap(find.byKey(const ValueKey('stepper-plus')));
    await tester.pump();

    expect(container.read(playerCountProvider), 7);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('"¡Elegir juego al azar!" abre la configuración de un juego',
      (tester) async {
    final container = await pumpHome(tester);

    await tester.tap(find.text('¡Elegir juego al azar!'));
    await tester.pumpAndSettle();

    expect(currentPath(container), startsWith('/configurar/'));
    expect(find.textContaining('¡Tocó '), findsOneWidget);
  });

  testWidgets('el selector de mesa cambia el número', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Mesa 4'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mesa 2'));
    await tester.pumpAndSettle();

    expect(find.text('Mesa 2'), findsOneWidget);
    expect(find.text('Mesa 4'), findsNothing);
  });
}

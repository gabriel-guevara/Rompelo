import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/app.dart';
import 'package:rompelo_app/core/router/app_router.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';

/// Abre la partida de [gameId] con los timers apagados y un viewport alto
/// (la fuente de test dibuja cada letra de 1 em; ver `home_screen_test.dart`).
///
/// [prepare] permite ajustar la configuración antes de entrar (p. ej. menos
/// rondas para llegar rápido al final).
Future<ProviderContainer> pumpGame(
  WidgetTester tester,
  String gameId, {
  void Function(ProviderContainer container)? prepare,
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [liveTimersEnabledProvider.overrideWithValue(false)],
    child: const RompeloApp(),
  ));
  final container =
      ProviderScope.containerOf(tester.element(find.byType(RompeloApp)));
  prepare?.call(container);
  container.read(appRouterProvider).go('/partida/$gameId');
  await tester.pumpAndSettle();
  return container;
}

String currentPath(ProviderContainer container) =>
    container.read(appRouterProvider).state.uri.path;

/// Toca "Salir", cancela una vez y luego confirma: debe volver a `/`.
Future<void> expectExitWithConfirmation(
    WidgetTester tester, ProviderContainer container) async {
  final path = currentPath(container);

  await tester.tap(find.text('Salir'));
  await tester.pumpAndSettle();
  expect(find.text('¿Salir de la partida?'), findsOneWidget);
  await tester.tap(find.text('Seguir jugando'));
  await tester.pumpAndSettle();
  expect(currentPath(container), path);

  await tester.tap(find.text('Salir'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sí, salir'));
  await tester.pumpAndSettle();
  expect(currentPath(container), '/');
  expect(find.text('¿Qué jugamos hoy?'), findsOneWidget);
}

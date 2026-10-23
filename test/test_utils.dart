import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/app.dart';
import 'package:rompelo_app/core/router/app_router.dart';
import 'package:rompelo_app/features/games/providers/match_result_provider.dart';

/// Monta la app real en [location] con los timers de partida apagados y un
/// viewport alto (la fuente de test dibuja cada letra de 1 em; ver
/// `home_screen_test.dart`).
///
/// [prepare] ajusta el estado antes de navegar (p. ej. guardar un resultado
/// o bajar las rondas).
Future<ProviderContainer> pumpAppAt(
  WidgetTester tester,
  String location, {
  void Function(ProviderContainer container)? prepare,
  Size size = const Size(800, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [liveTimersEnabledProvider.overrideWithValue(false)],
    child: const RompeloApp(),
  ));
  final container =
      ProviderScope.containerOf(tester.element(find.byType(RompeloApp)));
  prepare?.call(container);
  container.read(appRouterProvider).go(location);
  await tester.pumpAndSettle();
  return container;
}

String currentPath(ProviderContainer container) =>
    container.read(appRouterProvider).state.uri.path;

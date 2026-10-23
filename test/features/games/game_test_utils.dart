import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils.dart';

export '../../test_utils.dart';

/// Abre la partida de [gameId] (ver [pumpAppAt]).
Future<ProviderContainer> pumpGame(
  WidgetTester tester,
  String gameId, {
  void Function(ProviderContainer container)? prepare,
}) =>
    pumpAppAt(tester, '/partida/$gameId', prepare: prepare);

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

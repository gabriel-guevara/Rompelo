import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/setup/providers/player_count_provider.dart';

void main() {
  // Un ProviderContainer es un ProviderScope sin widgets: permite probar
  // la lógica del provider como una clase normal.
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  PlayerCountNotifier notifier() =>
      container.read(playerCountProvider.notifier);

  test('arranca en 6 jugadores', () {
    expect(container.read(playerCountProvider), PlayerCountNotifier.initial);
  });

  test('incrementa, decrementa y respeta los límites', () {
    notifier().increment();
    expect(container.read(playerCountProvider), 7);

    notifier().set(1);
    expect(container.read(playerCountProvider), PlayerCountNotifier.min);
    notifier().decrement();
    expect(container.read(playerCountProvider), PlayerCountNotifier.min);

    notifier().set(100);
    expect(container.read(playerCountProvider), PlayerCountNotifier.max);
  });
}

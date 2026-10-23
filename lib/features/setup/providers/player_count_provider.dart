import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Número de jugadores reunidos alrededor del móvil.
///
/// Lo edita el selector mágico del home y la Fase 3 lo usará como valor
/// inicial en la configuración de cada juego. Un `Notifier` es la pieza de
/// Riverpod para estado que cambia: el estado vive en `state` y los cambios
/// solo pasan por los métodos públicos (como un servicio con un
/// `BehaviorSubject` privado en Angular).
class PlayerCountNotifier extends Notifier<int> {
  static const int min = 2;
  static const int max = 24;
  static const int initial = 6;

  @override
  int build() => initial;

  /// Fija un valor, siempre dentro de [min]..[max].
  void set(int value) => state = value.clamp(min, max);

  void increment() => set(state + 1);
  void decrement() => set(state - 1);
}

final playerCountProvider =
    NotifierProvider<PlayerCountNotifier, int>(PlayerCountNotifier.new);

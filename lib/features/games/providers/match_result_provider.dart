import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/match_result.dart';

export '../domain/match_result.dart';

/// Guarda el resultado de la última partida (`null` si aún no se jugó).
class LastMatchResultNotifier extends Notifier<MatchResult?> {
  @override
  MatchResult? build() => null;

  void save(MatchResult result) => state = result;

  /// "Borrar el último marcador" (Ajustes).
  void clear() => state = null;
}

final lastMatchResultProvider =
    NotifierProvider<LastMatchResultNotifier, MatchResult?>(
        LastMatchResultNotifier.new);

/// Interruptor de los temporizadores de partida.
///
/// En la app siempre es `true`. Los tests lo sobreescriben con `false`:
/// un timer que corre sin parar programa frames sin fin y `pumpAndSettle`
/// nunca terminaría de "asentarse".
final liveTimersEnabledProvider = Provider<bool>((ref) => true);

/// Interruptor del acelerómetro de Charadas (los tests lo apagan: en el
/// entorno de test no hay sensores).
final tiltSensorEnabledProvider = Provider<bool>((ref) => true);

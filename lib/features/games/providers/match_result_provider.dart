import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Puntaje final de un equipo o jugador.
@immutable
class ScoreEntry {
  const ScoreEntry({required this.name, required this.points});

  final String name;
  final int points;
}

/// Resultado de la última partida jugada. Lo escribe la pantalla de partida
/// al terminar y lo leerá el marcador / podio (Fase 5).
@immutable
class MatchResult {
  MatchResult({
    required this.gameId,
    required List<ScoreEntry> scores,
    required this.summary,
  }) : scores = List.unmodifiable(
            [...scores]..sort((a, b) => b.points.compareTo(a.points)));

  /// Juego jugado: permite la "revancha" con la misma configuración.
  final String gameId;

  /// Ordenados de mayor a menor (el primero es el ganador).
  final List<ScoreEntry> scores;

  /// Frase corta del final ("¡Atraparon al impostor!").
  final String summary;
}

/// Guarda el resultado de la última partida (`null` si aún no se jugó).
class LastMatchResultNotifier extends Notifier<MatchResult?> {
  @override
  MatchResult? build() => null;

  void save(MatchResult result) => state = result;
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

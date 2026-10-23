import 'package:flutter/material.dart';

/// Puntaje final de un equipo o jugador.
@immutable
class ScoreEntry {
  const ScoreEntry({required this.name, required this.points});

  final String name;
  final int points;
}

/// Familia de color de un premio (fondo del icono en "Premios de la noche").
enum AwardTone { sky, wine, warm }

/// Un "premio de la noche": un momento destacado con su ganador.
@immutable
class MatchAward {
  const MatchAward({
    required this.title,
    required this.description,
    required this.winner,
    required this.caption,
    required this.icon,
    this.tone = AwardTone.sky,
  });

  /// "Máquina de aciertos".
  final String title;

  /// "Más cartas adivinadas".
  final String description;
  final String winner;

  /// Dato corto bajo el ganador ("5 aciertos").
  final String caption;
  final IconData icon;
  final AwardTone tone;
}

/// Resultado de la última partida jugada. Lo escribe la pantalla de partida
/// al terminar y lo lee el marcador (podio, premios y estadísticas).
///
/// Es un objeto de dominio: no sabe de widgets ni de rutas, solo describe
/// qué pasó. Así el marcador sirve para cualquier juego nuevo.
@immutable
class MatchResult {
  MatchResult({
    required this.gameId,
    required List<ScoreEntry> scores,
    required this.summary,
    this.detail = '',
    this.plays = 0,
    this.playsLabel = 'Jugadas',
    this.elapsed = Duration.zero,
    this.awards = const [],
  }) : scores = List.unmodifiable(
            [...scores]..sort((a, b) => b.points.compareTo(a.points)));

  /// Juego jugado: permite la "revancha" con la misma configuración.
  final String gameId;

  /// Ordenados de mayor a menor (el primero es el ganador). `sort` es
  /// estable: con empate se conserva el orden original.
  final List<ScoreEntry> scores;

  /// Frase corta del final ("¡Atraparon al impostor!").
  final String summary;

  /// Complemento del subtítulo ("3 rondas intensas").
  final String detail;

  /// Cartas, preguntas o turnos jugados, y cómo se llaman en este juego.
  final int plays;
  final String playsLabel;

  /// Cuánto duró la partida.
  final Duration elapsed;
  final List<MatchAward> awards;

  /// Suma de todos los puntos repartidos.
  int get totalPoints => scores.fold(0, (sum, s) => sum + s.points);

  /// `true` si los dos primeros terminaron con los mismos puntos.
  bool get tiedAtTop =>
      scores.length > 1 && scores[0].points == scores[1].points;

  /// Ventaja del 1.º sobre el 2.º (0 si hay un solo participante).
  int get leadMargin =>
      scores.length > 1 ? scores[0].points - scores[1].points : 0;
}

/// Índice del valor más alto de [values], o `null` si todos son ≤ 0
/// (no se premia a nadie por "0 aciertos"). Con empate gana el primero.
int? bestIndex(List<int> values) {
  int? best;
  for (var i = 0; i < values.length; i++) {
    if (values[i] > 0 && (best == null || values[i] > values[best])) best = i;
  }
  return best;
}

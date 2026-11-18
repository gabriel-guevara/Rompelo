import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/game_item.dart';

/// Catálogo de juegos disponibles (textos del mockup `design/stitch/home`).
///
/// Agregar un juego nuevo empieza aquí: una entrada más en esta lista.
const List<GameItem> gamesCatalog = [
  GameItem(
    id: 'charadas',
    title: 'Charadas alocadas',
    description:
        'Ponte el móvil en la frente e interpreta situaciones delirantes '
        'antes de que acabe el tiempo.',
    icon: Icons.theater_comedy_rounded,
    tag: 'Actuación & risas',
    durationMinutes: 10,
    minPlayers: 3,
    maxPlayers: 12,
    chips: [
      GameChip(label: 'Cine & series', icon: Icons.movie_rounded),
      GameChip(label: 'Memes', icon: Icons.sentiment_very_satisfied_rounded),
      GameChip(label: 'Mímica extrema', icon: Icons.theater_comedy_rounded),
    ],
    accent: GameAccent.wine,
    ctaIcon: Icons.play_arrow_rounded,
    vibes: {GameVibe.fiesta, GameVibe.chill},
    rules: [
      'Elijan modo: por equipos o todos contra todos.',
      'En su turno, un jugador se pone el móvil en la frente con la pantalla '
          'hacia su grupo.',
      'El grupo actúa o da pistas sin decir la palabra, y el jugador intenta '
          'adivinarla.',
      'Inclina el móvil hacia abajo (o toca ¡Acierto!) si adivinó, y hacia '
          'arriba (o Pasar) para saltar la carta.',
      'Fácil vale 1 punto, media 2 y difícil 3. Pasar puede restar 1.',
      'Jueguen todas las cartas que puedan antes de que se acabe el tiempo. '
          'Gana quien más puntos sume.',
    ],
  ),
  GameItem(
    id: 'impostor',
    title: 'El impostor silencioso',
    description:
        'Todos conocen la palabra secreta salvo uno. Haz preguntas sutiles '
        'y desenmascara al farsante.',
    icon: Icons.person_search_rounded,
    tag: 'Deducción & misterio',
    durationMinutes: 8,
    minPlayers: 4,
    maxPlayers: 10,
    chips: [
      GameChip(label: 'Turno a ciegas', icon: Icons.visibility_off_rounded),
      GameChip(label: 'Voto secreto', icon: Icons.how_to_vote_rounded),
      GameChip(label: 'Sin pistas obvias', icon: Icons.psychology_rounded),
    ],
    accent: GameAccent.sky,
    ctaIcon: Icons.fingerprint_rounded,
    vibes: {GameVibe.misterio, GameVibe.chill},
    rules: [
      'Pasen el móvil: cada uno mantiene presionado para ver su rol en '
          'secreto.',
      'Todos ven la misma palabra secreta, menos el impostor, que solo '
          'conoce el tema.',
      'Por turnos, cada uno pregunta o da una pista sobre la palabra sin '
          'decirla.',
      'Al terminar el debate, voten en voz alta y marquen a quién acusan. '
          'Si es inocente, queda eliminado y siguen debatiendo.',
      'Los impostores ganan si quedan tantos como ciudadanos.',
      'Si atrapan al impostor, aún puede ganar si adivina la palabra.',
      'Ciudadanos: +1 si ganan. Impostor: +2 si escapa y +3 si adivina. '
          'Jueguen las rondas que quieran.',
    ],
  ),
  GameItem(
    id: 'trivia',
    title: 'Trivia relámpago',
    description:
        'Preguntas directas al grano. El más rápido en tocar el pulsador '
        'roba el turno y la gloria.',
    icon: Icons.quiz_rounded,
    tag: 'Conocimiento & velocidad',
    durationMinutes: 12,
    minPlayers: 2,
    maxPlayers: 20,
    chips: [
       GameChip(
          label: 'Para toda la familia', icon: Icons.family_restroom_rounded),
      GameChip(label: 'Verdadero o falso', icon: Icons.rule_rounded),
      GameChip(label: 'Robo de turno', icon: Icons.bolt_rounded),
    ],
    accent: GameAccent.warm,
    ctaIcon: Icons.bolt_rounded,
    vibes: {GameVibe.reflejos, GameVibe.fiesta},
    rules: [
      'Elijan modo: dos equipos con pulsador o turnos individuales.',
      'Lean la pregunta en voz alta y elijan una opción antes de que se '
          'acabe el tiempo.',
      'Confirmen la respuesta: si es correcta, suman puntos (la última '
          'pregunta puede valer doble).',
      'En modo equipos pueden robar el turno una vez por pregunta, pero '
          'fallar resta puntos.',
      'Gana quien llegue primero a la meta de puntos o vaya arriba al '
          'terminar las preguntas.',
    ],
  ),
];

/// Busca un juego por id; `null` si la ruta trae un id desconocido.
GameItem? gameById(String id) {
  for (final game in gamesCatalog) {
    if (game.id == id) return game;
  }
  return null;
}

/// Juegos que coinciden con una vibra; `null` ("Todos") devuelve el catálogo.
List<GameItem> gamesByVibe(GameVibe? vibe,
    {List<GameItem> games = gamesCatalog}) {
  if (vibe == null) return games;
  return [
    for (final game in games)
      if (game.vibes.contains(vibe)) game,
  ];
}

/// Elige un juego al azar para "¡Elegir juego al azar!".
///
/// Prioriza los juegos en los que cabe el grupo; si ninguno cabe, sortea
/// entre todos. [random] se inyecta para que los tests sean deterministas.
GameItem pickRandomGame({
  required int players,
  Random? random,
  List<GameItem> games = gamesCatalog,
}) {
  assert(games.isNotEmpty);
  final fitting = [
    for (final game in games)
      if (game.fitsPlayers(players)) game,
  ];
  final pool = fitting.isEmpty ? games : fitting;
  return pool[(random ?? Random()).nextInt(pool.length)];
}

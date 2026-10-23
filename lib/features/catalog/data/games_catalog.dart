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
  ),
  GameItem(
    id: 'trivia',
    title: 'Trivia relámpago',
    description:
        'Preguntas directas al grano. El más rápido en tocar el pulsador '
        'roba el turno y la gloria.',
    icon: Icons.quiz_rounded,
    tag: 'Cultura pop & velocidad',
    durationMinutes: 12,
    minPlayers: 2,
    maxPlayers: 20,
    chips: [
      GameChip(label: 'Hits 2000s', icon: Icons.music_note_rounded),
      GameChip(
          label: 'Memes virales', icon: Icons.local_fire_department_rounded),
      GameChip(label: 'Robo de turno', icon: Icons.bolt_rounded),
    ],
    accent: GameAccent.warm,
    ctaIcon: Icons.bolt_rounded,
    vibes: {GameVibe.reflejos, GameVibe.fiesta},
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

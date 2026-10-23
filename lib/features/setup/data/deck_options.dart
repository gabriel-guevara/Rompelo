import 'package:flutter/material.dart';

/// Un mazo de cartas / pack de preguntas / paquete de palabras.
@immutable
class DeckOption {
  const DeckOption({
    required this.id,
    required this.title,
    required this.subtitle,
    this.icon,
    this.emoji,
    this.badge,
    this.adult = false,
  }) : assert(icon != null || emoji != null);

  final String id;
  final String title;
  final String subtitle;
  final IconData? icon;

  /// Alternativa al icono (el mockup del Impostor usa emoji).
  final String? emoji;

  /// Insignia corta: "Popular", "+18"…
  final String? badge;

  /// Contenido para adultos: la UI lo tiñe de vino como advertencia.
  final bool adult;
}

/// Textos de los mockups `config_*`.
const List<DeckOption> charadesDecks = [
  DeckOption(
    id: 'viral',
    title: 'Películas & series virales',
    subtitle: '140 cartas listas para interpretar',
    icon: Icons.movie_rounded,
    badge: 'Popular',
  ),
  DeckOption(
    id: 'memes',
    title: 'Famosos & memes absurdos',
    subtitle: '95 momentos de la cultura pop',
    icon: Icons.sentiment_very_satisfied_rounded,
  ),
  DeckOption(
    id: 'mimica',
    title: 'Acciones imposibles & mímica extrema',
    subtitle: '110 retos solo con cuerpo y gestos',
    icon: Icons.sports_kabaddi_rounded,
  ),
];

const List<DeckOption> triviaPacks = [
  DeckOption(
    id: 'hits',
    title: 'Hits musicales & Canciones de los 2000',
    subtitle: 'Pop, reggaetón nostálgico y tribus urbanas',
    icon: Icons.music_note_rounded,
  ),
  DeckOption(
    id: 'cine',
    title: 'Cine de culto & Series de maratón',
    subtitle: 'Frases célebres, spoilers y estrenos icónicos',
    icon: Icons.movie_rounded,
  ),
  DeckOption(
    id: 'memes',
    title: 'Memes virales & Cultura de internet',
    subtitle: 'Audios de TikTok, stickers legendarios y trends',
    icon: Icons.mood_rounded,
  ),
  DeckOption(
    id: 'geografia',
    title: 'Geografía express & Curiosidades absurdas',
    subtitle: 'Banderas rápidas, animales raros y datos locos',
    icon: Icons.public_rounded,
  ),
];

const List<DeckOption> impostorDecks = [
  DeckOption(
    id: 'comida',
    title: 'Comida & antojos de fiesta',
    subtitle: 'Tacos, fondue, sushi y snacks',
    emoji: '🍔',
  ),
  DeckOption(
    id: 'objetos',
    title: 'Objetos cotidianos raros',
    subtitle: 'Quitapelusas, sacacorchos, pantufla',
    emoji: '🛋️',
  ),
  DeckOption(
    id: 'lugares',
    title: 'Lugares del mundo y viajes',
    subtitle: 'Aeropuertos, ruinas y playas secretas',
    emoji: '✈️',
  ),
  DeckOption(
    id: 'picante',
    title: 'Modo picante',
    subtitle: 'Citas incómodas, confesiones y secretos',
    emoji: '🌶️',
    badge: '+18',
    adult: true,
  ),
];

/// Avatares emoji de los jugadores (se repiten si hay más de 8).
const List<String> playerEmojis = [
  '👑', '🐱', '🍕', '🚀', '🥑', '👾', '🦊', '⚡', //
];

String playerEmoji(int index) => playerEmojis[index % playerEmojis.length];

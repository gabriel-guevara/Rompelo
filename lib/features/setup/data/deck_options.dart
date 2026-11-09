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

@immutable
class DeckGroup {
  const DeckGroup({
    required this.title,
    required this.icon,
    required this.deckIds,
  });

  final String title;
  final IconData icon;
  final List<String> deckIds;
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

const List<DeckGroup> triviaPackGroups = [
  DeckGroup(
    title: 'Naturaleza y ciencia',
    icon: Icons.eco_rounded,
    deckIds: ['animales', 'oceanos', 'dinos', 'ciencia', 'espacio', 'cuerpo'],
  ),
  DeckGroup(
    title: 'Mundo y culturas',
    icon: Icons.public_rounded,
    deckIds: ['mundo', 'banderas', 'comida', 'culturas', 'idiomas'],
  ),
  DeckGroup(
    title: 'Arte y diversión',
    icon: Icons.theaters_rounded,
    deckIds: ['arte', 'cine_familia', 'mitos', 'deportes'],
  ),
  DeckGroup(
    title: 'Retos mentales',
    icon: Icons.psychology_rounded,
    deckIds: ['mates', 'inventos', 'vf'],
  ),
];

const List<DeckOption> triviaPacks = [
  DeckOption(
    id: 'animales',
    title: 'Animales asombrosos',
    subtitle: 'Récords, rarezas y datos del reino animal',
    icon: Icons.pets_rounded,
  ),
  DeckOption(
    id: 'espacio',
    title: 'Viaje al espacio',
    subtitle: 'Planetas, estrellas y misiones históricas',
    icon: Icons.rocket_launch_rounded,
  ),
  DeckOption(
    id: 'cuerpo',
    title: 'Cuerpo humano',
    subtitle: 'Huesos, órganos y cómo funcionamos',
    icon: Icons.favorite_rounded,
  ),
  DeckOption(
    id: 'mundo',
    title: 'Vuelta al mundo',
    subtitle: 'Capitales, montañas, ríos y desiertos',
    icon: Icons.public_rounded,
  ),
  DeckOption(
    id: 'banderas',
    title: 'Banderas del mundo',
    subtitle: 'Colores, símbolos y escudos',
    icon: Icons.flag_rounded,
  ),
  DeckOption(
    id: 'ciencia',
    title: 'Ciencia y naturaleza',
    subtitle: 'Experimentos, plantas y fenómenos',
    icon: Icons.science_rounded,
  ),
  DeckOption(
    id: 'oceanos',
    title: 'Océanos y vida marina',
    subtitle: 'Criaturas y secretos del fondo del mar',
    icon: Icons.water_rounded,
  ),
  DeckOption(
    id: 'dinos',
    title: 'Dinosaurios',
    subtitle: 'Gigantes prehistóricos y fósiles',
    icon: Icons.egg_rounded,
  ),
  DeckOption(
    id: 'comida',
    title: 'Sabores del mundo',
    subtitle: 'Platos típicos, ingredientes y orígenes',
    icon: Icons.restaurant_rounded,
  ),
  DeckOption(
    id: 'inventos',
    title: 'Inventos y genios',
    subtitle: 'Descubrimientos que cambiaron el mundo',
    icon: Icons.lightbulb_rounded,
  ),
  DeckOption(
    id: 'arte',
    title: 'Arte, música y libros',
    subtitle: 'Pintores, escritores e instrumentos',
    icon: Icons.palette_rounded,
  ),
  DeckOption(
    id: 'deportes',
    title: 'Deportes y campeones',
    subtitle: 'Reglas, récords y grandes atletas',
    icon: Icons.sports_soccer_rounded,
  ),
  DeckOption(
    id: 'idiomas',
    title: 'Palabras e idiomas',
    subtitle: 'Lenguas del mundo y juegos de palabras',
    icon: Icons.translate_rounded,
  ),
  DeckOption(
    id: 'mates',
    title: 'Mente matemática',
    subtitle: 'Cálculo rápido, figuras y acertijos',
    icon: Icons.calculate_rounded,
  ),
  DeckOption(
    id: 'culturas',
    title: 'Culturas y celebraciones',
    subtitle: 'Fiestas, tradiciones y maravillas del mundo',
    icon: Icons.celebration_rounded,
  ),
  DeckOption(
    id: 'cine_familia',
    title: 'Cine y animación en familia',
    subtitle: 'Películas animadas y personajes de todas las edades',
    icon: Icons.theaters_rounded,
  ),
  DeckOption(
    id: 'mitos',
    title: 'Mitos y leyendas',
    subtitle: 'Dioses, héroes y criaturas fantásticas',
    icon: Icons.auto_stories_rounded,
  ),
  DeckOption(
    id: 'vf',
    title: 'Verdadero o falso',
    subtitle: 'Mitos comunes y datos que parecen mentira',
    icon: Icons.rule_rounded,
    badge: 'Nuevo',
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

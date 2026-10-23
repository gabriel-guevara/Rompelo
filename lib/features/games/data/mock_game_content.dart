import 'package:flutter/material.dart';

/// Contenido mock de las partidas (Fase 4): cartas, preguntas y palabras.
///
/// Las claves de cada mapa son los **mismos ids de mazo** de
/// `features/setup/data/deck_options.dart`, así la configuración elegida
/// decide qué contenido sale en la partida. Es dato puro e inmutable: cuando
/// exista contenido real (JSON en `assets/`), solo cambia este archivo.

// --- Charadas ----------------------------------------------------------------

enum CardDifficulty {
  easy('Fácil'),
  medium('Media'),
  hard('Difícil');

  const CardDifficulty(this.label);

  final String label;
}

@immutable
class CharadesCard {
  const CharadesCard({
    required this.word,
    required this.hint,
    required this.category,
    required this.icon,
    this.difficulty = CardDifficulty.medium,
  });

  final String word;

  /// Indicación entre paréntesis bajo la palabra.
  final String hint;
  final String category;
  final IconData icon;
  final CardDifficulty difficulty;
}

const Map<String, List<CharadesCard>> charadesCardsByDeck = {
  'viral': [
    CharadesCard(
      word: 'Titanic',
      hint: '(Escena del barco con los brazos abiertos)',
      category: 'Cine & Drama romántico',
      icon: Icons.sailing_rounded,
    ),
    CharadesCard(
      word: 'Darth Vader',
      hint: '("Yo soy tu padre" con voz profunda)',
      category: 'Cine & Ciencia ficción',
      icon: Icons.smart_toy_rounded,
      difficulty: CardDifficulty.easy,
    ),
    CharadesCard(
      word: 'El Rey León',
      hint: '(Alzando a Simba en la roca del rey)',
      category: 'Animación infantil',
      icon: Icons.pets_rounded,
    ),
    CharadesCard(
      word: 'El juego del calamar',
      hint: '(Luz roja, luz verde… ¡y quieto!)',
      category: 'Series de maratón',
      icon: Icons.videogame_asset_rounded,
      difficulty: CardDifficulty.hard,
    ),
  ],
  'memes': [
    CharadesCard(
      word: 'Bailar como robot',
      hint: '(El paso viral de TikTok, sin música)',
      category: 'Memes & cultura pop',
      icon: Icons.music_note_rounded,
      difficulty: CardDifficulty.easy,
    ),
    CharadesCard(
      word: 'Perro con lentes',
      hint: '("Esto está bien" mientras todo arde)',
      category: 'Memes absurdos',
      icon: Icons.sentiment_very_satisfied_rounded,
    ),
    CharadesCard(
      word: 'Influencer en vivo',
      hint: '(Saluda a la cámara y pide likes)',
      category: 'Famosos & redes',
      icon: Icons.videocam_rounded,
    ),
  ],
  'mimica': [
    CharadesCard(
      word: 'Bañar a un gato',
      hint: '(Sin que te arañe… o casi)',
      category: 'Acciones imposibles',
      icon: Icons.bathtub_rounded,
      difficulty: CardDifficulty.hard,
    ),
    CharadesCard(
      word: 'Surfear una ola gigante',
      hint: '(Equilibrio total sobre la tabla)',
      category: 'Mímica extrema',
      icon: Icons.surfing_rounded,
    ),
    CharadesCard(
      word: 'Armar un mueble sin manual',
      hint: '(Sobra un tornillo y nadie sabe por qué)',
      category: 'Acciones imposibles',
      icon: Icons.handyman_rounded,
    ),
  ],
};

// --- Trivia ------------------------------------------------------------------

@immutable
class TriviaQuestion {
  const TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
    required this.tag,
  });

  final String question;

  /// Siempre 4 opciones (A–D).
  final List<String> options;
  final int correctIndex;
  final String category;

  /// Etiqueta corta del pie de la carta ("Hit 2000s").
  final String tag;
}

const Map<String, List<TriviaQuestion>> triviaQuestionsByPack = {
  'hits': [
    TriviaQuestion(
      question: '¿En qué año se lanzó la canción "Gasolina" de Daddy Yankee '
          'que transformó el reggaetón en fenómeno global?',
      options: ['2002', '2004', '2006', '2008'],
      correctIndex: 1,
      category: 'Música & Cultura pop',
      tag: 'Hit 2000s',
    ),
    TriviaQuestion(
      question: '¿Qué banda mexicana cantaba "Sálvame" en la telenovela '
          'Rebelde?',
      options: ['Belanova', 'RBD', 'Reik', 'Camila'],
      correctIndex: 1,
      category: 'Música & Cultura pop',
      tag: 'Pop latino',
    ),
    TriviaQuestion(
      question: '¿Quién lanzó el álbum "Fijación oral" en 2005?',
      options: ['Shakira', 'Paulina Rubio', 'Thalía', 'Julieta Venegas'],
      correctIndex: 0,
      category: 'Música & Cultura pop',
      tag: 'Hit 2000s',
    ),
  ],
  'cine': [
    TriviaQuestion(
      question: '¿Cómo se llama el hotel de la película "El resplandor"?',
      options: [
        'Hotel Bates',
        'Hotel Overlook',
        'Gran Budapest',
        'Hotel Cortez'
      ],
      correctIndex: 1,
      category: 'Cine de culto',
      tag: 'Terror clásico',
    ),
    TriviaQuestion(
      question: '¿En qué ciudad viven los protagonistas de "Friends"?',
      options: ['Chicago', 'Boston', 'Nueva York', 'Los Ángeles'],
      correctIndex: 2,
      category: 'Series de maratón',
      tag: 'Sitcom',
    ),
    TriviaQuestion(
      question: '¿Qué color de pastilla elige Neo en "Matrix"?',
      options: ['Azul', 'Verde', 'Amarilla', 'Roja'],
      correctIndex: 3,
      category: 'Cine de culto',
      tag: 'Ciencia ficción',
    ),
  ],
  'memes': [
    TriviaQuestion(
      question: '¿Qué animal protagoniza el meme "Doge"?',
      options: ['Un gato', 'Un perro shiba', 'Un hámster', 'Una llama'],
      correctIndex: 1,
      category: 'Cultura de internet',
      tag: 'Meme clásico',
    ),
    TriviaQuestion(
      question: '¿En qué red social nació el formato de videos de 6 '
          'segundos?',
      options: ['Vine', 'Snapchat', 'TikTok', 'Tumblr'],
      correctIndex: 0,
      category: 'Cultura de internet',
      tag: 'Nostalgia',
    ),
    TriviaQuestion(
      question: '¿Qué emoji se usa más en el mundo según Unicode?',
      options: ['❤️', '😂', '👍', '🔥'],
      correctIndex: 1,
      category: 'Cultura de internet',
      tag: 'Dato curioso',
    ),
  ],
  'geografia': [
    TriviaQuestion(
      question: '¿Cuál es el país con más volcanes activos del mundo?',
      options: ['Japón', 'Chile', 'Indonesia', 'Islandia'],
      correctIndex: 2,
      category: 'Geografía express',
      tag: 'Dato loco',
    ),
    TriviaQuestion(
      question: '¿Qué animal puede dormir hasta 22 horas al día?',
      options: ['Koala', 'Perezoso', 'Gato', 'Murciélago'],
      correctIndex: 0,
      category: 'Curiosidades absurdas',
      tag: 'Animales raros',
    ),
    TriviaQuestion(
      question: '¿Cuál es la capital de Australia?',
      options: ['Sídney', 'Melbourne', 'Perth', 'Canberra'],
      correctIndex: 3,
      category: 'Geografía express',
      tag: 'Capitales',
    ),
  ],
};

// --- Impostor ----------------------------------------------------------------

@immutable
class ImpostorTopic {
  const ImpostorTopic({
    required this.topic,
    required this.icon,
    required this.words,
    required this.impostorHint,
  });

  /// Tema común que todos conocen ("Gastronomía & Fiesta").
  final String topic;
  final IconData icon;

  /// Palabras secretas posibles; la partida mock usa la primera.
  final List<String> words;

  /// Pista opcional para el impostor (ajuste "Pista para el impostor").
  final String impostorHint;
}

const Map<String, ImpostorTopic> impostorTopicsByDeck = {
  'comida': ImpostorTopic(
    topic: 'Gastronomía & Fiesta',
    icon: Icons.restaurant_rounded,
    words: ['Guacamole casero', 'Fondue', 'Tacos al pastor'],
    impostorHint: 'Se comparte en el centro de la mesa',
  ),
  'objetos': ImpostorTopic(
    topic: 'Objetos cotidianos',
    icon: Icons.chair_rounded,
    words: ['Sacacorchos', 'Pantufla', 'Quitapelusas'],
    impostorHint: 'Está en casi todas las cocinas',
  ),
  'lugares': ImpostorTopic(
    topic: 'Lugares & viajes',
    icon: Icons.flight_rounded,
    words: ['Aeropuerto', 'Ruinas mayas', 'Playa secreta'],
    impostorHint: 'Hay que hacer fila para entrar',
  ),
  'picante': ImpostorTopic(
    topic: 'Modo picante',
    icon: Icons.local_fire_department_rounded,
    words: ['Primera cita', 'Mensaje a las 3 a. m.', 'Confesión'],
    impostorHint: 'Da un poco de vergüenza contarlo',
  ),
};

// --- Selección según la configuración ----------------------------------------

/// Junta el contenido de los mazos elegidos **intercalándolo** (una carta de
/// cada mazo por vez), para que la partida no muestre todo un mazo seguido.
///
/// Respeta el orden de [deckOrder] (el de `deck_options.dart`) y no el del
/// `Set`, así el resultado es determinista y fácil de testear.
List<T> interleaveDecks<T>(
  Map<String, List<T>> byDeck,
  Iterable<String> deckOrder,
  Set<String> selected,
) {
  final decks = [
    for (final id in deckOrder)
      if (selected.contains(id) && byDeck[id] != null) byDeck[id]!,
  ];
  final longest =
      decks.fold<int>(0, (max, deck) => deck.length > max ? deck.length : max);
  return [
    for (var i = 0; i < longest; i++)
      for (final deck in decks)
        if (i < deck.length) deck[i],
  ];
}

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

  /// Siempre 2 o 4 opciones (A–D).
  final List<String> options;
  final int correctIndex;
  final String category;

  /// Etiqueta corta del pie de la carta ("Hit 2000s").
  final String tag;
}

const Map<String, List<TriviaQuestion>> triviaQuestionsByPack = {
  'animales': [
    TriviaQuestion(
      question: '¿Cuántos corazones tiene un pulpo?',
      options: ['3', '1', '2', '4'],
      correctIndex: 0,
      category: 'Animales',
      tag: 'Dato loco',
    ),
    TriviaQuestion(
      question: '¿Cuál es el animal terrestre más rápido?',
      options: ['León', 'Caballo', 'Guepardo', 'Gacela'],
      correctIndex: 2,
      category: 'Animales',
      tag: 'Récord',
    ),
    TriviaQuestion(
      question: '¿Cuál es el animal más grande del planeta?',
      options: [
        'Ballena azul',
        'Elefante africano',
        'Tiburón ballena',
        'Jirafa'
      ],
      correctIndex: 0,
      category: 'Animales',
      tag: 'Récord',
    ),
    TriviaQuestion(
      question: '¿Cuál es el único mamífero capaz de volar de verdad?',
      options: ['Ardilla voladora', 'Murciélago', 'Colibrí', 'Lémur'],
      correctIndex: 1,
      category: 'Animales',
      tag: 'Mamíferos',
    ),
    TriviaQuestion(
      question: '¿De qué se alimenta casi exclusivamente el panda gigante?',
      options: ['Eucalipto', 'Pescado', 'Frutas', 'Bambú'],
      correctIndex: 3,
      category: 'Animales',
      tag: 'Alimentación',
    ),
    TriviaQuestion(
      question: '¿Cuántas patas tiene cualquier insecto?',
      options: ['4', '8', '10', '6'],
      correctIndex: 3,
      category: 'Animales',
      tag: 'Insectos',
    ),
    TriviaQuestion(
      question: '¿Cuál es el ave más grande del mundo?',
      options: ['Emú', 'Pingüino emperador', 'Cóndor', 'Avestruz'],
      correctIndex: 3,
      category: 'Animales',
      tag: 'Aves',
    ),
    TriviaQuestion(
      question: '¿Cuál es el animal más alto del mundo?',
      options: ['Elefante', 'Jirafa', 'Camello', 'Avestruz'],
      correctIndex: 1,
      category: 'Animales',
      tag: 'Récord',
    ),
    TriviaQuestion(
      question: '¿Qué ave aparece en el escudo de Colombia?',
      options: ['Cóndor andino', 'Águila real', 'Guacamaya', 'Colibrí'],
      correctIndex: 0,
      category: 'Animales',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question:
          '¿Cómo se llama el proceso en que una oruga se convierte en mariposa?',
      options: ['Metamorfosis', 'Fotosíntesis', 'Hibernación', 'Migración'],
      correctIndex: 0,
      category: 'Animales',
      tag: 'Ciclo de vida',
    ),
    TriviaQuestion(
      question: '¿Cuál de estos animales es un marsupial?',
      options: ['Koala', 'Panda', 'Perezoso', 'Mapache'],
      correctIndex: 0,
      category: 'Animales',
      tag: 'Mamíferos',
    ),
    TriviaQuestion(
      question:
          '¿Qué reptil puede mover cada ojo por separado y cambia de color?',
      options: ['Iguana', 'Gecko', 'Camaleón', 'Tortuga'],
      correctIndex: 2,
      category: 'Animales',
      tag: 'Reptiles',
    ),
  ],
  'espacio': [
    TriviaQuestion(
      question: '¿Cuál es el planeta más cercano al Sol?',
      options: ['Mercurio', 'Venus', 'Marte', 'Tierra'],
      correctIndex: 0,
      category: 'Espacio',
      tag: 'Planetas',
    ),
    TriviaQuestion(
      question: '¿Cuál es el planeta más caliente del sistema solar?',
      options: ['Mercurio', 'Marte', 'Júpiter', 'Venus'],
      correctIndex: 3,
      category: 'Espacio',
      tag: 'Dato loco',
    ),
    TriviaQuestion(
      question: '¿Cuál es el planeta más grande del sistema solar?',
      options: ['Júpiter', 'Saturno', 'Neptuno', 'Urano'],
      correctIndex: 0,
      category: 'Espacio',
      tag: 'Planetas',
    ),
    TriviaQuestion(
      question: '¿Cuántos planetas tiene el sistema solar?',
      options: ['7', '9', '10', '8'],
      correctIndex: 3,
      category: 'Espacio',
      tag: 'Planetas',
    ),
    TriviaQuestion(
      question: '¿Quién fue la primera persona en pisar la Luna?',
      options: [
        'Yuri Gagarin',
        'Buzz Aldrin',
        'Neil Armstrong',
        'Michael Collins'
      ],
      correctIndex: 2,
      category: 'Espacio',
      tag: 'Misiones',
    ),
    TriviaQuestion(
      question: '¿Quién fue el primer ser humano en viajar al espacio?',
      options: [
        'Neil Armstrong',
        'Yuri Gagarin',
        'John Glenn',
        'Valentina Tereshkova'
      ],
      correctIndex: 1,
      category: 'Espacio',
      tag: 'Misiones',
    ),
    TriviaQuestion(
      question: '¿Cómo se llama nuestra galaxia?',
      options: [
        'Andrómeda',
        'Galaxia del Sombrero',
        'Nube de Magallanes',
        'Vía Láctea'
      ],
      correctIndex: 3,
      category: 'Espacio',
      tag: 'Galaxias',
    ),
    TriviaQuestion(
      question: '¿Cuánto tarda la luz del Sol en llegar a la Tierra?',
      options: [
        'Unos 8 segundos',
        'Unas 8 horas',
        'Unos 8 minutos',
        'Unos 8 días'
      ],
      correctIndex: 2,
      category: 'Espacio',
      tag: 'Dato loco',
    ),
    TriviaQuestion(
      question: '¿En qué año llegó el ser humano a la Luna por primera vez?',
      options: ['1959', '1965', '1969', '1975'],
      correctIndex: 2,
      category: 'Espacio',
      tag: 'Historia',
    ),
    TriviaQuestion(
      question: '¿Qué planeta gira "acostado", con su eje casi de lado?',
      options: ['Neptuno', 'Marte', 'Urano', 'Saturno'],
      correctIndex: 2,
      category: 'Espacio',
      tag: 'Planetas',
    ),
    TriviaQuestion(
      question: '¿Qué telescopio espacial, lanzado en 2021, sucedió al Hubble?',
      options: ['Kepler', 'Galileo', 'Spitzer', 'James Webb'],
      correctIndex: 3,
      category: 'Espacio',
      tag: 'Tecnología',
    ),
    TriviaQuestion(
      question: '¿Qué es Plutón actualmente?',
      options: [
        'Un planeta enano',
        'Un planeta',
        'Una estrella',
        'Una luna de Neptuno'
      ],
      correctIndex: 0,
      category: 'Espacio',
      tag: 'Curiosidad',
    ),
  ],
  'cuerpo': [
    TriviaQuestion(
      question: '¿Cuántos huesos tiene un adulto?',
      options: ['186', '226', '206', '306'],
      correctIndex: 2,
      category: 'Cuerpo humano',
      tag: 'Huesos',
    ),
    TriviaQuestion(
      question: '¿Cuál es el órgano más grande del cuerpo?',
      options: ['La piel', 'El hígado', 'Los pulmones', 'El intestino'],
      correctIndex: 0,
      category: 'Cuerpo humano',
      tag: 'Órganos',
    ),
    TriviaQuestion(
      question: '¿Cuál es el hueso más largo del cuerpo?',
      options: ['Húmero', 'Tibia', 'Fémur', 'Radio'],
      correctIndex: 2,
      category: 'Cuerpo humano',
      tag: 'Huesos',
    ),
    TriviaQuestion(
      question: '¿Dónde está el hueso más pequeño del cuerpo?',
      options: [
        'En la nariz',
        'En el dedo meñique del pie',
        'En el oído',
        'En la muñeca'
      ],
      correctIndex: 2,
      category: 'Cuerpo humano',
      tag: 'Huesos',
    ),
    TriviaQuestion(
      question:
          '¿Cuántos dientes tiene un adulto contando las muelas del juicio?',
      options: ['28', '30', '36', '32'],
      correctIndex: 3,
      category: 'Cuerpo humano',
      tag: 'Dientes',
    ),
    TriviaQuestion(
      question: '¿Qué tipo de sangre se considera donante universal?',
      options: ['A positivo', 'O negativo', 'AB positivo', 'B negativo'],
      correctIndex: 1,
      category: 'Cuerpo humano',
      tag: 'Sangre',
    ),
    TriviaQuestion(
      question: '¿Qué órganos filtran la sangre y producen la orina?',
      options: ['El hígado', 'El páncreas', 'Los riñones', 'El estómago'],
      correctIndex: 2,
      category: 'Cuerpo humano',
      tag: 'Órganos',
    ),
    TriviaQuestion(
      question: '¿Cuántas cavidades tiene el corazón humano?',
      options: ['4', '2', '3', '6'],
      correctIndex: 0,
      category: 'Cuerpo humano',
      tag: 'Corazón',
    ),
    TriviaQuestion(
      question: '¿Qué parte del ojo le da su color?',
      options: ['La pupila', 'La retina', 'El iris', 'La córnea'],
      correctIndex: 2,
      category: 'Cuerpo humano',
      tag: 'Sentidos',
    ),
    TriviaQuestion(
      question: '¿Qué vitamina produce el cuerpo al recibir luz del sol?',
      options: ['Vitamina A', 'Vitamina C', 'Vitamina D', 'Vitamina K'],
      correctIndex: 2,
      category: 'Cuerpo humano',
      tag: 'Salud',
    ),
    TriviaQuestion(
      question: '¿Cuántos dientes de leche tiene un niño?',
      options: ['16', '24', '28', '20'],
      correctIndex: 3,
      category: 'Cuerpo humano',
      tag: 'Dientes',
    ),
    TriviaQuestion(
      question: '¿Qué células de la sangre transportan el oxígeno?',
      options: ['Glóbulos blancos', 'Plaquetas', 'Neuronas', 'Glóbulos rojos'],
      correctIndex: 3,
      category: 'Cuerpo humano',
      tag: 'Sangre',
    ),
  ],
  'mundo': [
    TriviaQuestion(
      question: '¿Cuál es la capital de Canadá?',
      options: ['Ottawa', 'Toronto', 'Vancouver', 'Montreal'],
      correctIndex: 0,
      category: 'Geografía',
      tag: 'Capitales',
    ),
    TriviaQuestion(
      question: '¿Cuál es el país más grande del mundo?',
      options: ['China', 'Canadá', 'Estados Unidos', 'Rusia'],
      correctIndex: 3,
      category: 'Geografía',
      tag: 'Récord',
    ),
    TriviaQuestion(
      question: '¿Cuál es el océano más grande?',
      options: ['Atlántico', 'Índico', 'Ártico', 'Pacífico'],
      correctIndex: 3,
      category: 'Geografía',
      tag: 'Océanos',
    ),
    TriviaQuestion(
      question: '¿Cuál es la montaña más alta del mundo?',
      options: ['Everest', 'K2', 'Aconcagua', 'Kilimanjaro'],
      correctIndex: 0,
      category: 'Geografía',
      tag: 'Montañas',
    ),
    TriviaQuestion(
      question: '¿Cuál es el desierto cálido más grande del mundo?',
      options: ['Atacama', 'Gobi', 'Kalahari', 'Sahara'],
      correctIndex: 3,
      category: 'Geografía',
      tag: 'Desiertos',
    ),
    TriviaQuestion(
      question: '¿Cuál es el desierto no polar más seco del mundo?',
      options: ['Sahara', 'Gobi', 'Mojave', 'Atacama'],
      correctIndex: 3,
      category: 'Geografía',
      tag: 'Desiertos',
    ),
    TriviaQuestion(
      question: '¿Cuál es el río con más agua del mundo?',
      options: ['Nilo', 'Misisipi', 'Yangtsé', 'Amazonas'],
      correctIndex: 3,
      category: 'Geografía',
      tag: 'Ríos',
    ),
    TriviaQuestion(
      question: '¿En qué país están las pirámides de Guiza?',
      options: ['México', 'Perú', 'Egipto', 'Sudán'],
      correctIndex: 2,
      category: 'Geografía',
      tag: 'Monumentos',
    ),
    TriviaQuestion(
      question: '¿Cuál es la capital de Japón?',
      options: ['Kioto', 'Osaka', 'Seúl', 'Tokio'],
      correctIndex: 3,
      category: 'Geografía',
      tag: 'Capitales',
    ),
    TriviaQuestion(
      question: '¿Cuál es el país más pequeño del mundo?',
      options: ['Mónaco', 'San Marino', 'Liechtenstein', 'Ciudad del Vaticano'],
      correctIndex: 3,
      category: 'Geografía',
      tag: 'Récord',
    ),
    TriviaQuestion(
      question: '¿Cuál es la montaña más alta de América?',
      options: ['Aconcagua', 'Chimborazo', 'Denali', 'Huascarán'],
      correctIndex: 0,
      category: 'Geografía',
      tag: 'Montañas',
    ),
    TriviaQuestion(
      question: '¿Cuántos países independientes hay en Sudamérica?',
      options: ['9', '12', '10', '14'],
      correctIndex: 1,
      category: 'Geografía',
      tag: 'Continentes',
    ),
    TriviaQuestion(
      question: '¿En qué país se encuentra Machu Picchu?',
      options: ['Bolivia', 'Perú', 'Ecuador', 'Chile'],
      correctIndex: 1,
      category: 'Geografía',
      tag: 'Monumentos',
    ),
    TriviaQuestion(
      question:
          '¿Qué lago, entre Perú y Bolivia, es famoso por ser uno de los navegables más altos del mundo?',
      options: ['Titicaca', 'Victoria', 'Baikal', 'Tota'],
      correctIndex: 0,
      category: 'Geografía',
      tag: 'Lagos',
    ),
  ],
  'banderas': [
    TriviaQuestion(
      question: '¿Qué país tiene una hoja de arce roja en su bandera?',
      options: ['Canadá', 'Suiza', 'Austria', 'Perú'],
      correctIndex: 0,
      category: 'Banderas',
      tag: 'América',
    ),
    TriviaQuestion(
      question: '¿Qué país tiene un cedro verde en el centro de su bandera?',
      options: ['Siria', 'Chipre', 'Grecia', 'Líbano'],
      correctIndex: 3,
      category: 'Banderas',
      tag: 'Asia',
    ),
    TriviaQuestion(
      question: '¿Qué país tiene un dragón rojo en su bandera?',
      options: ['China', 'Escocia', 'Vietnam', 'Gales'],
      correctIndex: 3,
      category: 'Banderas',
      tag: 'Europa',
    ),
    TriviaQuestion(
      question:
          '¿Qué país tiene una bandera con forma de dos triángulos, uno sobre otro?',
      options: ['Suiza', 'Nepal', 'Bután', 'Sri Lanka'],
      correctIndex: 1,
      category: 'Banderas',
      tag: 'Rareza',
    ),
    TriviaQuestion(
      question: '¿Qué país tiene un sol con cara en el centro de su bandera?',
      options: ['Japón', 'Perú', 'Bolivia', 'Argentina'],
      correctIndex: 3,
      category: 'Banderas',
      tag: 'América',
    ),
    TriviaQuestion(
      question: '¿De qué colores es la bandera de Italia?',
      options: [
        'Azul, blanco y rojo',
        'Verde, blanco y rojo',
        'Verde, amarillo y rojo',
        'Negro, rojo y amarillo'
      ],
      correctIndex: 1,
      category: 'Banderas',
      tag: 'Europa',
    ),
    TriviaQuestion(
      question:
          '¿Qué país tiene una bandera verde con un rombo amarillo y un círculo azul?',
      options: ['Brasil', 'Portugal', 'Jamaica', 'Bolivia'],
      correctIndex: 0,
      category: 'Banderas',
      tag: 'América',
    ),
    TriviaQuestion(
      question:
          '¿En qué bandera aparece un águila sobre un nopal comiéndose una serpiente?',
      options: ['Ecuador', 'Albania', 'Egipto', 'México'],
      correctIndex: 3,
      category: 'Banderas',
      tag: 'América',
    ),
    TriviaQuestion(
      question:
          '¿Qué país tiene una bandera blanca y roja con un cuadro azul y una estrella blanca?',
      options: ['Cuba', 'Panamá', 'Honduras', 'Chile'],
      correctIndex: 3,
      category: 'Banderas',
      tag: 'América',
    ),
    TriviaQuestion(
      question:
          '¿Qué país tiene una bandera roja con una estrella amarilla grande y cuatro pequeñas?',
      options: ['Vietnam', 'Corea del Norte', 'China', 'Marruecos'],
      correctIndex: 2,
      category: 'Banderas',
      tag: 'Asia',
    ),
    TriviaQuestion(
      question: '¿Cuántas estrellas tiene la bandera de Estados Unidos?',
      options: ['13', '48', '52', '50'],
      correctIndex: 3,
      category: 'Banderas',
      tag: 'América',
    ),
    TriviaQuestion(
      question: '¿De qué colores es la bandera de Alemania?',
      options: [
        'Rojo, blanco y negro',
        'Negro, blanco y amarillo',
        'Negro, rojo y amarillo',
        'Rojo, amarillo y azul'
      ],
      correctIndex: 2,
      category: 'Banderas',
      tag: 'Europa',
    ),
  ],
  'ciencia': [
    TriviaQuestion(
      question:
          '¿Qué gas toman las plantas del aire para hacer la fotosíntesis?',
      options: ['Oxígeno', 'Nitrógeno', 'Helio', 'Dióxido de carbono'],
      correctIndex: 3,
      category: 'Ciencia',
      tag: 'Plantas',
    ),
    TriviaQuestion(
      question: '¿A cuántos grados Celsius se congela el agua?',
      options: ['4 °C', '-10 °C', '10 °C', '0 °C'],
      correctIndex: 3,
      category: 'Ciencia',
      tag: 'Agua',
    ),
    TriviaQuestion(
      question: '¿Cuál es el símbolo químico del oro?',
      options: ['Ag', 'Go', 'Or', 'Au'],
      correctIndex: 3,
      category: 'Ciencia',
      tag: 'Química',
    ),
    TriviaQuestion(
      question: '¿Qué fórmula química representa el agua?',
      options: ['CO₂', 'H₂O', 'O₂', 'NaCl'],
      correctIndex: 1,
      category: 'Ciencia',
      tag: 'Química',
    ),
    TriviaQuestion(
      question: '¿Qué científico describió la ley de la gravedad universal?',
      options: [
        'Galileo Galilei',
        'Albert Einstein',
        'Isaac Newton',
        'Charles Darwin'
      ],
      correctIndex: 2,
      category: 'Ciencia',
      tag: 'Científicos',
    ),
    TriviaQuestion(
      question: '¿Qué metal es líquido a temperatura ambiente?',
      options: ['Hierro', 'Aluminio', 'Mercurio', 'Plata'],
      correctIndex: 2,
      category: 'Ciencia',
      tag: 'Química',
    ),
    TriviaQuestion(
      question: '¿Qué parte de la planta absorbe el agua del suelo?',
      options: ['La raíz', 'Las hojas', 'La flor', 'El tallo'],
      correctIndex: 0,
      category: 'Ciencia',
      tag: 'Plantas',
    ),
    TriviaQuestion(
      question: '¿Cuál es el gas más abundante en el aire que respiramos?',
      options: ['Nitrógeno', 'Oxígeno', 'Dióxido de carbono', 'Hidrógeno'],
      correctIndex: 0,
      category: 'Ciencia',
      tag: 'Aire',
    ),
    TriviaQuestion(
      question: '¿Cuál es el árbol más alto del mundo?',
      options: ['Ceiba', 'Secuoya roja', 'Palma de cera', 'Baobab'],
      correctIndex: 1,
      category: 'Ciencia',
      tag: 'Récord',
    ),
    TriviaQuestion(
      question: '¿Cuál es el árbol nacional de Colombia?',
      options: ['Ceiba', 'Guayacán', 'Roble', 'Palma de cera'],
      correctIndex: 3,
      category: 'Ciencia',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question: '¿Qué mide la escala de Richter?',
      options: [
        'La velocidad del viento',
        'La temperatura',
        'La cantidad de lluvia',
        'La fuerza de los sismos'
      ],
      correctIndex: 3,
      category: 'Ciencia',
      tag: 'Planeta',
    ),
    TriviaQuestion(
      question: '¿Qué instrumento mide la presión del aire?',
      options: ['Termómetro', 'Anemómetro', 'Barómetro', 'Higrómetro'],
      correctIndex: 2,
      category: 'Ciencia',
      tag: 'Clima',
    ),
    TriviaQuestion(
      question: '¿Cómo se llama la energía que se obtiene del viento?',
      options: ['Solar', 'Eólica', 'Geotérmica', 'Hidráulica'],
      correctIndex: 1,
      category: 'Ciencia',
      tag: 'Energía',
    ),
  ],
  'oceanos': [
    TriviaQuestion(
      question: '¿Por dónde respiran las ballenas?',
      options: [
        'Por branquias',
        'Por la piel',
        'Por el espiráculo',
        'Por la boca'
      ],
      correctIndex: 2,
      category: 'Océanos',
      tag: 'Mamíferos',
    ),
    TriviaQuestion(
      question:
          '¿En qué animal es el papá quien lleva a las crías antes de nacer?',
      options: ['Pulpo', 'Tortuga marina', 'Pez payaso', 'Caballito de mar'],
      correctIndex: 3,
      category: 'Océanos',
      tag: 'Dato loco',
    ),
    TriviaQuestion(
      question: '¿Cuál es el pez más grande del mundo?',
      options: [
        'Tiburón blanco',
        'Ballena azul',
        'Manta raya',
        'Tiburón ballena'
      ],
      correctIndex: 3,
      category: 'Océanos',
      tag: 'Récord',
    ),
    TriviaQuestion(
      question: '¿Cuál es el punto más profundo del océano?',
      options: [
        'Fosa de Puerto Rico',
        'Triángulo de las Bermudas',
        'Fosa de Java',
        'Fosa de las Marianas'
      ],
      correctIndex: 3,
      category: 'Océanos',
      tag: 'Récord',
    ),
    TriviaQuestion(
      question:
          '¿Qué parte de la Tierra está cubierta por agua, aproximadamente?',
      options: ['50 %', '61 %', '85 %', '71 %'],
      correctIndex: 3,
      category: 'Océanos',
      tag: 'Planeta',
    ),
    TriviaQuestion(
      question: '¿Cuál es el arrecife de coral más grande del mundo?',
      options: [
        'Gran Barrera de Coral',
        'Arrecife Mesoamericano',
        'Arrecife de San Andrés',
        'Arrecife de Florida'
      ],
      correctIndex: 0,
      category: 'Océanos',
      tag: 'Arrecifes',
    ),
    TriviaQuestion(
      question: '¿Qué animal marino tiene la sangre azul?',
      options: ['Delfín', 'Tiburón', 'Pulpo', 'Foca'],
      correctIndex: 2,
      category: 'Océanos',
      tag: 'Dato loco',
    ),
    TriviaQuestion(
      question: '¿Cuántos océanos reconoce hoy la mayoría de geógrafos?',
      options: ['3', '4', '5', '7'],
      correctIndex: 2,
      category: 'Océanos',
      tag: 'Planeta',
    ),
    TriviaQuestion(
      question: '¿Cuál es el océano más pequeño?',
      options: ['Índico', 'Austral', 'Atlántico', 'Ártico'],
      correctIndex: 3,
      category: 'Océanos',
      tag: 'Planeta',
    ),
    TriviaQuestion(
      question: '¿Qué animal marino no tiene cerebro, corazón ni huesos?',
      options: ['Medusa', 'Pulpo', 'Calamar', 'Cangrejo'],
      correctIndex: 0,
      category: 'Océanos',
      tag: 'Rareza',
    ),
    TriviaQuestion(
      question: '¿Dónde ponen sus huevos las tortugas marinas?',
      options: [
        'En el fondo del mar',
        'Entre los corales',
        'En los ríos',
        'En la arena de la playa'
      ],
      correctIndex: 3,
      category: 'Océanos',
      tag: 'Reptiles',
    ),
    TriviaQuestion(
      question:
          '¿En qué mar el agua es tan salada que las personas flotan fácilmente?',
      options: ['Mar Rojo', 'Mar Caribe', 'Mar Muerto', 'Mar Negro'],
      correctIndex: 2,
      category: 'Océanos',
      tag: 'Mares',
    ),
  ],
  'dinos': [
    TriviaQuestion(
      question: '¿Qué significa la palabra "dinosaurio"?',
      options: [
        'Gran reptil',
        'Animal antiguo',
        'Diente gigante',
        'Lagarto terrible'
      ],
      correctIndex: 3,
      category: 'Dinosaurios',
      tag: 'Palabras',
    ),
    TriviaQuestion(
      question: '¿Qué dinosaurio tenía placas en la espalda y púas en la cola?',
      options: ['Triceratops', 'Estegosaurio', 'Velociraptor', 'Braquiosaurio'],
      correctIndex: 1,
      category: 'Dinosaurios',
      tag: 'Especies',
    ),
    TriviaQuestion(
      question: '¿Qué dinosaurio tenía tres cuernos en la cara?',
      options: [
        'Anquilosaurio',
        'Parasaurolophus',
        'Espinosaurio',
        'Triceratops'
      ],
      correctIndex: 3,
      category: 'Dinosaurios',
      tag: 'Especies',
    ),
    TriviaQuestion(
      question:
          '¿Hace cuántos años se extinguieron los dinosaurios (salvo las aves)?',
      options: [
        'Unos 6.000',
        'Unos 6 millones',
        'Unos 660 millones',
        'Unos 66 millones'
      ],
      correctIndex: 3,
      category: 'Dinosaurios',
      tag: 'Historia',
    ),
    TriviaQuestion(
      question:
          '¿Qué animales de hoy descienden directamente de los dinosaurios?',
      options: ['Las aves', 'Los cocodrilos', 'Los lagartos', 'Las tortugas'],
      correctIndex: 0,
      category: 'Dinosaurios',
      tag: 'Evolución',
    ),
    TriviaQuestion(
      question: '¿Cómo se llaman los científicos que estudian fósiles?',
      options: ['Arqueólogos', 'Geólogos', 'Paleontólogos', 'Biólogos marinos'],
      correctIndex: 2,
      category: 'Dinosaurios',
      tag: 'Ciencia',
    ),
    TriviaQuestion(
      question:
          '¿Qué dinosaurio de cuello larguísimo comía hojas de árboles altos?',
      options: [
        'Tiranosaurio rex',
        'Velociraptor',
        'Estegosaurio',
        'Braquiosaurio'
      ],
      correctIndex: 3,
      category: 'Dinosaurios',
      tag: 'Especies',
    ),
    TriviaQuestion(
      question: '¿Qué era el pterodáctilo?',
      options: [
        'Un dinosaurio volador',
        'Un ave primitiva',
        'Un reptil volador que no era dinosaurio',
        'Un murciélago gigante'
      ],
      correctIndex: 2,
      category: 'Dinosaurios',
      tag: 'Trampa',
    ),
    TriviaQuestion(
      question:
          '¿Qué causó, muy probablemente, la extinción de los dinosaurios?',
      options: [
        'El impacto de un asteroide',
        'Una glaciación',
        'Una plaga',
        'La falta de agua'
      ],
      correctIndex: 0,
      category: 'Dinosaurios',
      tag: 'Historia',
    ),
    TriviaQuestion(
      question: '¿En qué era geológica vivieron los dinosaurios?',
      options: ['Paleozoica', 'Mesozoica', 'Cenozoica', 'Precámbrica'],
      correctIndex: 1,
      category: 'Dinosaurios',
      tag: 'Historia',
    ),
    TriviaQuestion(
      question:
          '¿Qué dinosaurio carnívoro, más largo que el T. rex, vivía cerca del agua?',
      options: ['Alosaurio', 'Velociraptor', 'Carnotauro', 'Espinosaurio'],
      correctIndex: 3,
      category: 'Dinosaurios',
      tag: 'Especies',
    ),
    TriviaQuestion(
      question: '¿De qué tamaño era realmente el velociraptor?',
      options: [
        'Como un autobús',
        'Como un pavo grande',
        'Como un elefante',
        'Como una jirafa'
      ],
      correctIndex: 1,
      category: 'Dinosaurios',
      tag: 'Trampa',
    ),
  ],
  'comida': [
    TriviaQuestion(
      question: '¿De qué país es originario el sushi?',
      options: ['China', 'Corea del Sur', 'Tailandia', 'Japón'],
      correctIndex: 3,
      category: 'Comida',
      tag: 'Asia',
    ),
    TriviaQuestion(
      question: '¿De qué planta se obtiene el chocolate?',
      options: ['Cacao', 'Café', 'Vainilla', 'Caña de azúcar'],
      correctIndex: 0,
      category: 'Comida',
      tag: 'Ingredientes',
    ),
    TriviaQuestion(
      question: '¿Cuál es el ingrediente principal del hummus?',
      options: ['Garbanzos', 'Lentejas', 'Fríjoles', 'Arvejas'],
      correctIndex: 0,
      category: 'Comida',
      tag: 'Ingredientes',
    ),
    TriviaQuestion(
      question: '¿Cuál es la especia más cara del mundo?',
      options: ['Azafrán', 'Vainilla', 'Canela', 'Pimienta'],
      correctIndex: 0,
      category: 'Comida',
      tag: 'Récord',
    ),
    TriviaQuestion(
      question: '¿De qué país es la paella?',
      options: ['México', 'Italia', 'Portugal', 'España'],
      correctIndex: 3,
      category: 'Comida',
      tag: 'Europa',
    ),
    TriviaQuestion(
      question: '¿De dónde es originaria la papa?',
      options: [
        'De los Andes de Sudamérica',
        'De Europa',
        'De Asia',
        'De África'
      ],
      correctIndex: 0,
      category: 'Comida',
      tag: 'Orígenes',
    ),
    TriviaQuestion(
      question: '¿Qué fruta tiene las semillas por fuera?',
      options: ['Kiwi', 'Fresa', 'Mango', 'Guayaba'],
      correctIndex: 1,
      category: 'Comida',
      tag: 'Frutas',
    ),
    TriviaQuestion(
      question:
          '¿Qué plato colombiano lleva fríjoles, arroz, chicharrón, huevo, aguacate y arepa?',
      options: ['Ajiaco', 'Bandeja paisa', 'Sancocho', 'Lechona'],
      correctIndex: 1,
      category: 'Comida',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question: '¿Qué hierba no puede faltar en el ajiaco santafereño?',
      options: ['Guascas', 'Cilantro', 'Perejil', 'Albahaca'],
      correctIndex: 0,
      category: 'Comida',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question: '¿En qué país el ceviche es considerado plato nacional?',
      options: ['Perú', 'México', 'Chile', 'Ecuador'],
      correctIndex: 0,
      category: 'Comida',
      tag: 'América',
    ),
    TriviaQuestion(
      question: '¿Qué se fermenta para hacer yogur?',
      options: ['Jugo de fruta', 'Agua', 'Leche', 'Harina'],
      correctIndex: 2,
      category: 'Comida',
      tag: 'Ingredientes',
    ),
    TriviaQuestion(
      question: 'Para la ciencia, ¿cuál de estos alimentos es una fruta?',
      options: ['Zanahoria', 'Lechuga', 'Tomate', 'Papa'],
      correctIndex: 2,
      category: 'Comida',
      tag: 'Trampa',
    ),
  ],
  'inventos': [
    TriviaQuestion(
      question:
          '¿Quiénes hicieron el primer vuelo en avión con motor, en 1903?',
      options: [
        'Los hermanos Lumière',
        'Los hermanos Wright',
        'Alberto Santos-Dumont',
        'Los hermanos Montgolfier'
      ],
      correctIndex: 1,
      category: 'Inventos',
      tag: 'Transporte',
    ),
    TriviaQuestion(
      question: '¿Quién creó la imprenta de tipos móviles en Europa?',
      options: [
        'Johannes Gutenberg',
        'Leonardo da Vinci',
        'Galileo Galilei',
        'Thomas Edison'
      ],
      correctIndex: 0,
      category: 'Inventos',
      tag: 'Comunicación',
    ),
    TriviaQuestion(
      question: '¿Quién creó la World Wide Web?',
      options: [
        'Bill Gates',
        'Steve Jobs',
        'Tim Berners-Lee',
        'Mark Zuckerberg'
      ],
      correctIndex: 2,
      category: 'Inventos',
      tag: 'Internet',
    ),
    TriviaQuestion(
      question: '¿Qué científica ganó dos premios Nobel en ciencias distintas?',
      options: [
        'Rosalind Franklin',
        'Ada Lovelace',
        'Jane Goodall',
        'Marie Curie'
      ],
      correctIndex: 3,
      category: 'Inventos',
      tag: 'Científicas',
    ),
    TriviaQuestion(
      question: '¿Quién es considerada la primera programadora de la historia?',
      options: ['Grace Hopper', 'Ada Lovelace', 'Marie Curie', 'Hedy Lamarr'],
      correctIndex: 1,
      category: 'Inventos',
      tag: 'Científicas',
    ),
    TriviaQuestion(
      question: '¿Qué descubrió Alexander Fleming en 1928?',
      options: ['La primera vacuna', 'La penicilina', 'La insulina', 'El ADN'],
      correctIndex: 1,
      category: 'Inventos',
      tag: 'Medicina',
    ),
    TriviaQuestion(
      question: '¿Qué inventaron los hermanos Lumière?',
      options: ['El teléfono', 'La radio', 'La bombilla', 'El cinematógrafo'],
      correctIndex: 3,
      category: 'Inventos',
      tag: 'Cine',
    ),
    TriviaQuestion(
      question: '¿En qué país se inventó el papel?',
      options: ['Egipto', 'China', 'Grecia', 'India'],
      correctIndex: 1,
      category: 'Inventos',
      tag: 'Antigüedad',
    ),
    TriviaQuestion(
      question: '¿Qué significa la sigla GPS en español?',
      options: [
        'Guía Personal de Satélites',
        'Gran Panel Solar',
        'Sistema de Posicionamiento Global',
        'Grupo de Puntos Satelitales'
      ],
      correctIndex: 2,
      category: 'Inventos',
      tag: 'Tecnología',
    ),
    TriviaQuestion(
      question:
          '¿Qué inventor es famoso por perfeccionar y popularizar la bombilla eléctrica?',
      options: [
        'Thomas Edison',
        'Nikola Tesla',
        'Benjamin Franklin',
        'Alexander Graham Bell'
      ],
      correctIndex: 0,
      category: 'Inventos',
      tag: 'Electricidad',
    ),
    TriviaQuestion(
      question: '¿Qué demostró Benjamin Franklin con su famosa cometa?',
      options: [
        'Que existe la gravedad',
        'Cómo funciona el magnetismo',
        'La velocidad del viento',
        'Que los rayos son electricidad'
      ],
      correctIndex: 3,
      category: 'Inventos',
      tag: 'Electricidad',
    ),
    TriviaQuestion(
      question:
          '¿Qué invento ayudó a los marineros a orientarse hacia el norte?',
      options: [
        'El telescopio',
        'La brújula',
        'El reloj de arena',
        'El sextante'
      ],
      correctIndex: 1,
      category: 'Inventos',
      tag: 'Navegación',
    ),
  ],
  'arte': [
    TriviaQuestion(
      question: '¿Quién pintó "La noche estrellada"?',
      options: [
        'Claude Monet',
        'Vincent van Gogh',
        'Pablo Picasso',
        'Salvador Dalí'
      ],
      correctIndex: 1,
      category: 'Arte y cultura',
      tag: 'Pintura',
    ),
    TriviaQuestion(
      question: '¿Quién escribió "Cien años de soledad"?',
      options: [
        'Mario Vargas Llosa',
        'Julio Cortázar',
        'Gabriel García Márquez',
        'Jorge Luis Borges'
      ],
      correctIndex: 2,
      category: 'Arte y cultura',
      tag: 'Libros',
    ),
    TriviaQuestion(
      question: '¿Quién escribió "Don Quijote de la Mancha"?',
      options: [
        'Lope de Vega',
        'Francisco de Quevedo',
        'Calderón de la Barca',
        'Miguel de Cervantes'
      ],
      correctIndex: 3,
      category: 'Arte y cultura',
      tag: 'Libros',
    ),
    TriviaQuestion(
      question: '¿Cuántas teclas tiene un piano estándar?',
      options: ['66', '76', '98', '88'],
      correctIndex: 3,
      category: 'Arte y cultura',
      tag: 'Música',
    ),
    TriviaQuestion(
      question:
          '¿Qué artista colombiano es famoso por sus figuras voluminosas?',
      options: [
        'Alejandro Obregón',
        'Fernando Botero',
        'Enrique Grau',
        'Édgar Negret'
      ],
      correctIndex: 1,
      category: 'Arte y cultura',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question: '¿Cuántas cuerdas tiene un violín?',
      options: ['3', '4', '5', '6'],
      correctIndex: 1,
      category: 'Arte y cultura',
      tag: 'Música',
    ),
    TriviaQuestion(
      question:
          '¿Qué compositor siguió creando música después de quedar sordo?',
      options: [
        'Wolfgang Amadeus Mozart',
        'Johann Sebastian Bach',
        'Frédéric Chopin',
        'Ludwig van Beethoven'
      ],
      correctIndex: 3,
      category: 'Arte y cultura',
      tag: 'Música',
    ),
    TriviaQuestion(
      question: '¿En qué museo se exhibe la Mona Lisa?',
      options: [
        'Museo del Louvre',
        'Museo del Prado',
        'MoMA',
        'Galería Uffizi'
      ],
      correctIndex: 0,
      category: 'Arte y cultura',
      tag: 'Museos',
    ),
    TriviaQuestion(
      question:
          '¿Qué artista mexicana es famosa por sus autorretratos con flores en el pelo?',
      options: [
        'Frida Kahlo',
        'Remedios Varo',
        'Leonora Carrington',
        'María Izquierdo'
      ],
      correctIndex: 0,
      category: 'Arte y cultura',
      tag: 'Pintura',
    ),
    TriviaQuestion(
      question: '¿Quién pintó el techo de la Capilla Sixtina?',
      options: ['Leonardo da Vinci', 'Rafael', 'Botticelli', 'Miguel Ángel'],
      correctIndex: 3,
      category: 'Arte y cultura',
      tag: 'Pintura',
    ),
    TriviaQuestion(
      question:
          '¿Cuál de estos es uno de los tres instrumentos del vallenato tradicional?',
      options: ['Guacharaca', 'Tiple', 'Arpa', 'Marimba'],
      correctIndex: 0,
      category: 'Arte y cultura',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question: '¿Quién escribió "El principito"?',
      options: [
        'Antoine de Saint-Exupéry',
        'Julio Verne',
        'Victor Hugo',
        'Alejandro Dumas'
      ],
      correctIndex: 0,
      category: 'Arte y cultura',
      tag: 'Libros',
    ),
  ],
  'deportes': [
    TriviaQuestion(
      question:
          '¿Cada cuántos años se celebran los Juegos Olímpicos de verano?',
      options: ['2', '3', '4', '5'],
      correctIndex: 2,
      category: 'Deportes',
      tag: 'Olímpicos',
    ),
    TriviaQuestion(
      question:
          '¿Cuántos jugadores tiene en la cancha cada equipo de voleibol?',
      options: ['5', '7', '6', '9'],
      correctIndex: 2,
      category: 'Deportes',
      tag: 'Reglas',
    ),
    TriviaQuestion(
      question: '¿Cuál es el deporte nacional de Colombia?',
      options: ['Tejo', 'Fútbol', 'Ciclismo', 'Béisbol'],
      correctIndex: 0,
      category: 'Deportes',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question:
          '¿Cuántos puntos vale una canasta desde detrás de la línea de triple?',
      options: ['3', '1', '2', '4'],
      correctIndex: 0,
      category: 'Deportes',
      tag: 'Baloncesto',
    ),
    TriviaQuestion(
      question: '¿Cuánto mide una maratón?',
      options: ['21 km', '50 km', '10 km', '42,195 km'],
      correctIndex: 3,
      category: 'Deportes',
      tag: 'Atletismo',
    ),
    TriviaQuestion(
      question: '¿Qué ciclista colombiano ganó el Tour de Francia en 2019?',
      options: [
        'Nairo Quintana',
        'Rigoberto Urán',
        'Egan Bernal',
        'Miguel Ángel López'
      ],
      correctIndex: 2,
      category: 'Deportes',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question: '¿En qué deporte ganó Mariana Pajón dos oros olímpicos?',
      options: ['Natación', 'Atletismo', 'BMX', 'Patinaje'],
      correctIndex: 2,
      category: 'Deportes',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question: '¿Qué torneo de tenis de Grand Slam se juega sobre césped?',
      options: [
        'Roland Garros',
        'US Open',
        'Abierto de Australia',
        'Wimbledon'
      ],
      correctIndex: 3,
      category: 'Deportes',
      tag: 'Tenis',
    ),
    TriviaQuestion(
      question: '¿Qué representan los cinco aros olímpicos?',
      options: [
        'Cinco deportes',
        'Cinco fundadores',
        'La unión de los continentes',
        'Cinco ciudades sede'
      ],
      correctIndex: 2,
      category: 'Deportes',
      tag: 'Olímpicos',
    ),
    TriviaQuestion(
      question: '¿En qué deporte se batea un "jonrón"?',
      options: ['Béisbol', 'Críquet', 'Rugby', 'Golf'],
      correctIndex: 0,
      category: 'Deportes',
      tag: 'Reglas',
    ),
    TriviaQuestion(
      question:
          '¿Cuántos jugadores tiene en el campo cada equipo de rugby tradicional?',
      options: ['7', '11', '13', '15'],
      correctIndex: 3,
      category: 'Deportes',
      tag: 'Reglas',
    ),
    TriviaQuestion(
      question: '¿Qué deporte se juega con raqueta y un volante de plumas?',
      options: ['Squash', 'Pádel', 'Tenis de mesa', 'Bádminton'],
      correctIndex: 3,
      category: 'Deportes',
      tag: 'Raqueta',
    ),
    TriviaQuestion(
      question: '¿Qué ciudad será sede de los Juegos Olímpicos de 2028?',
      options: ['París', 'Los Ángeles', 'Brisbane', 'Tokio'],
      correctIndex: 1,
      category: 'Deportes',
      tag: 'Olímpicos',
    ),
  ],
  'idiomas': [
    TriviaQuestion(
      question: '¿Cuántas letras tiene el abecedario español?',
      options: ['26', '27', '28', '29'],
      correctIndex: 1,
      category: 'Idiomas',
      tag: 'Español',
    ),
    TriviaQuestion(
      question: '¿Qué es un palíndromo?',
      options: [
        'Una palabra con todas las vocales',
        'Una palabra que se lee igual al revés',
        'Un sinónimo',
        'Una palabra extranjera'
      ],
      correctIndex: 1,
      category: 'Idiomas',
      tag: 'Juego de palabras',
    ),
    TriviaQuestion(
      question: '¿Cuál es la lengua con más hablantes nativos del mundo?',
      options: ['Inglés', 'Español', 'Hindi', 'Chino mandarín'],
      correctIndex: 3,
      category: 'Idiomas',
      tag: 'Récord',
    ),
    TriviaQuestion(
      question: '¿Qué idioma es el oficial de Brasil?',
      options: ['Español', 'Brasileño', 'Portugués', 'Francés'],
      correctIndex: 2,
      category: 'Idiomas',
      tag: 'América',
    ),
    TriviaQuestion(
      question: '¿Cómo se dice "gracias" en japonés?',
      options: ['Konnichiwa', 'Sayōnara', 'Kawaii', 'Arigatō'],
      correctIndex: 3,
      category: 'Idiomas',
      tag: 'Asia',
    ),
    TriviaQuestion(
      question: '¿Cuál de estas palabras tiene las cinco vocales?',
      options: ['Elefante', 'Murciélago', 'Mariposa', 'Canguro'],
      correctIndex: 1,
      category: 'Idiomas',
      tag: 'Juego de palabras',
    ),
    TriviaQuestion(
      question: '¿Cuántos idiomas oficiales tiene Suiza?',
      options: ['4', '1', '2', '3'],
      correctIndex: 0,
      category: 'Idiomas',
      tag: 'Europa',
    ),
    TriviaQuestion(
      question: '¿Qué lengua hablaban los incas?',
      options: ['Náhuatl', 'Maya', 'Guaraní', 'Quechua'],
      correctIndex: 3,
      category: 'Idiomas',
      tag: 'Lenguas indígenas',
    ),
    TriviaQuestion(
      question: '¿De qué lengua viene la palabra "chocolate"?',
      options: ['Náhuatl', 'Árabe', 'Latín', 'Quechua'],
      correctIndex: 0,
      category: 'Idiomas',
      tag: 'Orígenes',
    ),
    TriviaQuestion(
      question: '¿Cuál es un antónimo de "generoso"?',
      options: ['Amable', 'Tacaño', 'Rico', 'Alegre'],
      correctIndex: 1,
      category: 'Idiomas',
      tag: 'Español',
    ),
    TriviaQuestion(
      question: '¿Cómo se saluda informalmente en italiano?',
      options: ['Hola', 'Ciao', 'Hallo', 'Salut'],
      correctIndex: 1,
      category: 'Idiomas',
      tag: 'Europa',
    ),
    TriviaQuestion(
      question: '¿En qué idioma "danke" significa "gracias"?',
      options: ['Alemán', 'Neerlandés', 'Sueco', 'Danés'],
      correctIndex: 0,
      category: 'Idiomas',
      tag: 'Europa',
    ),
  ],
  'mates': [
    TriviaQuestion(
      question: '¿Cuánto es 15 × 4?',
      options: ['60', '45', '55', '64'],
      correctIndex: 0,
      category: 'Matemáticas',
      tag: 'Cálculo',
    ),
    TriviaQuestion(
      question: '¿Cuántos lados tiene un octágono?',
      options: ['6', '7', '10', '8'],
      correctIndex: 3,
      category: 'Matemáticas',
      tag: 'Figuras',
    ),
    TriviaQuestion(
      question: '¿Qué número representa la L en números romanos?',
      options: ['5', '50', '100', '500'],
      correctIndex: 1,
      category: 'Matemáticas',
      tag: 'Romanos',
    ),
    TriviaQuestion(
      question: '¿Cuánto suman los ángulos internos de un triángulo?',
      options: ['90°', '270°', '360°', '180°'],
      correctIndex: 3,
      category: 'Matemáticas',
      tag: 'Geometría',
    ),
    TriviaQuestion(
      question: '¿Cuál es el único número primo par?',
      options: ['2', '0', '1', '4'],
      correctIndex: 0,
      category: 'Matemáticas',
      tag: 'Números',
    ),
    TriviaQuestion(
      question: '¿Cuál es la raíz cuadrada de 144?',
      options: ['10', '12', '14', '16'],
      correctIndex: 1,
      category: 'Matemáticas',
      tag: 'Cálculo',
    ),
    TriviaQuestion(
      question: '¿Cuántos días tiene un año bisiesto?',
      options: ['364', '366', '365', '367'],
      correctIndex: 1,
      category: 'Matemáticas',
      tag: 'Calendario',
    ),
    TriviaQuestion(
      question: '¿Cuántos segundos hay en una hora?',
      options: ['600', '3.600', '6.000', '36.000'],
      correctIndex: 1,
      category: 'Matemáticas',
      tag: 'Tiempo',
    ),
    TriviaQuestion(
      question: '¿Cuánto es el 25 % de 200?',
      options: ['25', '50', '40', '75'],
      correctIndex: 1,
      category: 'Matemáticas',
      tag: 'Porcentajes',
    ),
    TriviaQuestion(
      question: '¿Qué número sigue en la serie 1, 1, 2, 3, 5, 8…?',
      options: ['11', '13', '12', '15'],
      correctIndex: 1,
      category: 'Matemáticas',
      tag: 'Acertijo',
    ),
    TriviaQuestion(
      question: '¿Cuántos ceros tiene un millón?',
      options: ['5', '7', '9', '6'],
      correctIndex: 3,
      category: 'Matemáticas',
      tag: 'Números',
    ),
    TriviaQuestion(
      question: '¿Cuál es el valor aproximado del número pi?',
      options: ['2,14', '3,41', '3,14', '4,13'],
      correctIndex: 2,
      category: 'Matemáticas',
      tag: 'Números',
    ),
  ],
  'culturas': [
    TriviaQuestion(
      question:
          '¿En qué país se celebra el Día de Muertos con altares y flores de cempasúchil?',
      options: ['Argentina', 'España', 'Chile', 'México'],
      correctIndex: 3,
      category: 'Culturas del mundo',
      tag: 'Fiestas',
    ),
    TriviaQuestion(
      question: '¿De qué país es el arte de doblar papel llamado origami?',
      options: ['China', 'Corea del Sur', 'India', 'Japón'],
      correctIndex: 3,
      category: 'Culturas del mundo',
      tag: 'Tradiciones',
    ),
    TriviaQuestion(
      question:
          '¿Qué festival de la India se celebra lanzando polvos de colores?',
      options: ['Holi', 'Diwali', 'Navratri', 'Pongal'],
      correctIndex: 0,
      category: 'Culturas del mundo',
      tag: 'Fiestas',
    ),
    TriviaQuestion(
      question: '¿Cómo se conoce al Diwali?',
      options: [
        'El festival de los colores',
        'El Año Nuevo indio',
        'El festival de las cometas',
        'El festival de las luces'
      ],
      correctIndex: 3,
      category: 'Culturas del mundo',
      tag: 'Fiestas',
    ),
    TriviaQuestion(
      question: '¿Cuántos animales tiene el zodiaco chino?',
      options: ['8', '10', '12', '13'],
      correctIndex: 2,
      category: 'Culturas del mundo',
      tag: 'Tradiciones',
    ),
    TriviaQuestion(
      question:
          '¿En qué ciudad colombiana se celebra el Carnaval de Negros y Blancos?',
      options: ['Barranquilla', 'Pasto', 'Popayán', 'Medellín'],
      correctIndex: 1,
      category: 'Culturas del mundo',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question:
          '¿Qué ciudad celebra la Feria de las Flores con el desfile de silleteros?',
      options: ['Bogotá', 'Cali', 'Medellín', 'Manizales'],
      correctIndex: 2,
      category: 'Culturas del mundo',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question: '¿En qué país se originó la tradición de Halloween?',
      options: ['Estados Unidos', 'Irlanda', 'Inglaterra', 'Canadá'],
      correctIndex: 1,
      category: 'Culturas del mundo',
      tag: 'Orígenes',
    ),
    TriviaQuestion(
      question:
          '¿En qué país es tradición el hanami, admirar los cerezos en flor?',
      options: ['China', 'Corea del Sur', 'Japón', 'Vietnam'],
      correctIndex: 2,
      category: 'Culturas del mundo',
      tag: 'Tradiciones',
    ),
    TriviaQuestion(
      question:
          '¿Cuál de estas es una de las siete maravillas del mundo moderno?',
      options: [
        'Torre Eiffel',
        'Estatua de la Libertad',
        'Big Ben',
        'Machu Picchu'
      ],
      correctIndex: 3,
      category: 'Culturas del mundo',
      tag: 'Maravillas',
    ),
    TriviaQuestion(
      question: '¿En qué país está el Taj Mahal?',
      options: ['Pakistán', 'Irán', 'Turquía', 'India'],
      correctIndex: 3,
      category: 'Culturas del mundo',
      tag: 'Maravillas',
    ),
    TriviaQuestion(
      question:
          '¿Qué bebida es tradición compartir en Argentina, Uruguay y Paraguay?',
      options: ['Té negro', 'Chicha', 'Café', 'Mate'],
      correctIndex: 3,
      category: 'Culturas del mundo',
      tag: 'Tradiciones',
    ),
  ],
  'cine_familia': [
    TriviaQuestion(
      question: '¿Cómo se llama el papá de Nemo en "Buscando a Nemo"?',
      options: ['Dory', 'Gill', 'Marlin', 'Bruce'],
      correctIndex: 2,
      category: 'Cine en familia',
      tag: 'Pixar',
    ),
    TriviaQuestion(
      question: '¿En qué país se ambienta la película "Encanto"?',
      options: ['México', 'Perú', 'España', 'Colombia'],
      correctIndex: 3,
      category: 'Cine en familia',
      tag: 'Disney',
    ),
    TriviaQuestion(
      question:
          '¿Cuál fue el primer largometraje hecho completamente por computadora?',
      options: ['Shrek', 'Toy Story', 'Bichos', 'Hormiguitas'],
      correctIndex: 1,
      category: 'Cine en familia',
      tag: 'Historia del cine',
    ),
    TriviaQuestion(
      question: '¿En qué celebración se basa la película "Coco"?',
      options: ['Navidad', 'Halloween', 'Día de Muertos', 'Carnaval'],
      correctIndex: 2,
      category: 'Cine en familia',
      tag: 'Pixar',
    ),
    TriviaQuestion(
      question: '¿Cómo se llama el muñeco de nieve de "Frozen"?',
      options: ['Sven', 'Kristoff', 'Hans', 'Olaf'],
      correctIndex: 3,
      category: 'Cine en familia',
      tag: 'Disney',
    ),
    TriviaQuestion(
      question: '¿Qué animal es Remy en "Ratatouille"?',
      options: ['Un ratón', 'Un hámster', 'Una ardilla', 'Una rata'],
      correctIndex: 3,
      category: 'Cine en familia',
      tag: 'Pixar',
    ),
    TriviaQuestion(
      question: '¿Qué emoción es de color azul en "Intensa-Mente"?',
      options: ['Tristeza', 'Alegría', 'Miedo', 'Desagrado'],
      correctIndex: 0,
      category: 'Cine en familia',
      tag: 'Pixar',
    ),
    TriviaQuestion(
      question:
          '¿Cómo se llama el pequeño robot que limpia la Tierra en una película de Pixar de 2008?',
      options: ['EVA', 'Baymax', 'WALL·E', 'Robbie'],
      correctIndex: 2,
      category: 'Cine en familia',
      tag: 'Pixar',
    ),
    TriviaQuestion(
      question: '¿Con qué hace volar su casa el abuelo Carl en "Up"?',
      options: ['Con globos', 'Con cohetes', 'Con alas', 'Con hélices'],
      correctIndex: 0,
      category: 'Cine en familia',
      tag: 'Pixar',
    ),
    TriviaQuestion(
      question: '¿Qué estudio japonés hizo "Mi vecino Totoro"?',
      options: ['Toei Animation', 'Studio Ghibli', 'Sunrise', 'Madhouse'],
      correctIndex: 1,
      category: 'Cine en familia',
      tag: 'Anime',
    ),
    TriviaQuestion(
      question: '¿Cómo se llama el papá de Simba en "El rey león"?',
      options: ['Scar', 'Mufasa', 'Rafiki', 'Zazú'],
      correctIndex: 1,
      category: 'Cine en familia',
      tag: 'Disney',
    ),
    TriviaQuestion(
      question: '¿En qué saga de películas aparecen los Minions?',
      options: [
        'Mi villano favorito',
        'Shrek',
        'Madagascar',
        'La era de hielo'
      ],
      correctIndex: 0,
      category: 'Cine en familia',
      tag: 'Animación',
    ),
    TriviaQuestion(
      question: '¿Cuál es el apellido de la familia protagonista de "Encanto"?',
      options: ['Madrigal', 'Rivera', 'Buendía', 'Mendoza'],
      correctIndex: 0,
      category: 'Cine en familia',
      tag: 'Disney',
    ),
    TriviaQuestion(
      question: '¿Cómo se llama el niño protagonista de "Coco"?',
      options: ['Héctor', 'Ernesto', 'Dante', 'Miguel'],
      correctIndex: 3,
      category: 'Cine en familia',
      tag: 'Pixar',
    ),
  ],
  'mitos': [
    TriviaQuestion(
      question: 'En la mitología griega, ¿quién es el rey de los dioses?',
      options: ['Ares', 'Poseidón', 'Zeus', 'Hades'],
      correctIndex: 2,
      category: 'Mitos y leyendas',
      tag: 'Grecia',
    ),
    TriviaQuestion(
      question: '¿Qué criatura griega tenía serpientes en lugar de cabello?',
      options: ['Hidra', 'Quimera', 'Esfinge', 'Medusa'],
      correctIndex: 3,
      category: 'Mitos y leyendas',
      tag: 'Grecia',
    ),
    TriviaQuestion(
      question: '¿Qué héroe griego tenía el talón como único punto débil?',
      options: ['Hércules', 'Aquiles', 'Ulises', 'Perseo'],
      correctIndex: 1,
      category: 'Mitos y leyendas',
      tag: 'Grecia',
    ),
    TriviaQuestion(
      question: '¿Qué dios nórdico usa un martillo mágico?',
      options: ['Thor', 'Odín', 'Loki', 'Balder'],
      correctIndex: 0,
      category: 'Mitos y leyendas',
      tag: 'Nórdicos',
    ),
    TriviaQuestion(
      question: '¿En qué laguna colombiana nació la leyenda de El Dorado?',
      options: ['Tota', 'La Cocha', 'Guatavita', 'Iguaque'],
      correctIndex: 2,
      category: 'Mitos y leyendas',
      tag: 'Colombia',
    ),
    TriviaQuestion(
      question: '¿Qué ave mítica renace de sus propias cenizas?',
      options: ['Grifo', 'Fénix', 'Pegaso', 'Dragón'],
      correctIndex: 1,
      category: 'Mitos y leyendas',
      tag: 'Criaturas',
    ),
    TriviaQuestion(
      question: '¿Cómo se llama el caballo alado de la mitología griega?',
      options: ['Unicornio', 'Centauro', 'Pegaso', 'Bucéfalo'],
      correctIndex: 2,
      category: 'Mitos y leyendas',
      tag: 'Grecia',
    ),
    TriviaQuestion(
      question: '¿Qué criatura es mitad humano y mitad caballo?',
      options: ['Minotauro', 'Centauro', 'Sátiro', 'Grifo'],
      correctIndex: 1,
      category: 'Mitos y leyendas',
      tag: 'Criaturas',
    ),
    TriviaQuestion(
      question: '¿Quién robó el fuego a los dioses para dárselo a los humanos?',
      options: ['Prometeo', 'Hermes', 'Ícaro', 'Atlas'],
      correctIndex: 0,
      category: 'Mitos y leyendas',
      tag: 'Grecia',
    ),
    TriviaQuestion(
      question: '¿Qué le pasó a Ícaro por volar muy cerca del Sol?',
      options: [
        'Se convirtió en estrella',
        'Lo atrapó Zeus',
        'Se derritió la cera de sus alas',
        'Se quedó ciego'
      ],
      correctIndex: 2,
      category: 'Mitos y leyendas',
      tag: 'Grecia',
    ),
    TriviaQuestion(
      question:
          '¿Qué serpiente emplumada era un dios importante para los aztecas?',
      options: ['Tláloc', 'Quetzalcóatl', 'Huitzilopochtli', 'Viracocha'],
      correctIndex: 1,
      category: 'Mitos y leyendas',
      tag: 'América',
    ),
    TriviaQuestion(
      question: '¿Cómo se apoda al famoso monstruo del lago Ness, en Escocia?',
      options: ['Bigfoot', 'Yeti', 'Nessie', 'Chupacabras'],
      correctIndex: 2,
      category: 'Mitos y leyendas',
      tag: 'Leyendas',
    ),
    TriviaQuestion(
      question: 'Según el mito, ¿qué quedó dentro de la caja de Pandora?',
      options: ['El oro', 'El fuego', 'La esperanza', 'El amor'],
      correctIndex: 2,
      category: 'Mitos y leyendas',
      tag: 'Grecia',
    ),
  ],
  'vf': [
    TriviaQuestion(
      question: 'Los pulpos tienen tres corazones.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Animales',
    ),
    TriviaQuestion(
      question: 'La Gran Muralla China se ve a simple vista desde la Luna.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Mito común',
    ),
    TriviaQuestion(
      question: 'Los murciélagos son ciegos.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Mito común',
    ),
    TriviaQuestion(
      question: 'El tomate es una fruta.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Comida',
    ),
    TriviaQuestion(
      question: 'El Sol es una estrella.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Espacio',
    ),
    TriviaQuestion(
      question: 'Los peces dorados solo tienen 3 segundos de memoria.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Mito común',
    ),
    TriviaQuestion(
      question:
          'Venus es más caliente que Mercurio, aunque está más lejos del Sol.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Espacio',
    ),
    TriviaQuestion(
      question:
          'Las jirafas tienen las mismas vértebras en el cuello que los humanos: siete.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Animales',
    ),
    TriviaQuestion(
      question: 'Un rayo nunca cae dos veces en el mismo lugar.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Mito común',
    ),
    TriviaQuestion(
      question: 'Los pingüinos viven en el Polo Norte.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Animales',
    ),
    TriviaQuestion(
      question: 'La miel bien guardada puede durar miles de años sin dañarse.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Comida',
    ),
    TriviaQuestion(
      question: 'Los humanos solo usamos el 10 % del cerebro.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Mito común',
    ),
    TriviaQuestion(
      question: 'Las arañas son insectos.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Animales',
    ),
    TriviaQuestion(
      question: 'Los camellos guardan agua en sus jorobas.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Mito común',
    ),
    TriviaQuestion(
      question: 'El río Amazonas pasa por Colombia.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Geografía',
    ),
    TriviaQuestion(
      question: 'Los koalas son un tipo de oso.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Animales',
    ),
    TriviaQuestion(
      question: 'El sonido viaja más rápido en el agua que en el aire.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Ciencia',
    ),
    TriviaQuestion(
      question: 'Un bebé nace con más huesos que un adulto.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Cuerpo humano',
    ),
    TriviaQuestion(
      question: 'El monte Everest está en la frontera entre Nepal y China.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Geografía',
    ),
    TriviaQuestion(
      question: 'Los delfines duermen con la mitad del cerebro despierta.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Animales',
    ),
    TriviaQuestion(
      question: 'Las estrellas de mar son peces.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Océanos',
    ),
    TriviaQuestion(
      question: 'Plutón sigue siendo considerado el noveno planeta.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Espacio',
    ),
    TriviaQuestion(
      question: 'El corazón humano tiene cuatro cavidades.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 0,
      category: 'Verdadero o falso',
      tag: 'Cuerpo humano',
    ),
    TriviaQuestion(
      question: 'Los dinosaurios y los humanos vivieron en la misma época.',
      options: ['Verdadero', 'Falso'],
      correctIndex: 1,
      category: 'Verdadero o falso',
      tag: 'Dinosaurios',
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

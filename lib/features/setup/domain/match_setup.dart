import 'package:flutter/foundation.dart';

import '../../catalog/data/games_catalog.dart';

/// Configuración de una partida. Es inmutable: cada cambio crea una copia
/// con `copyWith`, igual que actualizar estado en React (`{...prev, x}`).
///
/// Es `sealed`: solo existen las subclases de este archivo, así un `switch`
/// sobre un [MatchSetup] obliga a cubrir todos los juegos (como una *union*
/// discriminada de TypeScript). Los campos comunes viven aquí y los propios
/// de cada juego en su subclase.
@immutable
sealed class MatchSetup {
  const MatchSetup({
    required this.players,
    required this.playerNames,
    required this.selectedDecks,
  });

  /// Id del juego en el catálogo (`charadas`, `trivia`, `impostor`).
  String get gameId;

  /// Mínimo de mazos/packs que deben quedar seleccionados.
  int get minDecks => 1;

  final int players;

  /// Un nombre por jugador; siempre tiene `players` elementos.
  final List<String> playerNames;
  final Set<String> selectedDecks;

  /// Rango de jugadores del juego, tomado del catálogo.
  int get minPlayers => gameById(gameId)!.minPlayers;
  int get maxPlayers => gameById(gameId)!.maxPlayers;

  int clampPlayers(int value) => value.clamp(minPlayers, maxPlayers);
}

// --- Charadas ----------------------------------------------------------------

enum CharadesMode { teams, freeForAll }

/// Filtro de dificultad de las cartas (`mixed` = todas).
enum CharadesDifficulty {
  easy('Fácil'),
  medium('Media'),
  hard('Difícil'),
  mixed('Mezcla');

  const CharadesDifficulty(this.label);

  final String label;
}

final class CharadesSetup extends MatchSetup {
  const CharadesSetup({
    required super.players,
    required super.playerNames,
    required super.selectedDecks,
    this.mode = CharadesMode.teams,
    this.teamNames = const ['Team Vino', 'Team Burbujas'],
    this.turnSeconds = 60,
    this.penaltyOnPass = true,
    this.rounds = 3,
    this.difficulty = CharadesDifficulty.mixed,
    this.tiltControls = true,
    this.customWords = const [],
  });

  /// Valores por defecto del mockup: listos para jugar en ≤ 3 toques.
  factory CharadesSetup.initial(int players) {
    const base = CharadesSetup(
        players: 0, playerNames: [], selectedDecks: {'viral', 'memes'});
    return base.withPlayers(players);
  }

  static const List<int> turnOptions = [45, 60, 90];
  static const int minRounds = 1;
  static const int maxRounds = 10;

  @override
  String get gameId => 'charadas';

  final CharadesMode mode;
  final List<String> teamNames;
  final int turnSeconds;
  final bool penaltyOnPass;
  final int rounds;
  final CharadesDifficulty difficulty;

  /// Girar el móvil en la frente marca Acierto/Pasar (acelerómetro).
  final bool tiltControls;

  /// Palabras propias del grupo ("Mazo personalizado rápido"); si hay,
  /// se suman a los mazos elegidos. Solo viven durante la sesión.
  final List<String> customWords;

  static const int maxCustomWords = 50;

  CharadesSetup withPlayers(int value) {
    final count = clampPlayers(value);
    return copyWith(
      players: count,
      playerNames: resizePlayerNames(playerNames, count),
    );
  }

  CharadesSetup copyWith({
    int? players,
    List<String>? playerNames,
    Set<String>? selectedDecks,
    CharadesMode? mode,
    List<String>? teamNames,
    int? turnSeconds,
    bool? penaltyOnPass,
    int? rounds,
    CharadesDifficulty? difficulty,
    bool? tiltControls,
    List<String>? customWords,
  }) {
    return CharadesSetup(
      players: players ?? this.players,
      playerNames: playerNames ?? this.playerNames,
      selectedDecks: selectedDecks ?? this.selectedDecks,
      mode: mode ?? this.mode,
      teamNames: teamNames ?? this.teamNames,
      turnSeconds: turnSeconds ?? this.turnSeconds,
      penaltyOnPass: penaltyOnPass ?? this.penaltyOnPass,
      rounds: rounds ?? this.rounds,
      difficulty: difficulty ?? this.difficulty,
      tiltControls: tiltControls ?? this.tiltControls,
      customWords: customWords ?? this.customWords,
    );
  }
}

// --- Trivia ------------------------------------------------------------------

enum TriviaAnswerMode { buzzer, turns }

final class TriviaSetup extends MatchSetup {
  const TriviaSetup({
    required super.players,
    required super.playerNames,
    required super.selectedDecks,
    this.answerMode = TriviaAnswerMode.buzzer,
    this.teamNames = const ['Team Vino', 'Team Burbujas'],
    this.questionSeconds = 15,
    this.doublePointsLastRound = true,
    this.targetPoints = 500,
  });

  factory TriviaSetup.initial(int players) {
    const base = TriviaSetup(
      players: 0,
      playerNames: [],
      selectedDecks: {'animales', 'mundo', 'cine_familia'},
    );
    return base.withPlayers(players);
  }

  static const List<int> secondsOptions = [10, 15, 30];
  static const List<int> targetOptions = [300, 500, 1000];

  @override
  String get gameId => 'trivia';

  /// El mockup pide "Mínimo 2 seleccionados".
  @override
  int get minDecks => 2;

  final TriviaAnswerMode answerMode;

  /// Los 2 equipos del modo "Pulsador en pantalla".
  final List<String> teamNames;
  final int questionSeconds;
  final bool doublePointsLastRound;
  final int targetPoints;

  TriviaSetup withPlayers(int value) {
    final count = clampPlayers(value);
    return copyWith(
      players: count,
      playerNames: resizePlayerNames(playerNames, count),
    );
  }

  TriviaSetup copyWith({
    int? players,
    List<String>? playerNames,
    Set<String>? selectedDecks,
    TriviaAnswerMode? answerMode,
    List<String>? teamNames,
    int? questionSeconds,
    bool? doublePointsLastRound,
    int? targetPoints,
  }) {
    return TriviaSetup(
      players: players ?? this.players,
      playerNames: playerNames ?? this.playerNames,
      selectedDecks: selectedDecks ?? this.selectedDecks,
      answerMode: answerMode ?? this.answerMode,
      teamNames: teamNames ?? this.teamNames,
      questionSeconds: questionSeconds ?? this.questionSeconds,
      doublePointsLastRound:
          doublePointsLastRound ?? this.doublePointsLastRound,
      targetPoints: targetPoints ?? this.targetPoints,
    );
  }
}

// --- Impostor ----------------------------------------------------------------

final class ImpostorSetup extends MatchSetup {
  const ImpostorSetup({
    required super.players,
    required super.playerNames,
    required super.selectedDecks,
    this.impostors = 1,
    this.blindHapticTurn = true,
    this.hintForImpostor = false,
    this.debateMinutes = 3,
  });

  factory ImpostorSetup.initial(int players) {
    const base = ImpostorSetup(
        players: 0, playerNames: [], selectedDecks: {'comida', 'objetos'});
    return base.withPlayers(players);
  }

  static const List<int> debateOptions = [2, 3, 5];

  /// Con menos jugadores, dos impostores serían mayoría muy pronto.
  static const int playersForTwoImpostors = 6;

  @override
  String get gameId => 'impostor';

  final int impostors;
  final bool blindHapticTurn;
  final bool hintForImpostor;
  final int debateMinutes;

  int get maxImpostors => players >= playersForTwoImpostors ? 2 : 1;

  /// Al bajar de jugadores, el nº de impostores se ajusta solo.
  ImpostorSetup withPlayers(int value) {
    final count = clampPlayers(value);
    final updated = copyWith(
      players: count,
      playerNames: resizePlayerNames(playerNames, count),
    );
    return updated.copyWith(
        impostors: impostors.clamp(1, updated.maxImpostors));
  }

  ImpostorSetup copyWith({
    int? players,
    List<String>? playerNames,
    Set<String>? selectedDecks,
    int? impostors,
    bool? blindHapticTurn,
    bool? hintForImpostor,
    int? debateMinutes,
  }) {
    return ImpostorSetup(
      players: players ?? this.players,
      playerNames: playerNames ?? this.playerNames,
      selectedDecks: selectedDecks ?? this.selectedDecks,
      impostors: impostors ?? this.impostors,
      blindHapticTurn: blindHapticTurn ?? this.blindHapticTurn,
      hintForImpostor: hintForImpostor ?? this.hintForImpostor,
      debateMinutes: debateMinutes ?? this.debateMinutes,
    );
  }
}

// --- Funciones puras compartidas ----------------------------------------------

/// Nombres sugeridos del mockup del Impostor; después, "Jugador N".
const List<String> _suggestedNames = [
  'Mateo', 'Clara', 'David', 'Sofi', 'Lucas', 'Ana', 'Nico', 'Val', //
];

/// Nombres listos para jugar: un nombre borrado en la config no deja un
/// hueco en el marcador ("Equipo A", "Jugador 3").
List<String> displayTeamNames(List<String> names) => [
      for (final (i, name) in names.indexed)
        name.trim().isEmpty ? 'Equipo ${String.fromCharCode(65 + i)}' : name.trim(),
    ];

List<String> displayPlayerNames(List<String> names) => [
      for (final (i, name) in names.indexed)
        name.trim().isEmpty ? 'Jugador ${i + 1}' : name.trim(),
    ];

String defaultPlayerName(int index) => index < _suggestedNames.length
    ? _suggestedNames[index]
    : 'Jugador ${index + 1}';

/// Ajusta la lista de nombres a [count] jugadores: conserva los que ya se
/// editaron y completa con nombres sugeridos.
List<String> resizePlayerNames(List<String> names, int count) => [
      for (var i = 0; i < count; i++)
        i < names.length ? names[i] : defaultPlayerName(i),
    ];

/// Devuelve el nuevo set de mazos tras tocar [deckId], o `null` si el cambio
/// dejaría menos de [minDecks] seleccionados.
Set<String>? toggleDeck(Set<String> current, String deckId, int minDecks) {
  if (!current.contains(deckId)) return {...current, deckId};
  if (current.length <= minDecks) return null;
  return {...current}..remove(deckId);
}

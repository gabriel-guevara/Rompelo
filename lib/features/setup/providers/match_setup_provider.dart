import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/match_setup.dart';
import 'player_count_provider.dart';

/// Escucha al selector mágico del home: si cambia el número de jugadores
/// reunidos, la configuración se adapta (sin perder el resto de ajustes).
///
/// `ref.listen` (y no `ref.watch`) porque `watch` reconstruiría el estado
/// desde cero y borraría mazos, nombres y reglas ya elegidos. El flujo es
/// en un solo sentido: home → configuración. Si cada pantalla escribiera
/// también en `playerCountProvider`, los rangos distintos de cada juego
/// (3-12, 2-20, 4-10) se recortarían entre sí en cadena.
void _followPlayerCount(Ref ref, void Function(int) setPlayers) {
  ref.listen<int>(playerCountProvider, (_, next) => setPlayers(next));
}

class CharadesSetupNotifier extends Notifier<CharadesSetup> {
  @override
  CharadesSetup build() {
    _followPlayerCount(ref, setPlayers);
    return CharadesSetup.initial(ref.read(playerCountProvider));
  }

  void setPlayers(int value) => state = state.withPlayers(value);

  void renamePlayer(int index, String name) => state =
      state.copyWith(playerNames: [...state.playerNames]..[index] = name);

  /// `false` si no se pudo quitar porque es el último mazo.
  bool toggleDeck(String deckId) {
    final decks = toggleDeckIn(state, deckId);
    if (decks == null) return false;
    state = state.copyWith(selectedDecks: decks);
    return true;
  }

  void setMode(CharadesMode mode) => state = state.copyWith(mode: mode);

  void renameTeam(int index, String name) =>
      state = state.copyWith(teamNames: [...state.teamNames]..[index] = name);

  void setTurnSeconds(int seconds) =>
      state = state.copyWith(turnSeconds: seconds);

  void setPenaltyOnPass(bool value) =>
      state = state.copyWith(penaltyOnPass: value);

  void setRounds(int rounds) => state = state.copyWith(
      rounds: rounds.clamp(CharadesSetup.minRounds, CharadesSetup.maxRounds));
}

class TriviaSetupNotifier extends Notifier<TriviaSetup> {
  @override
  TriviaSetup build() {
    _followPlayerCount(ref, setPlayers);
    return TriviaSetup.initial(ref.read(playerCountProvider));
  }

  void setPlayers(int value) => state = state.withPlayers(value);

  bool toggleDeck(String deckId) {
    final decks = toggleDeckIn(state, deckId);
    if (decks == null) return false;
    state = state.copyWith(selectedDecks: decks);
    return true;
  }

  void setAnswerMode(TriviaAnswerMode mode) =>
      state = state.copyWith(answerMode: mode);

  void setQuestionSeconds(int seconds) =>
      state = state.copyWith(questionSeconds: seconds);

  void setDoublePointsLastRound(bool value) =>
      state = state.copyWith(doublePointsLastRound: value);

  void setTargetPoints(int points) =>
      state = state.copyWith(targetPoints: points);
}

class ImpostorSetupNotifier extends Notifier<ImpostorSetup> {
  @override
  ImpostorSetup build() {
    _followPlayerCount(ref, setPlayers);
    return ImpostorSetup.initial(ref.read(playerCountProvider));
  }

  void setPlayers(int value) => state = state.withPlayers(value);

  void renamePlayer(int index, String name) => state =
      state.copyWith(playerNames: [...state.playerNames]..[index] = name);

  bool toggleDeck(String deckId) {
    final decks = toggleDeckIn(state, deckId);
    if (decks == null) return false;
    state = state.copyWith(selectedDecks: decks);
    return true;
  }

  /// `false` si el grupo es muy chico para esa cantidad de impostores.
  bool setImpostors(int value) {
    if (value < 1 || value > state.maxImpostors) return false;
    state = state.copyWith(impostors: value);
    return true;
  }

  void setBlindHapticTurn(bool value) =>
      state = state.copyWith(blindHapticTurn: value);

  void setHintForImpostor(bool value) =>
      state = state.copyWith(hintForImpostor: value);

  void setDebateMinutes(int minutes) =>
      state = state.copyWith(debateMinutes: minutes);
}

/// Atajo para los notifiers: aplica la regla de mínimo de mazos del juego.
Set<String>? toggleDeckIn(MatchSetup setup, String deckId) =>
    toggleDeck(setup.selectedDecks, deckId, setup.minDecks);

// No son `autoDispose`: la configuración sobrevive al salir de la pantalla,
// así "Jugar revancha" (Fase 5) reutiliza los mismos ajustes.
final charadesSetupProvider =
    NotifierProvider<CharadesSetupNotifier, CharadesSetup>(
        CharadesSetupNotifier.new);

final triviaSetupProvider =
    NotifierProvider<TriviaSetupNotifier, TriviaSetup>(TriviaSetupNotifier.new);

final impostorSetupProvider =
    NotifierProvider<ImpostorSetupNotifier, ImpostorSetup>(
        ImpostorSetupNotifier.new);

/// Lectura genérica por id de juego (`/partida/:juego`, resultados…).
///
/// Un `family` es un provider con parámetro: `matchSetupProvider('trivia')`.
/// Es de solo lectura; para editar se usa el notifier de cada juego.
final matchSetupProvider = Provider.family<MatchSetup, String>((ref, gameId) {
  return switch (gameId) {
    'charadas' => ref.watch(charadesSetupProvider),
    'trivia' => ref.watch(triviaSetupProvider),
    'impostor' => ref.watch(impostorSetupProvider),
    _ => throw ArgumentError.value(gameId, 'gameId', 'Juego sin configuración'),
  };
});

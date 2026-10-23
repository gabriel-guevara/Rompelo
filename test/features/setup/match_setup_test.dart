import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/setup/domain/match_setup.dart';

void main() {
  group('resizePlayerNames', () {
    test('conserva los nombres editados y completa con sugeridos', () {
      expect(resizePlayerNames(['Gabo'], 3), ['Gabo', 'Clara', 'David']);
    });

    test('recorta al bajar de jugadores', () {
      expect(resizePlayerNames(['A', 'B', 'C'], 2), ['A', 'B']);
    });

    test('después de los 8 sugeridos usa "Jugador N"', () {
      expect(defaultPlayerName(8), 'Jugador 9');
    });
  });

  group('toggleDeck', () {
    test('agrega un mazo no seleccionado', () {
      expect(toggleDeck({'a'}, 'b', 1), {'a', 'b'});
    });

    test('quita un mazo si queda el mínimo', () {
      expect(toggleDeck({'a', 'b'}, 'a', 1), {'b'});
    });

    test('devuelve null si dejaría menos del mínimo', () {
      expect(toggleDeck({'a'}, 'a', 1), isNull);
      expect(toggleDeck({'a', 'b'}, 'a', 2), isNull);
    });
  });

  test('withPlayers respeta el rango del catálogo', () {
    // Charadas: 3-12 jugadores.
    final setup = CharadesSetup.initial(6);
    expect(setup.withPlayers(1).players, 3);
    expect(setup.withPlayers(40).players, 12);
    expect(setup.withPlayers(8).playerNames, hasLength(8));
  });

  test('el impostor baja a 1 si el grupo queda chico', () {
    final setup = ImpostorSetup.initial(8).copyWith(impostors: 2);
    expect(setup.maxImpostors, 2);
    final smaller = setup.withPlayers(4);
    expect(smaller.impostors, 1);
    expect(smaller.maxImpostors, 1);
  });

  test('valores por defecto de los mockups', () {
    final charades = CharadesSetup.initial(6);
    expect(charades.selectedDecks, {'viral', 'memes'});
    expect(charades.turnSeconds, 60);
    expect(charades.rounds, 3);

    final trivia = TriviaSetup.initial(6);
    expect(trivia.selectedDecks, hasLength(3));
    expect(trivia.minDecks, 2);
    expect(trivia.targetPoints, 500);

    final impostor = ImpostorSetup.initial(6);
    expect(impostor.debateMinutes, 3);
    expect(impostor.playerNames.first, 'Mateo');
  });
}

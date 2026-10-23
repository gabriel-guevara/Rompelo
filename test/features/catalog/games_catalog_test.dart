import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/catalog/domain/game_item.dart';
import 'package:rompelo_app/features/catalog/data/games_catalog.dart';

void main() {
  test('los ids del catálogo son únicos', () {
    final ids = gamesCatalog.map((g) => g.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('gameById encuentra juegos y devuelve null si no existe', () {
    expect(gameById('charadas')?.title, 'Charadas alocadas');
    expect(gameById('trivia')?.configPath, '/configurar/trivia');
    expect(gameById('impostor')?.playPath, '/partida/impostor');
    expect(gameById('no-existe'), isNull);
  });

  test('metaLabel usa el formato del mockup', () {
    expect(gameById('charadas')?.metaLabel, '10 min • 3-12 pers');
  });

  test('gamesByVibe filtra por vibra y null devuelve todo', () {
    expect(gamesByVibe(null), gamesCatalog);
    expect(gamesByVibe(GameVibe.misterio).map((g) => g.id), ['impostor']);
    expect(gamesByVibe(GameVibe.fiesta).map((g) => g.id),
        containsAll(['charadas', 'trivia']));
  });

  test('todas las vibras tienen al menos un juego', () {
    for (final vibe in GameVibe.values) {
      expect(gamesByVibe(vibe), isNotEmpty, reason: vibe.label);
    }
  });

  test('pickRandomGame prioriza juegos donde cabe el grupo', () {
    // Con 2 jugadores solo cabe Trivia (2-20).
    for (var seed = 0; seed < 20; seed++) {
      expect(pickRandomGame(players: 2, random: Random(seed)).id, 'trivia');
    }
    // Con 30 jugadores no cabe ninguno: sortea entre todos.
    final ids = {
      for (var seed = 0; seed < 50; seed++)
        pickRandomGame(players: 30, random: Random(seed)).id,
    };
    expect(ids, {'charadas', 'impostor', 'trivia'});
  });
}

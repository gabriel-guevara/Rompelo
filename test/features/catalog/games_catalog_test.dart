import 'package:flutter_test/flutter_test.dart';
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
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/data/mock_game_content.dart';
import 'package:rompelo_app/features/games/impostor/impostor_play_screen.dart';
import 'package:rompelo_app/features/setup/data/deck_options.dart';

void main() {
  test('cada mazo de la configuración tiene contenido mock', () {
    expect(charadesCardsByDeck.keys.toSet(),
        charadesDecks.map((d) => d.id).toSet());
    expect(triviaQuestionsByPack.keys.toSet(),
        triviaPacks.map((d) => d.id).toSet());
    expect(impostorTopicsByDeck.keys.toSet(),
        impostorDecks.map((d) => d.id).toSet());
  });

  test('las preguntas tienen 4 opciones y una respuesta válida', () {
    for (final question in triviaQuestionsByPack.values.expand((q) => q)) {
      expect(question.options, hasLength(4));
      expect(question.correctIndex, inInclusiveRange(0, 3));
    }
  });

  test('interleaveDecks intercala respetando el orden de los mazos', () {
    final result = interleaveDecks(
      {
        'a': [1, 2, 3],
        'b': [10],
        'c': [100, 200]
      },
      ['a', 'b', 'c'],
      {'c', 'a'},
    );
    expect(result, [1, 100, 2, 200, 3]);
  });

  test('mockImpostors reparte impostores distintos dentro de la mesa', () {
    expect(mockImpostors(6, 1), {5});
    expect(mockImpostors(6, 2), {5, 2});
    expect(mockImpostors(4, 1), {3});
  });
}

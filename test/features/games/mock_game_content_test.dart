import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/data/mock_game_content.dart';
import 'package:rompelo_app/features/games/providers/shuffled_deck.dart';
import 'package:rompelo_app/features/setup/data/deck_options.dart';

void main() {
  test('cada mazo de la configuración tiene contenido', () {
    expect(charadesCardsByDeck.keys.toSet(),
        charadesDecks.map((d) => d.id).toSet());
    expect(triviaQuestionsByPack.keys.toSet(),
        triviaPacks.map((d) => d.id).toSet());
    expect(impostorTopicsByDeck.keys.toSet(),
        impostorDecks.map((d) => d.id).toSet());
  });

  test('los mazos de Charadas tienen todas las dificultades y sin repetir',
      () {
    for (final MapEntry(key: id, value: cards) in charadesCardsByDeck.entries) {
      expect(cards.length, greaterThanOrEqualTo(30), reason: id);
      for (final d in CardDifficulty.values) {
        expect(cards.where((c) => c.difficulty == d), isNotEmpty,
            reason: '$id sin cartas ${d.label}');
      }
      final words = cards.map((c) => c.word).toList();
      expect(words.toSet().length, words.length, reason: id);
    }
  });

  test('cada tema del Impostor tiene palabras únicas con pista', () {
    for (final MapEntry(key: id, value: topic)
        in impostorTopicsByDeck.entries) {
      expect(topic.words.length, greaterThanOrEqualTo(20), reason: id);
      final words = topic.words.map((w) => w.word).toList();
      expect(words.toSet().length, words.length, reason: id);
      for (final w in topic.words) {
        expect(w.hint, isNotEmpty);
        expect(w.hint.toLowerCase(), isNot(w.word.toLowerCase()));
      }
    }
  });

  test('las preguntas tienen 4 opciones (2 en V/F) y una respuesta válida',
      () {
    for (final question in triviaQuestionsByPack.values.expand((q) => q)) {
      expect(question.options.length, anyOf(2, 4), reason: question.question);
      expect(question.correctIndex,
          inInclusiveRange(0, question.options.length - 1));
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

  group('ShuffledDeck', () {
    ShuffledDeck<int> deck() => ShuffledDeck(
          byDeck: {
            'a': [1, 2, 3, 4],
            'b': [5, 6],
          },
          keyOf: (n) => '$n',
          random: Random(1),
        );

    test('no repite hasta agotar el mazo', () {
      final d = deck();
      final first = d.draw({'a'}, count: 2);
      final second = d.draw({'a'}, count: 2);
      expect({...first, ...second}, {1, 2, 3, 4});
    });

    test('al agotarse rebaraja y sigue entregando', () {
      final d = deck();
      d.draw({'a'}, count: 4);
      expect(d.draw({'a'}, count: 3), hasLength(3));
    });

    test('suma el contenido extra y aplica el filtro', () {
      final d = deck();
      final all = d.draw({'b'}, extra: [7, 8], where: (n) => n.isOdd);
      expect(all.toSet(), {5, 7});
    });
  });
}

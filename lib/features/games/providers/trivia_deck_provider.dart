import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_game_content.dart';

class TriviaDeck {
  TriviaDeck({Random? random}) : _random = random ?? Random();
  final Random _random;
  final Set<String> _seen = {}; // preguntas que ya salieron en esta sesión

  List<TriviaQuestion> draw(Set<String> packs, int count) {
    final pool = [for (final id in packs) ...?triviaQuestionsByPack[id]];
    final fresh = pool.where((q) => !_seen.contains(q.question)).toList()
      ..shuffle(_random);

    if (fresh.length < count) {
      // Se acabaron las nuevas: primero van las que quedaban sin salir,
      // después se rebaraja el resto y se reinicia el registro de esos packs.
      final rest = pool.where((q) => !fresh.contains(q)).toList()
        ..shuffle(_random);
      _seen.removeAll(pool.map((q) => q.question));
      fresh.addAll(rest);
    }

    final picked = fresh.take(count).map(_shuffleOptions).toList();
    _seen.addAll(picked.map((q) => q.question));
    return picked;
  }

  /// Baraja A–D y recalcula cuál es la correcta.
  TriviaQuestion _shuffleOptions(TriviaQuestion q) {
    if (q.options.length == 2) return q; // V/F: siempre Verdadero, Falso
    final correct = q.options[q.correctIndex];
    final options = [...q.options]..shuffle(_random);
    return TriviaQuestion(
      question: q.question,
      options: options,
      correctIndex: options.indexOf(correct),
      category: q.category,
      tag: q.tag,
    );
  }
}

/// Un `Provider` normal (sin autoDispose) dura toda la sesión de la app.
final triviaDeckProvider = Provider<TriviaDeck>((ref) => TriviaDeck());
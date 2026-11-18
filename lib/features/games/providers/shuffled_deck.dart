import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_game_content.dart';

/// Azar compartido por los juegos (barajar mazos, elegir impostores…).
///
/// Los tests lo sobreescriben con un `Random(semilla)` para que cada
/// partida salga igual en cada ejecución.
final gameRandomProvider = Provider<Random>((ref) => Random());

/// Mazo barajado que **no repite** contenido durante la sesión de la app.
///
/// Generaliza la idea de `TriviaDeck`: junta el contenido de los mazos
/// elegidos, prioriza lo que aún no salió y, cuando se agota, vuelve a
/// barajar todo. [keyOf] identifica cada elemento (la palabra, p. ej.).
class ShuffledDeck<T> {
  ShuffledDeck({
    required this.byDeck,
    required this.keyOf,
    required Random random,
  }) : _random = random;

  final Map<String, List<T>> byDeck;
  final String Function(T item) keyOf;
  final Random _random;
  final Set<String> _seen = {};

  /// Devuelve hasta [count] elementos de [decks] (todos si `count` es null),
  /// primero los no vistos, y los marca como vistos.
  ///
  /// [extra] suma contenido que no vive en [byDeck] (mazo personalizado) y
  /// [where] filtra (p. ej. por dificultad).
  List<T> draw(
    Set<String> decks, {
    int? count,
    List<T> extra = const [],
    bool Function(T item)? where,
  }) {
    final pool = [
      for (final id in decks) ...?byDeck[id],
      ...extra,
    ].where(where ?? (_) => true).toList();

    final fresh = pool.where((item) => !_seen.contains(keyOf(item))).toList()
      ..shuffle(_random);
    final want = count ?? pool.length;

    if (fresh.length < want) {
      // Se acabaron las nuevas: van primero las que quedaban sin salir y
      // después el resto rebarajado; se reinicia el registro de ese pool.
      final rest = pool.where((item) => !fresh.contains(item)).toList()
        ..shuffle(_random);
      _seen.removeAll(pool.map(keyOf));
      fresh.addAll(rest);
    }

    final picked = fresh.take(want).toList();
    _seen.addAll(picked.map(keyOf));
    return picked;
  }

  /// Marca como vistos elementos que se sacaron pero no se usaron todos.
  void forget(Iterable<T> items) => _seen.removeAll(items.map(keyOf));
}

/// Cartas de Charadas: dura toda la sesión (no `autoDispose`) para que la
/// revancha no repita las mismas palabras.
final charadesDeckProvider = Provider<ShuffledDeck<CharadesCard>>(
  (ref) => ShuffledDeck(
    byDeck: charadesCardsByDeck,
    keyOf: (card) => card.word,
    random: ref.watch(gameRandomProvider),
  ),
);

/// Palabras secretas del Impostor.
final impostorDeckProvider = Provider<ShuffledDeck<ImpostorWord>>(
  (ref) => ShuffledDeck(
    byDeck: {
      for (final MapEntry(:key, :value) in impostorTopicsByDeck.entries)
        key: value.words,
    },
    keyOf: (word) => word.word,
    random: ref.watch(gameRandomProvider),
  ),
);

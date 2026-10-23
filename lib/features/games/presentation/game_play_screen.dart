import 'package:flutter/widgets.dart';

import '../../catalog/domain/game_item.dart';
import '../charades/charades_play_screen.dart';
import '../impostor/impostor_play_screen.dart';
import '../trivia/trivia_play_screen.dart';

/// Elige la pantalla de partida de cada juego (`/partida/:juego`).
///
/// Igual que `gameConfigScreenFor`: agregar un juego = un `case` más. El
/// router ya garantiza que el id existe en el catálogo.
Widget gamePlayScreenFor(GameItem game) {
  return switch (game.id) {
    'charadas' => const CharadesPlayScreen(),
    'trivia' => const TriviaPlayScreen(),
    'impostor' => const ImpostorPlayScreen(),
    _ => throw ArgumentError.value(game.id, 'game.id', 'Sin partida'),
  };
}

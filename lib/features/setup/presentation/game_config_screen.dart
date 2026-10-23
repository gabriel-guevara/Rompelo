import 'package:flutter/widgets.dart';

import '../../catalog/domain/game_item.dart';
import 'charades_config_screen.dart';
import 'impostor_config_screen.dart';
import 'trivia_config_screen.dart';

/// Elige la pantalla de configuración de cada juego (`/configurar/:juego`).
///
/// Agregar un juego nuevo = un `case` más aquí. El router ya garantiza que
/// el id existe en el catálogo (redirige a `/` si no).
Widget gameConfigScreenFor(GameItem game) {
  return switch (game.id) {
    'charadas' => const CharadesConfigScreen(),
    'trivia' => const TriviaConfigScreen(),
    'impostor' => const ImpostorConfigScreen(),
    _ => throw ArgumentError.value(game.id, 'game.id', 'Sin configuración'),
  };
}

# Fase 3 — Pantallas de configuración

**Mockups:** `design/stitch/config_charadas/`, `config_trivia/`, `config_impostor/`.

## Tareas
1. `features/setup/domain/match_setup.dart`: modelo inmutable (juego, jugadores, nombres, equipos,
   mazos seleccionados, tiempo, rondas, toggles, nº impostores…) con `copyWith`.
2. `providers/match_setup_provider.dart`: `Notifier` con valores por defecto por juego (para iniciar en ≤ 3 toques).
3. Widgets compartidos: `deck_list.dart` (mazos con check, badge "Popular"/"+18"), `player_names_editor.dart`
   (chips de nombres editables; cumple RF "ingresar nombres"), hero de cada juego.
4. `charades_config_screen.dart`: modo equipos/todos, jugadores + nombres de equipos, mazos, reglas
   (45/60/90 s, penalización, rondas), aviso de espacio libre, CTA "¡Empezar a actuar!".
5. `trivia_config_screen.dart`: dinámica (pulsador / turnos), participantes, packs (mín. 2), reglas
   (10/15/30 s, puntos dobles, 500 pts), CTA "¡Calentar pulsadores y jugar!".
6. `impostor_config_screen.dart`: jugadores + chips de nombres, 1/2 impostores, mazos de palabras,
   toggles de pase y debate, tiempo de debate, CTA "Repartir identidades secretas".
7. Cada CTA navega a `/partida/<juego>`.
8. Tests del provider (cambiar jugadores, seleccionar mazos) y de que cada pantalla renderiza su CTA.

## Terminado cuando
Las 3 configuraciones se ven como sus capturas, sus controles cambian el estado y llevan a la partida.

## Al terminar
1. `flutter analyze` sin issues y `flutter test` en verde.
2. Actualizar **`README.md`** con lo que cambió en esta fase (y la tabla de estado por fase).
3. Actualizar **`docs/progreso.md`**: estado ✅, commit, decisiones y pendientes para la siguiente sesión.
4. Commit y push a `claude/admiring-cray-ed15pq`.

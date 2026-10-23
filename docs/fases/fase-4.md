# Fase 4 — Pantallas en partida (mock)

**Mockups:** `design/stitch/partida_charadas/`, `partida_trivia/`, `partida_impostor/`.
Pantalla completa, sin bottom nav.

## Tareas
1. `features/games/data/mock_game_content.dart`: cartas de charadas, preguntas de trivia, palabra/tema del impostor.
2. Widgets: `LiveGameTopBar` ("Salir" con diálogo de confirmación → `/`, badge "Partida en vivo", avatar),
   `TimerBar` (animación decorativa con `AnimationController`).
3. `charades_play_screen.dart`: ronda y marcador de equipos, tiempo restante, carta con categoría, palabra e
   indicación, botones "Pasar" y "¡Acierto! +1 punto" que avanzan la carta y suman puntos mock.
4. `trivia_play_screen.dart`: marcador de equipos, contador 7/12, "Tiempo crítico", carta de pregunta,
   grid A–D que resalta la opción elegida, botón "¡Robar turno!".
5. `impostor_play_screen.dart`: timer de debate, "Fase secreta completada" + tema común, turno de pregunta,
   radar de sospechosos (grid de jugadores, tocar para marcar), "Votar y delatar al impostor",
   botón "Mantén presionado para ver tu rol" (muestra el rol solo mientras se presiona).
6. Al terminar las cartas/rondas mock o al votar → `/resultados`; guardar puntajes mock en un provider.
7. Tests: Acierto suma punto; la partida termina en resultados.

## Terminado cuando
Las 3 partidas se ven como sus capturas y el flujo home → config → partida → resultados funciona.

## Al terminar
1. `flutter analyze` sin issues y `flutter test` en verde.
2. Actualizar **`README.md`** con lo que cambió en esta fase (y la tabla de estado por fase).
3. Actualizar **`docs/progreso.md`**: estado ✅, commit, decisiones y pendientes para la siguiente sesión.
4. Commit y push a `claude/admiring-cray-ed15pq`.

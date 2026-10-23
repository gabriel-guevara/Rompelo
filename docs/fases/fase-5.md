# Fase 5 — Resultados y tabs restantes

**Mockup:** `design/stitch/resultados/`. Las tabs Configurar y Ajustes no tienen mockup.

## Tareas
1. `features/results/presentation/results_screen.dart`: badge "Fin del juego", "¡Partida finalizada!",
   confeti decorativo, `podium.dart` (1.º wine, 2.º y 3.º claros), "Premios de la noche" (`award_tile.dart`),
   estadísticas (`stat_tile.dart`).
2. Botones "¡Jugar revancha!" (→ `/partida/<último juego>` con la misma configuración) y
   "Volver al catálogo" (→ `/`). Cumple el RF "repetir o cambiar de juego sin reiniciar".
3. Si no hay partida jugada, la tab Marcador muestra un estado vacío con CTA al catálogo.
4. `configure_tab_screen.dart`: lista de juegos que lleva a su configuración.
5. `settings_screen.dart`: placeholder con el mismo estilo (p. ej. vibración, sonido, "acerca de").
6. Tests: revancha vuelve a la partida; "Volver al catálogo" vuelve al home.

## Terminado cuando
Todas las rutas del plan existen y se ven coherentes con el sistema de diseño.

## Al terminar
1. `flutter analyze` sin issues y `flutter test` en verde.
2. Actualizar **`README.md`** con lo que cambió en esta fase (y la tabla de estado por fase).
3. Actualizar **`docs/progreso.md`**: estado ✅, commit, decisiones y pendientes para la siguiente sesión.
4. Commit y push a `claude/admiring-cray-ed15pq`.

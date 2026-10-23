# Fase 2 — Home / Explorar

**Mockup:** `design/stitch/home/` (`screen.png` + `code.html`).

## Tareas
1. `features/catalog/presentation/home_screen.dart`: header (logo + "Rómpelo ✨ Party Hub", campana, avatar),
   "¿Qué jugamos hoy?" + selector "Mesa 4".
2. `widgets/magic_picker_card.dart`: tarjeta azul "¿No saben qué elegir?" con `CounterStepper` de
   jugadores y `ChunkyButton` wine "¡Elegir juego al azar!" → navega a `/configurar/<juego aleatorio>`.
3. "Explora por vibra": chips horizontales (Todos, Fiesta total, Misterio…) que filtran el catálogo; badge "3 juegos listos".
4. `widgets/game_card.dart`: tag, duración/jugadores, título, descripción, chips, ilustración
   (icono/emoji en contenedor de color) y CTA "Configurar y jugar" (wine o azul según el juego) → `/configurar/<juego>`.
5. El número de jugadores del selector se guarda en un provider para usarlo como valor inicial en la configuración.
6. Tests: el home muestra los 3 juegos; tocar "Configurar y jugar" navega a la configuración.

## Terminado cuando
El home se ve como `design/stitch/home/screen.png` y lleva a la configuración de cada juego.

## Al terminar
1. `flutter analyze` sin issues y `flutter test` en verde.
2. Actualizar **`README.md`** con lo que cambió en esta fase (y la tabla de estado por fase).
3. Actualizar **`docs/progreso.md`**: estado ✅, commit, decisiones y pendientes para la siguiente sesión.
4. Commit y push a `claude/admiring-cray-ed15pq`.

# Fase 1 — Entorno y fundaciones

**Objetivo:** dejar la base técnica lista para que las fases siguientes solo construyan pantallas:
tema del mockup, router con bottom nav y componentes reutilizables.

**Leer antes:** `design/stitch/DESIGN.md` (tokens, sombras, radios, tipografía) y los `code.html`
(config `tailwind.config` con los colores exactos).

## Tareas
1. Instalar Flutter (ver `docs/progreso.md`) y confirmar que los comandos funcionan; corregirlos allí si no.
2. `pubspec.yaml`: agregar `go_router` y `flutter_riverpod`; declarar la fuente **Outfit**
   (pesos 400–900) en `assets/fonts/` (descargar el TTF variable o estáticos de
   `https://raw.githubusercontent.com/google/fonts/main/ofl/outfit/` + `OFL.txt`).
3. `core/constants/app_color.dart`: reemplazar la paleta morada por los tokens de `DESIGN.md`
   (primary `#3b608c`, primaryContainer `#95baeb`, wine `#930400`/secondary `#b62416`, milk `#fff7e6`,
   ink `#1f1b2e`, surfaces, sombras `#6f97ce` y `#5c0200`).
4. `core/constants/app_spacing.dart`: espaciados (6/12/16/20/24/36) y radios (8/16/24/32/48/full).
5. `core/theme/app_theme.dart`: `ColorScheme` a mano + `TextTheme` con Outfit (headline-xl … label-sm),
   cifras tabulares para números.
6. `app.dart` + `main.dart` (`ProviderScope` → `MaterialApp.router`).
7. `core/router/app_router.dart`: `StatefulShellRoute.indexedStack` con 4 ramas (Explorar `/`,
   Configurar `/configurar`, Marcador `/resultados`, Ajustes `/ajustes`) y rutas `/configurar/:juego`
   y `/partida/:juego` (esta fuera del shell). Pantallas placeholder por ahora.
8. `core/widgets/`: `ChunkyButton` (pill, min 58 px, sombra sólida que se colapsa al presionar),
   `ChunkyCard`, `PillChip`, `SelectionTile`, `SegmentedPills`, `CounterStepper`, `SectionHeader`,
   `RompeloAppBar`, `AppShellScaffold` (bottom nav del mockup con indicador pill).
9. Mover `GameItem` a `features/catalog/domain/game_item.dart` y el catálogo a
   `features/catalog/data/games_catalog.dart` (extender con tag, duración, rango de jugadores, chips,
   color del CTA, ruta de configuración; textos del mockup `home`).
10. Reemplazar `test/widget_test.dart`: la app arranca y muestra la bottom nav; test de `CounterStepper`.

## Terminado cuando
La app compila, navega entre las 4 tabs con placeholders, y los widgets core se ven como en el mockup.

## Al terminar
1. `flutter analyze` sin issues y `flutter test` en verde.
2. Actualizar **`README.md`** con lo que cambió en esta fase (y la tabla de estado por fase).
3. Actualizar **`docs/progreso.md`**: estado ✅, commit, decisiones y pendientes para la siguiente sesión.
4. Commit y push a `claude/admiring-cray-ed15pq`.

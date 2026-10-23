# Plan de desarrollo del Front-end — Rómpelo

> Documento maestro. Cada fase se implementa en una sesión distinta: antes de empezar, lee este
> archivo, [`docs/progreso.md`](progreso.md) y la ficha de la fase en [`docs/fases/`](fases/).

## Contexto
Rómpelo es una app móvil Flutter (Android, 100 % offline, **un solo dispositivo compartido**) que reúne
juegos rompehielo: **Charadas, Trivia e Impostor**. El alcance de este plan es **solo el front**:
todas las pantallas y la navegación fieles al mockup, con los juegos como maquetas navegables
(datos mock, sin lógica real de juego).

Estado inicial del repo: `lib/main.dart` con todo en un archivo (`GameItem`, `RompeloApp`, `MenuScreen`
con 3 juegos que solo muestran un SnackBar), `lib/core/constants/app_color.dart` con una paleta morada que
**no** coincide con el mockup, y `test/widget_test.dart` (test del contador por defecto, falla).

### Requerimientos del documento del proyecto que afectan al front
- RF: catálogo de juegos con descripción · configurar partida (jugadores, categoría, dificultad) · ingresar
  nombres de jugadores · Charadas con temporizador · Trivia con puntaje · Impostor pasando el celular ·
  marcador/ranking final · repetir o cambiar de juego sin reiniciar.
- RNF: offline · un solo dispositivo · iniciar partida en ≤ 3 toques · legible a distancia (fuentes grandes,
  alto contraste) · Android · sin registro · código modular para agregar juegos fácilmente.

## Mockup
Export de Google Stitch en [`design/stitch/`](../design/stitch/): cada carpeta tiene `screen.png`
(captura) y `code.html` (HTML + Tailwind con los estilos exactos). Tokens y reglas del sistema de diseño
en [`design/stitch/DESIGN.md`](../design/stitch/DESIGN.md).

| Carpeta | Ruta | Contenido |
|---|---|---|
| `home` | `/` (tab Explorar) | Header, "¿Qué jugamos hoy?", Selector mágico (stepper jugadores + "¡Elegir juego al azar!"), chips "Explora por vibra", 3 GameCards con "Configurar y jugar" |
| `config_charadas` | `/configurar/charadas` | Modo (equipos / todos vs todos), total jugadores + nombres de equipos, mazos temáticos, reglas (45/60/90 s, penalización, rondas), CTA "¡Empezar a actuar!" |
| `config_trivia` | `/configurar/trivia` | Dinámica de respuesta, participantes, packs de preguntas, reglas (10/15/30 s, puntos dobles, puntos meta), CTA "¡Calentar pulsadores y jugar!" |
| `config_impostor` | `/configurar/impostor` | Jugadores (stepper + chips de nombres), nº impostores, mazos de palabras, dinámica de pase y debate, CTA "Repartir identidades secretas" |
| `partida_charadas` | `/partida/charadas` | Top bar "Salir / Partida en vivo", ronda y marcador, barra de tiempo, carta (Titanic), botones Pasar / ¡Acierto! |
| `partida_trivia` | `/partida/trivia` | Marcador por equipos, "Tiempo crítico", carta de pregunta, opciones A–D, botón "¡Robar turno!" |
| `partida_impostor` | `/partida/impostor` | Timer de debate, fase secreta, turno de pregunta, radar de sospechosos, votar, "Mantén presionado para ver tu rol" |
| `resultados` | `/resultados` (tab Marcador) | Podio top 3, premios de la noche, estadísticas, "¡Jugar revancha!" / "Volver al catálogo" |
| *(no existe)* | tabs Configurar / Ajustes | Configurar: lista de juegos → su config. Ajustes: placeholder simple |

La barra inferior (Explorar · Configurar · Marcador · Ajustes) se ve en home, configuración y resultados.
Las pantallas **en partida** son pantalla completa, sin barra (rutas fuera del shell).

## Stack
| Herramienta | Uso | Por qué |
|---|---|---|
| Flutter 3 / Dart 3 | UI nativa Android | Base de código existente |
| `go_router` | Rutas declarativas, `StatefulShellRoute.indexedStack` para las 4 tabs | Paquete oficial del equipo Flutter; rutas tipo URL, fácil de testear y de extender con juegos nuevos |
| `flutter_riverpod` | Estado de la configuración de partida y marcador mock | Estado tipado, sin `BuildContext`, testeable con `ProviderContainer` |
| Fuente **Outfit** en `assets/fonts/` | Tipografía del mockup | Empaquetada (no `google_fonts` en runtime) para cumplir el RNF offline. Descargar desde `https://raw.githubusercontent.com/google/fonts/main/ofl/outfit/` |
| Material Icons (Rounded) | Iconografía | Equivalentes a los Material Symbols del HTML, ya incluidos en Flutter |

**Imágenes:** las ilustraciones y avatares del mockup vienen de `lh3.googleusercontent.com`, que no se puede
descargar desde el entorno. Se reemplazan por iconos/emoji sobre contenedores de color; quedan listas para
cambiarse por PNG en `assets/images/`.

## Arquitectura (feature-first)
```
lib/
  main.dart                       // runApp(ProviderScope(child: RompeloApp()))
  app.dart                        // MaterialApp.router + AppTheme
  core/
    constants/app_color.dart      // tokens de DESIGN.md (reemplaza la paleta morada)
    constants/app_spacing.dart    // espaciados y radios
    theme/app_theme.dart          // ColorScheme + TextTheme Outfit (headline-xl … label-sm)
    router/app_router.dart        // GoRouter + shell con bottom nav
    widgets/                      // componentes reutilizables del sistema de diseño
      chunky_button.dart          // botón pill con sombra sólida que se "hunde" al presionar
      chunky_card.dart            // tarjeta rounded-3xl con borde sutil y drop inferior
      pill_chip.dart · selection_tile.dart · segmented_pills.dart · counter_stepper.dart
      rompelo_app_bar.dart · live_game_top_bar.dart · timer_bar.dart · section_header.dart
      app_shell_scaffold.dart     // Scaffold con la bottom nav
  features/
    catalog/   domain/game_item.dart · data/games_catalog.dart
               presentation/home_screen.dart · widgets/game_card.dart · widgets/magic_picker_card.dart
    setup/     domain/match_setup.dart · providers/match_setup_provider.dart
               presentation/{charades,trivia,impostor}_config_screen.dart · configure_tab_screen.dart
               widgets/deck_list.dart · widgets/player_names_editor.dart
    games/     data/mock_game_content.dart
               charades/charades_play_screen.dart · trivia/trivia_play_screen.dart · impostor/impostor_play_screen.dart
    results/   presentation/results_screen.dart · widgets/podium.dart · award_tile.dart · stat_tile.dart
    settings/  presentation/settings_screen.dart
```
**Agregar un juego nuevo** = una entrada en `games_catalog.dart` + su pantalla de configuración y de partida + 2 rutas.

## Comportamiento mock (sin lógica real de juego)
- Steppers, toggles, pills y selección de mazos sí cambian estado (Riverpod), para que la UI se sienta viva.
- "¡Elegir juego al azar!" navega a la configuración de un juego aleatorio.
- Partidas: Pasar/Acierto pasan a la siguiente carta mock y suman puntos mock; la opción de trivia se resalta
  al tocarla; "Mantén presionado" muestra el rol mientras se presiona; timer visual decorativo con
  `AnimationController`. "Salir" pide confirmación y vuelve al home. Al terminar las cartas/rondas mock →
  `/resultados`.
- Resultados: "¡Jugar revancha!" vuelve a `/partida/<juego>` con la misma configuración; "Volver al catálogo" → `/`.
- Flujo ≤ 3 toques: Home → "Configurar y jugar" (valores por defecto) → CTA de inicio.

## Fases
| Fase | Ficha | Contenido |
|---|---|---|
| 0 | — | Mockup en el repo, plan, fichas, progreso, README base *(esta sesión)* |
| 1 | [fase-1.md](fases/fase-1.md) | Entorno Flutter + fundaciones (deps, fuente, tema, router, widgets core) |
| 2 | [fase-2.md](fases/fase-2.md) | Home / Explorar |
| 3 | [fase-3.md](fases/fase-3.md) | Pantallas de configuración + provider de setup |
| 4 | [fase-4.md](fases/fase-4.md) | Pantallas en partida (mock) |
| 5 | [fase-5.md](fases/fase-5.md) | Resultados / podio + tabs Configurar y Ajustes |
| 6 | [fase-6.md](fases/fase-6.md) | Tests, pulido visual y README final |

## Flujo de trabajo de cada sesión
1. Leer `docs/plan-front.md`, `docs/progreso.md` y `docs/fases/fase-N.md`.
2. Instalar el SDK de Flutter (el contenedor es efímero; ver instrucciones en `docs/progreso.md`).
3. Implementar la fase en la rama `claude/admiring-cray-ed15pq`.
4. Verificar: `flutter analyze` sin issues y `flutter test` en verde. Comparar con las capturas de `design/stitch/`.
5. **Actualizar `README.md`** con lo que cambió y **`docs/progreso.md`** (estado, commit, decisiones, pendientes).
6. Commit + push. Proponer la siguiente fase en una sesión nueva.

## Verificación visual
`flutter build web` + servidor estático, y capturas con el Chromium preinstalado (Playwright,
`PLAYWRIGHT_BROWSERS_PATH=/opt/pw-browsers`) a ~390 px de ancho para cada ruta, comparadas con los
`screen.png`. No hay emulador Android en el contenedor; el APK se prueba en la máquina del equipo.

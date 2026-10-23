# Progreso del front-end

> Cada sesión lee este archivo al empezar y lo actualiza al terminar (estado, commit, decisiones, pendientes).

## Estado por fase
| Fase | Estado | Commit | Notas |
|---|---|---|---|
| 0 — Plan y documentación | ✅ Hecha | *(ver `git log`)* | Mockup en `design/stitch/`, plan, fichas, README base |
| 1 — Entorno y fundaciones | ✅ Hecha | `da737ad` | Tema, router con 4 tabs, widgets core, catálogo, tests |
| 2 — Home / Explorar | ✅ Hecha | `da836d2` | Home real, MagicPickerCard, GameCard, filtro por vibra, `playerCountProvider` |
| 3 — Configuraciones | ⏳ Pendiente | | |
| 4 — Pantallas en partida | ⏳ Pendiente | | |
| 5 — Resultados y tabs | ⏳ Pendiente | | |
| 6 — Tests, pulido y README final | ⏳ Pendiente | | |

## Instalar Flutter en el contenedor
El contenedor de cada sesión es efímero y no trae Flutter. `storage.googleapis.com` y `pub.dev` son accesibles.
**Confirmado en la Fase 1** (Flutter 3.47.7 stable, Dart 3.13.5; ~2 min):
```bash
cd /opt && git clone --depth 1 -b stable https://github.com/flutter/flutter.git
export PATH="/opt/flutter/bin:$PATH"     # repetir en cada comando de Bash: el PATH no persiste
flutter --version && flutter config --no-analytics
cd /home/user/Rompelo && flutter pub get
```
El aviso "Woah! You appear to be trying to run flutter as root" es inofensivo.

### Verificación visual (web temporal)
El repo solo tiene la plataforma `android/`. Para capturas:
```bash
flutter create --platforms=web .          # temporal: NO commitear web/
flutter build web --no-web-resources-cdn   # sin este flag CanvasKit se pide a la CDN y la página sale en blanco
cd build/web && python3 -m http.server 8765 &
# Playwright (Node, global): NODE_PATH=$(npm root -g) node script.js  → viewport 390x844, URLs http://localhost:8765/#/ruta
```
Al terminar: `rm -rf web build test/widget_test.dart && git checkout -- .metadata analysis_options.yaml`
(`flutter create` regenera el test del contador y toca esos dos archivos).

## Decisiones tomadas
- **Stack:** `go_router` + `flutter_riverpod` (elegido por el equipo).
- **Fuente Outfit empaquetada** en `assets/fonts/` (RNF offline). Fuente: `raw.githubusercontent.com/google/fonts/main/ofl/outfit/`.
- **Imágenes del mockup no descargables** (`lh3.googleusercontent.com` bloqueado) → iconos/emoji sobre contenedores de color.
- **Pantallas sin mockup** (tab Configurar, Ajustes) → diseño simple con los mismos componentes.
- **Juegos sin lógica real**: solo maquetas navegables con datos mock.
- Carpetas del mockup renombradas a nombres cortos (`home`, `config_charadas`, `partida_trivia`, …).
- **Fase 1 — versiones:** `go_router ^17.5.0`, `flutter_riverpod ^3.4.3`, `flutter_lints ^6.0.0` (antes ^3.0.0).
  La restricción `sdk: '>=3.0.0 <4.0.0'` se mantuvo; por eso no se usa sintaxis de Dart ≥ 3.8 (p. ej. `?elemento` en listas).
- **Fase 1 — Outfit variable:** `google/fonts` ya no publica estáticos de Outfit, solo `Outfit[wght].ttf`
  (guardado como `assets/fonts/Outfit-Variable.ttf`). Como es variable, el peso se aplica con
  `FontVariation.weight` además de `fontWeight`: usar siempre `AppTheme.outfit(...)` o
  `AppTheme.withWeight(style, peso)`; un `copyWith(fontWeight: …)` solo **no** cambia el grosor.
- **Fase 1 — router como provider** (`appRouterProvider`): cada `ProviderScope` crea su `GoRouter`, así los
  tests no comparten estado de navegación. Rutas como constantes en `core/router/app_routes.dart`.
- **Fase 1 — `/configurar/:juego`** vive dentro de la rama Configurar del shell (se ve la bottom nav con
  Configurar activa). `/partida/:juego` usa `parentNavigatorKey: rootNavigatorKey` (pantalla completa).
  Un `:juego` que no existe en el catálogo redirige a `/`.
- **Fase 1 — `ChunkyPressable`:** base común del efecto "hundirse" (gesto + estado presionado) que reutilizan
  botón, chips, tiles, segmentos y stepper.
- **Fase 1 — `GameAccent`** (enum en `game_item.dart`) agrupa los colores de tag, icono y CTA de cada juego
  (wine = Charadas, sky = Impostor, warm = Trivia con CTA vino).
- **Fase 1 — `PlaceholderScreen`:** pantalla temporal reutilizada por todas las rutas aún sin UI.
  El home temporal incluye una vitrina de los widgets core (se elimina en la Fase 2).
- **Fase 2 — widgets del catálogo** en `lib/features/catalog/widgets/` (`game_card.dart`, `magic_picker_card.dart`),
  hermanos de `presentation/` como indica el árbol del plan. Son presentacionales: reciben datos y callbacks,
  la navegación y el provider los maneja `HomeScreen`.
- **Fase 2 — `GameVibe`** (enum con emoji + label) y `GameItem.vibes: Set<GameVibe>`. Asignación:
  Charadas = fiesta + chill, Impostor = misterio + chill, Trivia = reflejos + fiesta. Toda vibra tiene al
  menos un juego (hay test); igual existe un mensaje de "sin juegos" por si se agrega una vibra vacía.
- **Fase 2 — `playerCountProvider`** (`NotifierProvider<PlayerCountNotifier, int>`, 2–24, inicial 6) en
  `features/setup/providers/player_count_provider.dart`. Es el primer estado global de Riverpod.
- **Fase 2 — estado local vs global:** la vibra filtrada y la mesa son `setState` en `HomeScreen` (solo
  importan ahí). La **mesa es decorativa** (hoja inferior Mesa 1–8, no se usa en otra pantalla).
- **Fase 2 — azar:** `pickRandomGame` sortea entre los juegos cuyo rango de jugadores incluye al grupo (si
  ninguno cabe, entre todos), muestra un SnackBar "¡Tocó …!" y navega a `/configurar/<juego>`. Recibe un
  `Random` inyectable para tests deterministas.
- **Fase 2 — `RompeloAvatar`** ahora es público para que las pantallas que pasan `actions` al app bar
  (el home pasa campana + avatar) puedan conservarlo.
- **Fase 2 — `PillChip` estático** envuelve el texto en `Flexible` (puede pasar a 2 líneas, como "Actuación &
  risas" en el mockup) para no desbordar en pantallas angostas o con texto grande. Los chips interactivos no,
  porque viven en carruseles horizontales sin ancho máximo.
- **Fase 2 — stepper del selector mágico** con acento azul (`AppColors.primary`) en vez de vino: en el mockup
  ambos botones son neutros; se mantuvo el patrón de `CounterStepper` ("+" de color) con el azul de la tarjeta.
- **Fase 2 — tests de widgets a 800 × 2400 px:** la fuente de test (Ahem) dibuja cada letra de 1 em y
  desborda la bottom nav a 390 px aunque en el dispositivo cabe; el ancho móvil se valida con capturas web.
  En `app_test.dart` (800 × 600) la lista es perezosa: hay que `scrollUntilVisible` + `ensureVisible`
  antes de tocar "Configurar y jugar".
- Se respeta la regla "nunca todo en mayúsculas" de DESIGN.md aunque algunos `code.html` usen `uppercase`
  en etiquetas de sección (`SectionHeader` no las pasa a mayúsculas).

## Pendientes / notas para la siguiente sesión
- **Fase 3**: las pantallas de configuración deben tomar el valor inicial de jugadores de
  `ref.read(playerCountProvider)` (y, si se cambia en la config, decidir si se sincroniza de vuelta).
  `match_setup_provider.dart` puede convivir con `player_count_provider.dart` en `features/setup/providers/`.
- Al reemplazar `GameConfigPlaceholderScreen`, actualizar los tests que tocan "Empezar partida"
  (`test/app_test.dart` y `test/features/catalog/home_screen_test.dart`): el CTA real de cada juego es
  "¡Empezar a actuar!", "¡Calentar pulsadores y jugar!" y "Repartir identidades secretas".
- La campana del home solo muestra un SnackBar (no hay notificaciones reales).
- Widgets que el plan pone en fases posteriores: `LiveGameTopBar` y `TimerBar` (Fase 4).

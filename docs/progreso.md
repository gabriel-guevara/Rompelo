# Progreso del front-end

> Cada sesión lee este archivo al empezar y lo actualiza al terminar (estado, commit, decisiones, pendientes).

## Estado por fase
| Fase | Estado | Commit | Notas |
|---|---|---|---|
| 0 — Plan y documentación | ✅ Hecha | *(ver `git log`)* | Mockup en `design/stitch/`, plan, fichas, README base |
| 1 — Entorno y fundaciones | ✅ Hecha | `da737ad` | Tema, router con 4 tabs, widgets core, catálogo, tests |
| 2 — Home / Explorar | ✅ Hecha | `da836d2` | Home real, MagicPickerCard, GameCard, filtro por vibra, `playerCountProvider` |
| 3 — Configuraciones | ✅ Hecha | `38debcb` | 3 pantallas de config, `MatchSetup` sealed, providers por juego, `DeckList`, `PlayerNamesEditor` |
| 4 — Pantallas en partida | ✅ Hecha | `afb024a` | 3 partidas mock, `LiveGameTopBar`, `TimerBar`, contenido mock, `lastMatchResultProvider` |
| 5 — Resultados y tabs | ✅ Hecha | `036826c` | Marcador con podio/premios/estadísticas, revancha, tabs Configurar y Ajustes |
| 6 — Tests, pulido y README final | ✅ Hecha | `e70878f` | Flujo completo, accesibilidad (30 checks), `_MinTapArea`, capturas, README final |

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
**Fase 4:** las partidas se abren directo con `http://localhost:8765/#/partida/<juego>`. Para interactuar
(scroll con `page.mouse.wheel`) primero hay que mover el ratón sobre el canvas (`page.mouse.move(195, 500)`).
Ojo: `flutter test` con `test/widget_test.dart` de `flutter create` presente falla; bórralo antes.

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
- **Fase 1 — `PlaceholderScreen`:** pantalla temporal reutilizada por todas las rutas aún sin UI
  (eliminada en la Fase 5, cuando ya ninguna ruta la usaba).
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
- **Fase 3 — `MatchSetup` es una `sealed class`** con una subclase por juego (`CharadesSetup`, `TriviaSetup`,
  `ImpostorSetup`): los campos comunes (jugadores, nombres, mazos) en la base, los propios en cada subclase.
  Un `switch` sobre `MatchSetup` obliga a cubrir todos los juegos.
- **Fase 3 — un provider por juego** (`charadesSetupProvider`, `triviaSetupProvider`, `impostorSetupProvider`,
  no `autoDispose`: la config sobrevive para la revancha) + `matchSetupProvider(gameId)` (`Provider.family`,
  solo lectura) para las fases 4 y 5.
- **Fase 3 — jugadores home → config en un solo sentido:** cada notifier toma `playerCountProvider` como
  valor inicial y lo sigue con `ref.listen` (conserva el resto de ajustes). Cambiar jugadores en una
  configuración **no** escribe en el home: los rangos distintos (3-12, 2-20, 4-10) se recortarían en cadena.
- **Fase 3 — reglas en el dominio:** rango de jugadores desde el catálogo; Trivia exige mínimo 2 packs y el
  resto 1 (`toggleDeck` devuelve `false` y la UI muestra un SnackBar); 2 impostores solo desde 6 jugadores
  (al bajar el grupo vuelve a 1 solo).
- **Fase 3 — nombres:** `playerNames` siempre tiene `players` elementos (`resizePlayerNames` conserva los
  editados y completa con Mateo, Clara, David… y luego "Jugador N"). Charadas en "Todos vs todos" muestra el
  editor de nombres en vez de los equipos. Trivia guarda nombres pero el mockup no tiene editor.
- **Fase 3 — desviaciones del mockup:** "Puntos para ganar" es un selector 300/500/1000 (en el mockup es solo
  la píldora "500 pts"); el "Mazo personalizado rápido" muestra un SnackBar "llegan pronto"; borde sólido en
  vez de punteado; el stepper de rondas muestra solo el número; el rango de Trivia se lee del catálogo (2 a 20,
  el mockup dice 4 a 12). Sin botón "atrás" (el mockup no lo tiene; Android usa el gesto del sistema).
- **Fase 3 — `gameConfigScreenFor(game)`** (`presentation/game_config_screen.dart`) elige la pantalla por id:
  agregar un juego = un `case` más.
- **Fase 3 — tests de pantallas** abren la ruta con `appRouterProvider.go(...)` en un viewport de 800 × 3600.
- **Fase 4 — estado efímero vs global:** carta, turno, marcador en curso, opción elegida y sospechosos viven en
  el `State` de cada pantalla (`ConsumerStatefulWidget` + `setState`); solo el **resultado final** sube a
  Riverpod (`lastMatchResultProvider`, en `features/games/providers/match_result_provider.dart`).
- **Fase 4 — configuración congelada:** cada partida lee `ref.read(matchSetupProvider(id))` una vez (con un
  cast al subtipo) en un `late final`: cambiar la config a mitad de partida no debe alterar el marcador.
- **Fase 4 — timers:** `CountdownBuilder` (core) posee el `AnimationController` y da `remaining`/`fraction`
  a un builder; `TimerBar` (estilos `card` = Charadas y `compact` = Trivia) se construye encima, y el Impostor
  usa `CountdownBuilder` directo para su píldora. Reinicio = `key` nueva por turno/pregunta; pausa =
  `running: false` (se reanuda donde quedó). `liveTimersEnabledProvider` (true en la app) se sobreescribe con
  `false` en **todos** los tests que abren partidas (`app_test`, `config_screens_test`, `test/features/games/`),
  porque un timer corriendo hace que `pumpAndSettle` espere el turno entero. El estado `completed` del
  controlador llega un frame **después** de mostrar 0:00 (`isDone` usa `>` estricto).
- **Fase 4 — reglas mock:** Charadas = 3 cartas por turno (o fin del tiempo), turnos alternados por equipo o
  jugador, `rounds × participantes` turnos → resultados; "Pasar" resta 1 (mínimo 0) con penalización.
  Trivia = 12 preguntas (cíclicas), +50 (+100 la última si hay puntos dobles), termina antes si alguien llega a
  la meta; "Pulsador en pantalla" = Team Vino vs Team Burbujas, "Por turnos" = cada jugador suma para sí (el
  marcador muestra quien responde y quien sigue); robar turno una vez por pregunta, -20 si falla; si se acaba
  el tiempo se revela sin puntos. Impostor = tema del primer mazo elegido (orden de `deck_options.dart`),
  palabra = primera de la lista, impostores deterministas `mockImpostors(players, n)` (desde el final de la
  mesa); ganan los ciudadanos si los marcados incluyen a todos los impostores (1 pt c/u), si no los impostores
  (2 pts). La fase secreta de pasar el móvil se da por hecha ("Fase secreta completada").
- **Fase 4 — "Salir":** diálogo "¿Salir de la partida?" con "Sí, salir" / "Seguir jugando" (el botón del diálogo
  no se llama "Salir" para no chocar con el de la barra en los tests). `LiveGameScaffold` envuelve todo en
  `PopScope(canPop: false)` para que el "atrás" de Android pida la misma confirmación.
- **Fase 4 — rol oculto:** `Listener` (eventos crudos `onPointerDown/Up/Cancel`) en vez de `GestureDetector`,
  que retrasa el `onTapDown` dentro de un scroll. El rol se dibuja **encima** del botón: abajo quedaba fuera
  de pantalla al final de la lista. Muestra el rol de quien tiene el turno.
- **Fase 4 — desviaciones del mockup:** "Partida en vivo" y "¡Robar turno!" en tipo oración (no mayúsculas);
  botones de acción fijos abajo (`bottomNavigationBar` del `Scaffold`); avatares emoji en vez de ilustraciones;
  sin animaciones infinitas (ping/pulse/spin) para no romper tests ni distraer; botones extra que el mockup
  no tiene pero el flujo necesita: "Confirmar respuesta"/"Siguiente pregunta" (Trivia), "Siguiente turno"
  (Impostor) y el veredicto de la votación; en Charadas el rival se atenúa para mostrar quién actúa.
- **Fase 5 — `MatchResult` en `features/games/domain/`** (antes en el provider, que ahora lo re-exporta):
  es dominio puro que producen las partidas y consume el marcador. Campos nuevos con valores por defecto
  (`detail`, `plays`, `playsLabel`, `elapsed`, `awards`) para no romper a quien no los use. `scores` se ordena
  en el constructor con `sort` estable (en empate se conserva el orden original).
- **Fase 5 — premios derivados de datos reales de la partida**, no inventados: cada pantalla cuenta aciertos,
  pases, robos exitosos y preguntas hechas, y `bestIndex` elige al mejor (nadie gana con 0). Las estadísticas
  del mockup "Gritos y risas 94 dB" se reemplazaron por "Puntos repartidos" (no hay micrófono) y "Tarjetas
  jugadas" usa el nombre de cada juego ("Preguntas jugadas", "Turnos de pregunta") y la duración real.
- **Fase 5 — podio:** columnas 2-1-3 alineadas por la base; con 2 participantes el bronce queda vacío; del 4.º en
  adelante una tabla (RF ranking final). Avatares emoji (👑 🥈 🥉). Nombres en 2 líneas ("Team Burbujas"). Si
  los dos primeros empatan, el subtítulo dice "¡Empate en la cima!" en vez del `summary`.
- **Fase 5 — confeti estático** (`CustomPainter` con `Random(7)` y `shouldRepaint: false`): sin animación
  infinita, igual que en la Fase 4.
- **Fase 5 — tab Configurar:** cada tarjeta es un `ConsumerWidget` que solo escucha
  `matchSetupProvider(game.id)`; "Jugar" lleva directo a la partida (otro camino de ≤ 3 toques).
  `describeSetup` usa *patterns* de Dart 3 (`CharadesSetup(:final rounds)`), compatibles con `sdk >=3.0`.
- **Fase 5 — Ajustes mock** en `features/settings/providers/app_settings_provider.dart` (`AppSettings` inmutable
  + `Notifier`); aún no hay sonidos ni vibración reales. "Borrar el último marcador" llama a
  `lastMatchResultProvider.notifier.clear()`.
- **Fase 5 — tests:** helper común `test/test_utils.dart` (`pumpAppAt(tester, ruta, prepare:)`, timers
  apagados, viewport 800 × 2400); `game_test_utils.dart` lo reutiliza. En `app_test.dart` (800 × 600) solo se
  buscan textos de la parte visible: las listas son perezosas.
- **Fase 6 — accesibilidad medida, no supuesta:** `test/accessibility_test.dart` corre
  `androidTapTargetGuideline`, `labeledTapTargetGuideline` y `textContrastGuideline` en las 10 rutas (con una
  partida guardada para el marcador). Viewport de 600 px: a 390 la fuente Ahem desborda filas. Contraste y
  etiquetas ya pasaban; fallaban áreas táctiles (steppers 40, chips 34, segmentos 46, "Salir" 44, campo de
  nombre de equipo 42).
- **Fase 6 — `_MinTapArea` en `ChunkyPressable`:** `RenderShiftedBox` propio que hace `child.layout(constraints)`
  **sin modificarlas** y toma `max(hijo, 48)` por eje, centrando el dibujo (misma idea que el `_InputPadding`
  privado de Material). Primer intento: `ConstrainedBox` + `Align(widthFactor: 1)` → `Align` afloja las
  restricciones y los botones "Pasar"/"¡Acierto!" (sin ancho propio dentro de un `Expanded`) se encogían; lo
  detectaron las capturas, no los tests. Regresión cubierta en `test/core/widgets/chunky_pressable_test.dart`
  (se comprobó que ese test falla con la versión anterior). Implementa también los intrínsecos y el dry layout
  (los usa `IntrinsicHeight` en Trivia y en el marcador).
- **Fase 6 — semántica:** con `semanticLabel`, `ChunkyPressable` usa `excludeSemantics: true` (TalkBack leía
  "Por equipos, Por equipos") y repite `onTap` en el `Semantics` porque al excluir hijos se pierde la acción
  del `GestureDetector`. `SelectionTile` anuncia "título. badge. subtítulo" (`whereType<String>()`, no la
  sintaxis `?elemento` de Dart 3.8).
- **Fase 6 — campo de nombre de equipo** (Charadas) con 13 px de padding vertical → 48 px de alto.
- **Fase 6 — marcador:** con 2 participantes el podio dibuja solo plata y oro centrados
  (`FractionallySizedBox` de 2/3, cada columna mantiene su tercio); el confeti se limita al 18 % lateral y
  baja a 60 % de opacidad para no competir con el título (RNF legible a distancia).
- **Fase 6 — tests:** `test/full_flow_test.dart` recorre home → config (baja rondas con el stepper) → partida →
  marcador → revancha (verifica que conserva "Ronda 1/1") → marcador → catálogo, solo con toques.
- **Fase 6 — capturas:** `docs/screenshots/01…10-*.png` (390 × 844 a 1.5x, optimizadas) y `overview.png`
  para la cabecera del README. Se regeneran con el procedimiento de verificación web de arriba.
- **Fase 6 — README** reorganizado por temas (requerimientos ↔ dónde se cumplen, stack y por qué, estructura,
  diseño, rutas, estado, cómo agregar un juego, tests, accesibilidad, changelog).
- Se respeta la regla "nunca todo en mayúsculas" de DESIGN.md aunque algunos `code.html` usen `uppercase`
  en etiquetas de sección (`SectionHeader` no las pasa a mayúsculas).

## Pendientes / siguiente etapa (lógica real de juego)
El plan del front (fases 0–6) está completo. Lo que queda fuera de su alcance, por prioridad sugerida:
1. **Persistencia local** (p. ej. `shared_preferences` o `hive`): hoy la configuración, los ajustes y el último
   marcador viven en memoria y se pierden al cerrar la app. Los `Notifier` ya centralizan el estado: basta con
   cargar en `build()` y guardar al cambiar.
2. **Contenido real**: reemplazar `mock_game_content.dart` por JSON en `assets/` (cientos de cartas/preguntas por
   mazo), barajado aleatorio y sin repetir; el "Mazo personalizado rápido" de Charadas sigue mostrando "llegan pronto".
3. **Lógica de juego real**: impostores aleatorios (hoy `mockImpostors` es determinista), fase secreta de pasar el
   móvil jugador por jugador, votación individual, Trivia con pulsador real y rondas completas.
4. **Sensores y feedback**: giroscopio para "Arriba: Pasar / Abajo: Acierto" en Charadas (`sensors_plus`),
   vibración (`HapticFeedback`), sonidos y `wakelock` para "pantalla siempre encendida" (hoy los ajustes son mock).
5. **Pruebas en dispositivo**: el contenedor no tiene emulador; validar en Android real el arranque < 3 s, el
   rendimiento de las animaciones y el texto grande del sistema (`textScaler`).
6. **Ilustraciones**: los avatares e imágenes del mockup (no descargables desde el entorno) siguen como
   emoji/iconos; se pueden agregar como PNG en `assets/images/`.

# Rómpelo 🎉

App móvil nativa (Flutter · Android) de **juegos rompehielo para grupos** que se juega desde **un solo
dispositivo compartido**, 100 % offline y sin registro. Catálogo inicial: **Charadas alocadas**,
**Trivia relámpago** y **El impostor silencioso**.

> Proyecto de *Desarrollo de Aplicaciones Móviles Nativas* — Ingeniería de Software, UCompensar (Bogotá, 2026).

## Objetivo
Facilitar la interacción social cara a cara usando la menor cantidad de tecnología posible: el celular actúa
como "maestro de juego" y muestra instrucciones, palabras o preguntas mientras el grupo juega en persona.

### Requerimientos clave
- **Funcionales:** catálogo de juegos · configurar partida (jugadores, categorías, dificultad) · nombres de
  jugadores · Charadas con temporizador · Trivia con puntaje · Impostor con roles secretos pasando el celular ·
  marcador y ranking final · repetir o cambiar de juego sin reiniciar.
- **No funcionales:** offline · un solo dispositivo · arranque < 3 s · iniciar partida en ≤ 3 toques ·
  legible a distancia · Android · sin datos personales · código modular para agregar juegos.

## Estado actual
🚧 **En desarrollo del front-end.** El alcance actual son las pantallas y la navegación según el mockup;
los juegos funcionan como maquetas navegables con datos de ejemplo.

| Fase | Contenido | Estado |
|---|---|---|
| 0 | Mockup en el repo, plan y documentación | ✅ |
| 1 | Entorno Flutter + fundaciones (tema, router, widgets core) | ✅ |
| 2 | Home / Explorar | ✅ |
| 3 | Pantallas de configuración | ✅ |
| 4 | Pantallas en partida | ⏳ |
| 5 | Resultados / podio + tabs | ⏳ |
| 6 | Tests, pulido y README final | ⏳ |

Detalle en [`docs/plan-front.md`](docs/plan-front.md) y avance en [`docs/progreso.md`](docs/progreso.md).

## Diseño
El mockup se hizo en Google Stitch y está exportado en [`design/stitch/`](design/stitch/) (captura `screen.png` +
`code.html` por pantalla). El sistema de diseño **"Rómpelo Dynamic Party System"**
([`DESIGN.md`](design/stitch/DESIGN.md)) usa:
- **Colores:** azul cielo `#95baeb` (ambiente), vino `#930400` (acción/tensión), leche `#fff7e6` (superficies),
  tinta ciruela `#1f1b2e` (texto).
- **Tipografía:** Outfit, en mayúsculas y minúsculas normales (nunca todo en mayúsculas), con cifras tabulares.
- **Estilo "chunky":** botones pill y tarjetas muy redondeadas con sombra sólida inferior que se hunde al presionar.

## Stack
| Herramienta | Versión | Para qué |
|---|---|---|
| Flutter / Dart | 3.47 (stable) / 3.13 | UI nativa |
| `go_router` | ^17.5.0 | Navegación declarativa con barra inferior (`StatefulShellRoute.indexedStack`) |
| `flutter_riverpod` | ^3.4.3 | Estado (router, número de jugadores y configuración de cada partida) |
| Fuente Outfit (TTF variable) | `assets/fonts/` | Tipografía empaquetada, funciona offline |
| `flutter_lints` | ^6.0.0 | Reglas de estilo para `flutter analyze` |

## Novedades de la Fase 3
- **Pantallas de configuración reales** para Charadas, Trivia e Impostor (`features/setup/presentation/`),
  fieles a `design/stitch/config_*`. Cada CTA ("¡Empezar a actuar!", "¡Calentar pulsadores y jugar!",
  "Repartir identidades secretas") lleva a `/partida/<juego>`. Se eliminó el placeholder de configuración.
- **Modelo inmutable `MatchSetup`** (`domain/match_setup.dart`): `sealed class` con `CharadesSetup`,
  `TriviaSetup` e `ImpostorSetup` (`copyWith`, rangos de jugadores del catálogo, mínimo de mazos, regla de
  2 impostores desde 6 jugadores).
- **Providers** (`providers/match_setup_provider.dart`): un `Notifier` por juego con valores por defecto
  listos para jugar (flujo ≤ 3 toques) que siguen al selector de jugadores del home con `ref.listen`, y
  `matchSetupProvider(gameId)` para leer cualquier configuración desde la partida o los resultados.
- **Widgets compartidos** (`features/setup/widgets/`): `ConfigScaffold`, `GameConfigHero`, `ConfigSection`,
  `RuleRow`, `RuleSwitch`, `OptionLabel`, `CountBadge`, `DeckList` y `PlayerNamesEditor` (chips "👑 P1 Mateo"
  que se renombran con un diálogo: RF "ingresar nombres"). `SelectionTile` acepta emoji y color de badge.
- **Tests:** dominio, providers (jugadores, mazos, impostores, nombres) y pantallas (CTA → partida, controles
  que cambian el estado, renombrar jugador).

## Novedades de la Fase 2
- **Home real** (`features/catalog/presentation/home_screen.dart`) fiel a `design/stitch/home`: header con
  campana y avatar, "¿Qué jugamos hoy?" con selector de mesa (hoja inferior Mesa 1–8), selector mágico,
  "Explora por vibra" y las tarjetas de juego. Se eliminó la vitrina temporal de la Fase 1.
- **`MagicPickerCard`**: tarjeta azul con degradado, `CounterStepper` de jugadores y "¡Elegir juego al azar!",
  que sortea entre los juegos donde cabe el grupo y navega a su configuración.
- **`GameCard`**: tag, duración/jugadores, título, descripción, ilustración (icono), chips y CTA
  "Configurar y jugar" (vino o azul según el juego) → `/configurar/<juego>`.
- **Filtro por vibra:** nuevo enum `GameVibe` (🎉 Fiesta total, 🕵️ Misterio, ⚡ Reflejos rápidos,
  🍷 Chill con amigos) y campo `vibes` en `GameItem`; el badge cuenta los juegos visibles.
- **Primer provider de estado:** `playerCountProvider` (`features/setup/providers/`) guarda los jugadores
  reunidos (2–24, empieza en 6); la configuración lo usará como valor inicial en la Fase 3.
- **Tests:** home (3 juegos, navegación, filtro, stepper, azar, mesa), provider de jugadores y funciones del
  catálogo (`gamesByVibe`, `pickRandomGame`).

## Novedades de la Fase 1
- **Tema del mockup:** `AppColors` (tokens de `DESIGN.md`, reemplaza la paleta morada), `AppSpacing`/`AppRadius`
  y `AppTheme` con `ColorScheme` hecho a mano y `TextTheme` Outfit (headline-xl … label-sm, cifras tabulares).
- **Navegación:** `go_router` con 4 tabs (Explorar `/`, Configurar `/configurar`, Marcador `/resultados`,
  Ajustes `/ajustes`), `/configurar/:juego` dentro del shell y `/partida/:juego` a pantalla completa.
  Por ahora las pantallas son *placeholders* navegables.
- **Widgets core** (`lib/core/widgets/`): `ChunkyButton`, `ChunkyCard`, `PillChip`, `SelectionTile`,
  `SegmentedPills`, `CounterStepper`, `SectionHeader`, `RompeloAppBar`, `AppShellScaffold` y `PlaceholderScreen`.
  El home temporal incluye una vitrina con todos ellos.
- **Catálogo:** `GameItem` salió de `main.dart` a `features/catalog/` con tag, duración, rango de jugadores,
  chips, color y rutas; los textos son los del mockup.
- **Tests:** se reemplazó el test roto del contador por tests de arranque/navegación, del `CounterStepper` y
  del catálogo.

## Estructura del repositorio
```
lib/
  main.dart · app.dart     arranque (ProviderScope → MaterialApp.router)
  core/constants/          colores, espaciados y radios
  core/theme/              AppTheme (ColorScheme + TextTheme Outfit)
  core/router/             rutas (AppRoutes) y GoRouter con el shell de tabs
  core/widgets/            componentes del sistema de diseño
  features/<feature>/      catalog · setup · games · results · settings
                           (cada una con domain/ data/ providers/ presentation/ widgets/ según necesite)
assets/fonts/              Outfit (variable) + licencia OFL
design/stitch/             mockup exportado + DESIGN.md
docs/                      plan maestro, fichas de fase y progreso
test/                      tests de widgets y unitarios
```

## Cómo ejecutar
Requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) estable (Dart ≥ 3.0) y un emulador o
dispositivo Android.
```bash
flutter pub get
flutter run          # en un emulador o dispositivo Android
flutter analyze      # análisis estático (debe dar "No issues found!")
flutter test         # tests
```

## Equipo
- Gabriel Sebastián Guevara Téllez
- Lesly Daniela Galindo Rivera
- Mateo Leal Rey

Docente: Andrés Felipe Vallejo Sastoque

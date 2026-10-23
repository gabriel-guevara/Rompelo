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
| 1 | Entorno Flutter + fundaciones (tema, router, widgets core) | ⏳ |
| 2 | Home / Explorar | ⏳ |
| 3 | Pantallas de configuración | ⏳ |
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

## Stack (planeado)
| Herramienta | Para qué |
|---|---|
| Flutter 3 / Dart 3 | UI nativa |
| `go_router` | Navegación declarativa con barra inferior (`StatefulShellRoute`) |
| `flutter_riverpod` | Estado de la configuración de partida y marcador |
| Fuente Outfit empaquetada | Tipografía offline |

## Estructura del repositorio
```
lib/                 código de la app (se reorganiza por features en la Fase 1)
design/stitch/       mockup exportado + DESIGN.md
docs/plan-front.md   plan maestro del front
docs/fases/          ficha de cada fase
docs/progreso.md     registro de avance y decisiones
test/                tests de widgets
```

## Cómo ejecutar
Requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) estable (Dart ≥ 3.0) y un emulador o
dispositivo Android.
```bash
flutter pub get
flutter run
```

## Equipo
- Gabriel Sebastián Guevara Téllez
- Lesly Daniela Galindo Rivera
- Mateo Leal Rey

Docente: Andrés Felipe Vallejo Sastoque

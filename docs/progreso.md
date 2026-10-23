# Progreso del front-end

> Cada sesión lee este archivo al empezar y lo actualiza al terminar (estado, commit, decisiones, pendientes).

## Estado por fase
| Fase | Estado | Commit | Notas |
|---|---|---|---|
| 0 — Plan y documentación | ✅ Hecha | *(ver `git log`)* | Mockup en `design/stitch/`, plan, fichas, README base |
| 1 — Entorno y fundaciones | ⏳ Pendiente | | |
| 2 — Home / Explorar | ⏳ Pendiente | | |
| 3 — Configuraciones | ⏳ Pendiente | | |
| 4 — Pantallas en partida | ⏳ Pendiente | | |
| 5 — Resultados y tabs | ⏳ Pendiente | | |
| 6 — Tests, pulido y README final | ⏳ Pendiente | | |

## Instalar Flutter en el contenedor
El contenedor de cada sesión es efímero y no trae Flutter. `storage.googleapis.com` y `pub.dev` son accesibles:
```bash
cd /opt && git clone --depth 1 -b stable https://github.com/flutter/flutter.git
export PATH="/opt/flutter/bin:$PATH"
flutter --version && flutter config --no-analytics
cd /home/user/Rompelo && flutter pub get
```
*(La Fase 1 debe confirmar o corregir estos comandos.)*

## Decisiones tomadas
- **Stack:** `go_router` + `flutter_riverpod` (elegido por el equipo).
- **Fuente Outfit empaquetada** en `assets/fonts/` (RNF offline). Fuente: `raw.githubusercontent.com/google/fonts/main/ofl/outfit/`.
- **Imágenes del mockup no descargables** (`lh3.googleusercontent.com` bloqueado) → iconos/emoji sobre contenedores de color.
- **Pantallas sin mockup** (tab Configurar, Ajustes) → diseño simple con los mismos componentes.
- **Juegos sin lógica real**: solo maquetas navegables con datos mock.
- Carpetas del mockup renombradas a nombres cortos (`home`, `config_charadas`, `partida_trivia`, …).

## Pendientes / notas para la siguiente sesión
- `test/widget_test.dart` es el test del contador por defecto y falla: reemplazarlo en la Fase 1.
- `lib/core/constants/app_color.dart` tiene una paleta morada que no coincide con el mockup: reemplazarla en la Fase 1.

# Fase 6 — Tests, pulido y README final

## Tareas
1. Test de flujo completo: home → configurar → partida → resultados → revancha / catálogo.
2. Revisión visual: `flutter build web`, capturas con el Chromium preinstalado a ~390 px de cada ruta y
   comparación con `design/stitch/*/screen.png`; corregir diferencias de espaciado, colores y tipografía.
3. Accesibilidad / RNF: contraste, tamaños de fuente grandes, áreas táctiles ≥ 48 px, `Semantics` en botones de icono,
   ancho máximo de 540 px en tablets (según `DESIGN.md`).
4. Limpieza: eliminar código muerto, `flutter analyze` sin warnings, `dart format .`.
5. **README final completo:** descripción y objetivo · capturas (guardar en `docs/screenshots/`) ·
   stack y por qué · requisitos e instalación · estructura de carpetas · sistema de diseño · navegación y rutas ·
   gestión de estado · cómo agregar un juego nuevo · tests y comandos · estado por fase / changelog · equipo.

## Terminado cuando
Tests en verde, la app se ve como el mockup y el README sirve de documentación completa del front.

## Al terminar
1. `flutter analyze` sin issues y `flutter test` en verde.
2. Actualizar **`README.md`** con lo que cambió en esta fase (y la tabla de estado por fase).
3. Actualizar **`docs/progreso.md`**: estado ✅, commit, decisiones y pendientes para la siguiente sesión.
4. Commit y push a `claude/admiring-cray-ed15pq`.

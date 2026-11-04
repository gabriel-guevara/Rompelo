# Colombia Makes Money (CMM)

Sitio web de educación financiera para adultos colombianos de 18 a 50 años, hecho por **Clan Rata Negra**.
Es una adaptación del proyecto *Fast-Learn* (Estructura de Datos): se mantiene el **árbol n-ario de rutas
de aprendizaje** con búsqueda en profundidad y recorrido **preorden**, ahora con temas de finanzas personales
y una paleta **amarillo + crema**.

## Cómo abrirlo
No necesita instalación: abre `Html/index.html` en el navegador (requiere internet para Tailwind y la fuente Poppins).

## Estructura
```
colombia-makes-money/
├── Html/
│   ├── index.html        # Inicio: problema, temas, objetivos y equipo
│   ├── rutas.html        # Buscador de rutas (árbol + preorden)
│   └── presupuesto.html  # Plantilla de presupuesto 50/30/20
├── JavaScript/
│   ├── tema.js           # Paleta Tailwind: crema, amarillo, cafe
│   ├── layout.js         # Navbar y footer compartidos (DRY)
│   ├── Nodos.js          # Clase Nodos + buscarNodoPorTema + generarRutaPreorden
│   ├── rutas-datos.js    # Los 5 temas y sus niveles → construirArbol()
│   ├── buscador.js       # Interfaz del buscador
│   └── presupuesto.js    # Calculadora 50/30/20
└── Imagenes/logo.svg
```

## El árbol
```
Finanzas personales (Raíz)
├── Presupuesto personal ─ Básico → Intermedio → Avanzado
├── Ahorro y fondo de emergencia ─ Básico → Intermedio → Avanzado
├── Manejo de deudas y crédito ─ Básico → Intermedio → Avanzado
├── Tasas de interés y tasa de cambio ─ Básico → Intermedio → Avanzado
└── Inversión ─ Básico → Intermedio → Avanzado
```
Cada nivel es hijo del anterior, así que el preorden desde el nodo encontrado da el orden de estudio.
La búsqueda ignora mayúsculas y tildes y usa palabras clave (`"TRM"`, `"tarjeta"`, `"CDT"`…).
También se puede enlazar directo: `rutas.html?tema=ahorro`.

## Cambios respecto a Fast-Learn
- Paleta amarillo/crema definida una sola vez en `tema.js`.
- Navbar/footer en `layout.js` en vez de copiados en cada página.
- Datos separados de la estructura (`rutas-datos.js` vs `Nodos.js`).
- Corrige: comparación `'Raíz'` vs `"Raiz"`, colores por nivel que nunca coincidían (`básico` vs `Basico`),
  y XSS al mostrar el texto del usuario con `innerHTML`.
- Búsqueda con `<form>` (Enter funciona), selector de nivel inicial y chips de temas.
- Nueva página de presupuesto 50/30/20.

> Los enlaces de recursos apuntan a sitios oficiales (Banco de la República, Superfinanciera, Fogafín,
> AMV, BVC, Asobancaria) y a Khan Academy/Investopedia; conviene revisarlos antes de la entrega.

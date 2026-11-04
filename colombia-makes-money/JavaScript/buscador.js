/**
 * buscador.js — Capa de interfaz de la página "Rutas".
 *
 * Depende de Nodos.js (algoritmos) y rutas-datos.js (árbol `raiz` y TEMAS).
 * Aquí solo se lee el formulario, se llama al árbol y se pinta el resultado.
 */

/**
 * Escapa texto antes de meterlo en innerHTML.
 * En Fast-Learn el texto del usuario se insertaba tal cual: escribir
 * <img src=x onerror=alert(1)> ejecutaba código (XSS). Con esto se muestra como texto.
 */
function escaparHTML(texto) {
    const div = document.createElement("div");
    div.textContent = texto;
    return div.innerHTML;
}

// Estilo visual por nivel (una tabla en vez de una cadena de if/else)
const ESTILO_NIVEL = {
    [NIVELES.BASICO]: "bg-amarillo-200 text-cafe-900",
    [NIVELES.INTERMEDIO]: "bg-amarillo-400 text-cafe-900",
    [NIVELES.AVANZADO]: "bg-cafe-900 text-amarillo-300",
};

function tarjetaPaso(paso, indice, esUltimo) {
    const recursos = paso.recursos
        .map((r) => `<li><a href="${r.url}" target="_blank" rel="noopener noreferrer"
                          class="underline decoration-amarillo-500 decoration-2 underline-offset-2 hover:text-amarillo-700">${r.nombre}</a></li>`)
        .join("");

    const puntos = paso.aprenderas.map((p) => `<li>${p}</li>`).join("");

    return `
        <li class="relative pl-14 ${esUltimo ? "" : "pb-8"}">
            <!-- Línea vertical que une los pasos (la "rama" del árbol) -->
            ${esUltimo ? "" : '<span class="absolute left-[1.15rem] top-10 bottom-0 w-1 bg-amarillo-300 rounded"></span>'}
            <span class="absolute left-0 top-0 w-10 h-10 rounded-full bg-amarillo-500 text-cafe-900 font-bold flex items-center justify-center shadow">${indice + 1}</span>

            <article class="bg-crema-50 border border-crema-300 rounded-2xl p-5 shadow-sm">
                <div class="flex flex-wrap items-center gap-2 mb-2">
                    <span class="text-xs font-semibold px-2.5 py-1 rounded-full ${ESTILO_NIVEL[paso.nivel]}">${paso.nivel}</span>
                    <span class="text-xs text-cafe-500">${paso.perfil}</span>
                </div>
                <h4 class="text-lg font-bold text-cafe-900">${paso.nombreTemas}: ${paso.descripcion}</h4>

                <h5 class="font-semibold mt-3 text-sm text-cafe-700">Aprenderás a:</h5>
                <ul class="list-disc list-inside text-sm text-cafe-700 space-y-0.5">${puntos}</ul>

                <h5 class="font-semibold mt-3 text-sm text-cafe-700">Recursos sugeridos:</h5>
                <ul class="list-disc list-inside text-sm text-cafe-700 space-y-0.5">${recursos}</ul>
            </article>
        </li>`;
}

function renderizarRuta(ruta, contenedor) {
    const tema = ruta[0].nombreTemas;
    contenedor.innerHTML = `
        <h3 class="text-2xl font-bold mb-1 text-cafe-900">Tu ruta: ${tema}</h3>
        <p class="text-cafe-500 mb-6">${ruta.length} ${ruta.length === 1 ? "paso" : "pasos"}, en el orden recomendado.</p>
        <ol>${ruta.map((paso, i) => tarjetaPaso(paso, i, i === ruta.length - 1)).join("")}</ol>`;
}

function mostrarMensaje(contenedor, html) {
    contenedor.innerHTML = `<p class="bg-amarillo-200 border border-amarillo-400 text-cafe-900 rounded-xl p-4">${html}</p>`;
}

/** Botones "chip" con los temas disponibles, generados desde el propio árbol. */
function renderizarSugerencias(contenedor, alElegir) {
    contenedor.innerHTML = raiz.hijos
        .map((t) => `<button type="button" data-tema="${t.nombreTemas}"
                      class="px-3 py-1.5 rounded-full border border-amarillo-500 bg-crema-50 text-sm text-cafe-900 hover:bg-amarillo-300 transition">${t.nombreTemas}</button>`)
        .join("");

    // Delegación de eventos: un solo listener en el contenedor en vez de uno por botón
    contenedor.addEventListener("click", (e) => {
        const boton = e.target.closest("button[data-tema]");
        if (boton) alElegir(boton.dataset.tema);
    });
}

document.addEventListener("DOMContentLoaded", () => {
    const formulario = document.getElementById("form-buscar");
    const inputTema = document.getElementById("input-tema");
    const selectNivel = document.getElementById("select-nivel");
    const resultados = document.getElementById("resultados-ruta");
    const sugerencias = document.getElementById("sugerencias");

    if (!formulario || !inputTema || !resultados) {
        console.error("buscador.js: faltan #form-buscar, #input-tema o #resultados-ruta en el HTML.");
        return;
    }

    function buscar() {
        const tema = inputTema.value.trim();
        const nivel = selectNivel?.value || null;

        if (tema === "") {
            mostrarMensaje(resultados, "Escribe un tema para buscar, por ejemplo <strong>ahorro</strong> o <strong>tarjeta de crédito</strong>.");
            return;
        }

        const nodoInicio = buscarNodoPorTema(raiz, tema, nivel);

        if (!nodoInicio) {
            mostrarMensaje(resultados,
                `No encontramos rutas para "<strong>${escaparHTML(tema)}</strong>". Prueba con uno de los temas de arriba.`);
            return;
        }

        renderizarRuta(generarRutaPreorden(nodoInicio), resultados);
    }

    // Usamos "submit" del <form>: funciona con clic Y con la tecla Enter.
    formulario.addEventListener("submit", (e) => {
        e.preventDefault();
        buscar();
    });

    if (sugerencias) {
        renderizarSugerencias(sugerencias, (tema) => {
            inputTema.value = tema;
            buscar();
        });
    }

    // Permite enlazar directo a una ruta: rutas.html?tema=ahorro
    const temaURL = new URLSearchParams(window.location.search).get("tema");
    if (temaURL) {
        inputTema.value = temaURL;
        buscar();
    }
});

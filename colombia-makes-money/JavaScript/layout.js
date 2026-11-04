/**
 * layout.js — Navbar y footer compartidos.
 *
 * En Fast-Learn el navbar y el footer estaban copiados en cada HTML. Si se
 * agregaba una página había que editar TODOS los archivos (viola DRY).
 * Aquí se definen una sola vez y se "inyectan" en los contenedores
 * <header id="app-nav"> y <footer id="app-footer"> de cada página.
 */

// Única fuente de verdad para la navegación: agregar una página = agregar una línea.
const PAGINAS = [
    { href: "index.html", texto: "Inicio" },
    { href: "rutas.html", texto: "Rutas" },
    { href: "presupuesto.html", texto: "Presupuesto" },
];

/** Devuelve el nombre del archivo actual (ej. "rutas.html"). */
function paginaActual() {
    const archivo = window.location.pathname.split("/").pop();
    return archivo === "" ? "index.html" : archivo;
}

function renderizarNav(contenedor) {
    const actual = paginaActual();

    const enlaces = PAGINAS.map(({ href, texto }) => {
        const activa = href === actual;
        // aria-current le dice a los lectores de pantalla en qué página está el usuario
        return `<a href="${href}" ${activa ? 'aria-current="page"' : ""}
                   class="px-3 py-1.5 rounded-full transition ${activa
                ? "bg-cafe-900 text-amarillo-300"
                : "hover:bg-amarillo-300"}">${texto}</a>`;
    }).join("");

    contenedor.className = "sticky top-0 z-20 bg-amarillo-400 shadow-md";
    contenedor.innerHTML = `
        <nav class="max-w-6xl mx-auto px-4 py-3 flex flex-wrap items-center justify-between gap-3 text-cafe-900 font-semibold">
            <a href="index.html" class="flex items-center gap-2">
                <img src="../Imagenes/logo.svg" alt="" class="w-9 h-9">
                <span class="text-lg font-bold tracking-tight">Colombia Makes Money</span>
            </a>
            <div class="flex gap-1 text-sm sm:text-base">${enlaces}</div>
        </nav>`;
}

function renderizarFooter(contenedor) {
    const enlaces = PAGINAS
        .map(({ href, texto }) => `<li><a href="${href}" class="hover:text-amarillo-300">${texto}</a></li>`)
        .join("");

    contenedor.className = "bg-cafe-900 text-crema-200 mt-16";
    contenedor.innerHTML = `
        <div class="max-w-6xl mx-auto px-4 py-10 grid grid-cols-1 md:grid-cols-3 gap-8">
            <div>
                <div class="flex items-center gap-3 mb-3">
                    <img src="../Imagenes/logo.svg" alt="Logo de Colombia Makes Money" class="w-14 h-14">
                    <h2 class="text-xl font-bold text-amarillo-300">Colombia<br>Makes Money</h2>
                </div>
                <p class="text-sm text-crema-300">Un proyecto de <strong>Clan Rata Negra</strong>.</p>
            </div>

            <div>
                <h3 class="text-lg font-semibold mb-3 text-amarillo-300">Enlaces rápidos</h3>
                <ul class="space-y-2">${enlaces}</ul>
            </div>

            <div>
                <h3 class="text-lg font-semibold mb-3 text-amarillo-300">Sobre el proyecto</h3>
                <p class="text-sm text-crema-300">
                    Plataforma de e-learning para que adultos colombianos de 18 a 50 años aprendan a manejar
                    su presupuesto, ahorrar, controlar sus deudas e invertir con criterio.
                </p>
            </div>
        </div>`;
}

document.addEventListener("DOMContentLoaded", () => {
    const nav = document.getElementById("app-nav");
    const footer = document.getElementById("app-footer");
    if (nav) renderizarNav(nav);
    if (footer) renderizarFooter(footer);
});

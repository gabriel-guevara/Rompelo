/**
 * presupuesto.js — Calculadora de presupuesto 50/30/20.
 *
 * Separación en dos partes:
 *  1. Funciones PURAS (calcularPresupuesto, compararGasto): reciben números y
 *     devuelven números/objetos. No tocan el DOM → fáciles de probar.
 *  2. Funciones de INTERFAZ: leen inputs y pintan el resultado.
 */

const CATEGORIAS = [
    { id: "necesidades", nombre: "Necesidades", porcentaje: 0.5, color: "bg-amarillo-500" },
    { id: "gustos", nombre: "Gustos", porcentaje: 0.3, color: "bg-amarillo-300" },
    { id: "ahorro", nombre: "Ahorro y deudas", porcentaje: 0.2, color: "bg-cafe-900" },
];

// Intl formatea moneda según el país: 1500000 → "$ 1.500.000"
const formatoCOP = new Intl.NumberFormat("es-CO", {
    style: "currency",
    currency: "COP",
    maximumFractionDigits: 0,
});

/** Monto recomendado por categoría para un ingreso dado. */
function calcularPresupuesto(ingreso) {
    return CATEGORIAS.map((c) => ({ ...c, recomendado: ingreso * c.porcentaje }));
}

/**
 * Compara lo gastado con lo recomendado.
 * En "ahorro" gastar MÁS es bueno; en las demás categorías es una alerta.
 */
function compararGasto(categoria, recomendado, real) {
    if (real === null) return null;
    const diferencia = real - recomendado;
    if (Math.abs(diferencia) < 1) return { tono: "ok", texto: "Justo en la meta." };

    const monto = formatoCOP.format(Math.abs(diferencia));
    if (categoria === "ahorro") {
        return diferencia > 0
            ? { tono: "ok", texto: `¡Bien! Ahorras ${monto} más de la meta.` }
            : { tono: "alerta", texto: `Te faltan ${monto} para la meta de ahorro.` };
    }
    return diferencia > 0
        ? { tono: "alerta", texto: `Te pasas por ${monto}.` }
        : { tono: "ok", texto: `Te sobran ${monto}.` };
}

/** Convierte el valor de un input en número, o null si está vacío/no es válido. */
function leerNumero(input) {
    const valor = parseFloat(input.value);
    return Number.isFinite(valor) && valor >= 0 ? valor : null;
}

function renderizarResultado(contenedor, ingreso, gastosReales) {
    const filas = calcularPresupuesto(ingreso).map((c) => {
        const real = gastosReales[c.id];
        const comparacion = compararGasto(c.id, c.recomendado, real);
        const anchoReal = real === null ? 0 : Math.min(100, (real / ingreso) * 100);

        return `
            <div class="bg-crema-50 rounded-2xl p-4 shadow-sm">
                <div class="flex justify-between items-baseline mb-2">
                    <span class="font-semibold">${c.nombre} · ${c.porcentaje * 100} %</span>
                    <span class="text-xl font-bold">${formatoCOP.format(c.recomendado)}</span>
                </div>
                <div class="h-3 bg-crema-200 rounded-full" title="Recomendado">
                    <div class="h-3 ${c.color} rounded-full" style="width:${c.porcentaje * 100}%"></div>
                </div>
                ${real === null ? "" : `
                <div class="h-3 bg-crema-200 rounded-full mt-1.5" title="Lo que gastas hoy">
                    <div class="h-3 rounded-full ${comparacion.tono === "ok" ? "bg-cafe-500" : "bg-red-500"}" style="width:${anchoReal}%"></div>
                </div>
                <p class="text-sm mt-2 ${comparacion.tono === "ok" ? "text-cafe-700" : "text-red-700 font-semibold"}">
                    Hoy: ${formatoCOP.format(real)} — ${comparacion.texto}
                </p>`}
            </div>`;
    }).join("");

    const totalReal = Object.values(gastosReales).reduce((suma, v) => suma + (v ?? 0), 0);
    const aviso = totalReal > ingreso
        ? `<p class="bg-red-100 text-red-800 border border-red-300 rounded-xl p-3 text-sm font-semibold">
               Gastas ${formatoCOP.format(totalReal - ingreso)} más de lo que ganas. Revisa la ruta de
               <a class="underline" href="rutas.html?tema=deudas">manejo de deudas</a>.
           </p>`
        : "";

    contenedor.innerHTML = `
        <h2 class="text-2xl font-bold mb-1">Tu presupuesto</h2>
        <p class="text-cafe-700 mb-5">Para un ingreso de <strong>${formatoCOP.format(ingreso)}</strong> al mes.</p>
        <div class="space-y-4">${aviso}${filas}</div>
        <p class="text-xs text-cafe-700 mt-5">Barra superior: recomendado · barra inferior: lo que gastas hoy.</p>`;
}

document.addEventListener("DOMContentLoaded", () => {
    const formulario = document.getElementById("form-presupuesto");
    const inputIngreso = document.getElementById("ingreso");
    const inputsGasto = formulario.querySelectorAll("[data-categoria]");
    const resultado = document.getElementById("resultado-presupuesto");

    function actualizar() {
        const ingreso = leerNumero(inputIngreso);
        if (!ingreso) {
            resultado.innerHTML = `<p class="text-cafe-700">Escribe tu ingreso para ver tu presupuesto recomendado.</p>`;
            return;
        }

        // { necesidades: 900000, gustos: null, ahorro: 200000 }
        const gastosReales = Object.fromEntries(
            [...inputsGasto].map((input) => [input.dataset.categoria, leerNumero(input)])
        );
        renderizarResultado(resultado, ingreso, gastosReales);
    }

    // "input" se dispara con cada tecla → el resultado se actualiza en vivo, sin botón.
    formulario.addEventListener("input", actualizar);
    formulario.addEventListener("submit", (e) => e.preventDefault());
});

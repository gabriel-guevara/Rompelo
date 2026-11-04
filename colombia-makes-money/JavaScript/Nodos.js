/**
 * Nodos.js — Estructura de datos: árbol n-ario de rutas de aprendizaje.
 *
 * Este archivo SOLO contiene la estructura y sus algoritmos (sin DOM), igual
 * que una clase de "modelo". Así se puede reutilizar o probar por separado.
 *
 *   Raíz ("Finanzas personales")
 *    ├── Tema "Presupuesto personal"   (nivel General)
 *    │     └── Básico → Intermedio → Avanzado   (cadena de prerrequisitos)
 *    ├── Tema "Ahorro..."
 *    └── ...
 *
 * Cada nivel es HIJO del anterior: para llegar a "Avanzado" el árbol obliga a
 * pasar por "Básico" e "Intermedio". El recorrido preorden de esa rama produce
 * justamente el orden en que se debe estudiar.
 */

const NIVELES = {
    RAIZ: "Raíz",
    GENERAL: "General",
    BASICO: "Básico",
    INTERMEDIO: "Intermedio",
    AVANZADO: "Avanzado",
};

class Nodos {
    /**
     * @param {string}   nombreTemas   Nombre del tema (ej. "Ahorro").
     * @param {string}   nivel         Uno de NIVELES.
     * @param {object}   [detalle]
     * @param {string}   [detalle.perfil]       A quién va dirigido el paso.
     * @param {string}   [detalle.descripcion]  Qué se aprende en este paso.
     * @param {string[]} [detalle.aprenderas]   Puntos clave del paso.
     * @param {{nombre: string, url: string}[]} [detalle.recursos]
     * @param {string[]} [detalle.palabrasClave] Sinónimos para el buscador (ej. "TRM", "dólar").
     */
    constructor(nombreTemas, nivel, detalle = {}) {
        this.nombreTemas = nombreTemas;
        this.nivel = nivel;
        this.perfil = detalle.perfil ?? "Adultos de 18 a 50 años";
        this.descripcion = detalle.descripcion ?? "";
        this.aprenderas = detalle.aprenderas ?? [];
        this.recursos = detalle.recursos ?? [];
        this.palabrasClave = detalle.palabrasClave ?? [];
        this.hijos = [];
    }

    agregarHijos(nodoHijo) {
        this.hijos.push(nodoHijo);
        return nodoHijo; // permite encadenar: basico.agregarHijos(intermedio).agregarHijos(avanzado)
    }

    /** true para los nodos que son pasos reales de estudio (no raíz ni tema general). */
    esPaso() {
        return this.nivel !== NIVELES.RAIZ && this.nivel !== NIVELES.GENERAL;
    }
}

/**
 * Normaliza texto para comparar: minúsculas y SIN tildes.
 * "Inversión" y "inversion" quedan iguales → el usuario no tiene que acertar la tilde.
 * NFD separa "ó" en "o" + "◌́" y la regex elimina la marca diacrítica.
 */
function normalizar(texto) {
    return texto
        .toLowerCase()
        .normalize("NFD")
        .replace(/[̀-ͯ]/g, "")
        .trim();
}

/** ¿El nodo coincide con la búsqueda por nombre o por alguna palabra clave? */
function coincide(nodo, busqueda) {
    const candidatos = [nodo.nombreTemas, ...nodo.palabrasClave].map(normalizar);
    return candidatos.some((c) => c.includes(busqueda) || busqueda.includes(c));
}

/**
 * Búsqueda en profundidad (DFS) del primer nodo que coincida con el tema.
 * Si se pasa `nivel`, devuelve el nodo de ese nivel dentro del tema encontrado.
 *
 * @param {Nodos}  nodo
 * @param {string} tema
 * @param {string|null} [nivel] Nivel desde el que se quiere empezar (opcional).
 * @returns {Nodos|null}
 */
function buscarNodoPorTema(nodo, tema, nivel = null) {
    if (!nodo) return null;
    const busqueda = normalizar(tema);
    if (busqueda === "") return null;

    // La raíz no se compara (si no, "finanzas" devolvería TODO el árbol).
    if (nodo.nivel !== NIVELES.RAIZ && coincide(nodo, busqueda)) {
        return nivel ? buscarNivel(nodo, nivel) : nodo;
    }

    for (const hijo of nodo.hijos) {
        const resultado = buscarNodoPorTema(hijo, tema, nivel);
        if (resultado) return resultado;
    }
    return null;
}

/** Busca, dentro de un subárbol, el nodo con el nivel indicado. */
function buscarNivel(nodo, nivel) {
    if (nodo.nivel === nivel) return nodo;
    for (const hijo of nodo.hijos) {
        const encontrado = buscarNivel(hijo, nivel);
        if (encontrado) return encontrado;
    }
    return null;
}

/**
 * Recorrido PREORDEN (nodo → hijos) para generar la ruta de aprendizaje.
 * Excluye la raíz y los nodos "General" porque no son pasos de estudio.
 *
 * @param {Nodos} nodo
 * @param {Nodos[]} [ruta] Acumulador.
 * @returns {Nodos[]}
 */
function generarRutaPreorden(nodo, ruta = []) {
    if (!nodo) return ruta;

    if (nodo.esPaso()) ruta.push(nodo);

    for (const hijo of nodo.hijos) {
        generarRutaPreorden(hijo, ruta);
    }
    return ruta;
}

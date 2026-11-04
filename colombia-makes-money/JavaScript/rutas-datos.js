/**
 * rutas-datos.js — Contenido del árbol de Colombia Makes Money.
 *
 * Los temas salen del documento del proyecto: presupuesto, ahorro, deudas,
 * tasas de interés / tasa de cambio e inversión. Separar los DATOS de la
 * ESTRUCTURA (Nodos.js) permite agregar o editar rutas sin tocar algoritmos.
 *
 * Para agregar un tema nuevo: añade un objeto a TEMAS con sus tres niveles.
 */

// Recursos reutilizados en varias rutas (DRY)
const R = {
    saberMas: { nombre: "Saber más, ser más — Asobancaria", url: "https://www.sabermassermas.com/" },
    khanFinanzas: { nombre: "Khan Academy — Finanzas personales", url: "https://www.khanacademy.org/college-careers-more/personal-finance" },
    banrep: { nombre: "Banco de la República", url: "https://www.banrep.gov.co/" },
    banrepTRM: { nombre: "Banco de la República — TRM", url: "https://www.banrep.gov.co/es/estadisticas/trm" },
    superfinanciera: { nombre: "Superintendencia Financiera de Colombia", url: "https://www.superfinanciera.gov.co/" },
    fogafin: { nombre: "Fogafín — Seguro de depósitos", url: "https://www.fogafin.gov.co/" },
    bvc: { nombre: "Bolsa de Valores de Colombia", url: "https://www.bvc.com.co/" },
    amv: { nombre: "AMV — Autorregulador del Mercado de Valores", url: "https://www.amvcolombia.org.co/" },
    investopedia: { nombre: "Investopedia (en inglés)", url: "https://www.investopedia.com/" },
};

const TEMAS = [
    {
        nombre: "Presupuesto personal",
        palabrasClave: ["presupuesto", "gastos", "ingresos", "50/30/20", "quincena", "salario", "plantilla"],
        niveles: {
            [NIVELES.BASICO]: {
                perfil: "Primer empleo o primer sueldo",
                descripcion: "Entiende a dónde se va tu dinero cada mes.",
                aprenderas: ["Diferenciar ingresos fijos y variables", "Registrar gastos durante 30 días", "Separar necesidades de deseos"],
                recursos: [R.saberMas, R.khanFinanzas],
            },
            [NIVELES.INTERMEDIO]: {
                perfil: "Ingresos estables, sin control de gastos",
                descripcion: "Arma un presupuesto mensual y cúmplelo.",
                aprenderas: ["Aplicar la regla 50/30/20", "Usar una plantilla de presupuesto", "Planear gastos anuales (SOAT, primas, matrículas)"],
                recursos: [R.khanFinanzas, R.saberMas],
            },
            [NIVELES.AVANZADO]: {
                perfil: "Hogares con varios ingresos o independientes",
                descripcion: "Presupuesto por objetivos y ingresos irregulares.",
                aprenderas: ["Presupuesto base cero", "Manejar ingresos de independiente", "Revisar el presupuesto cada trimestre"],
                recursos: [R.investopedia, R.khanFinanzas],
            },
        },
    },
    {
        nombre: "Ahorro y fondo de emergencia",
        palabrasClave: ["ahorro", "ahorrar", "emergencia", "imprevistos", "cdt", "cuenta de ahorros"],
        niveles: {
            [NIVELES.BASICO]: {
                perfil: "No logras ahorrar a fin de mes",
                descripcion: "Crea el hábito: págate primero a ti.",
                aprenderas: ["Ahorrar al recibir el sueldo, no al final", "Metas de ahorro pequeñas y medibles", "Cuentas de ahorro y depósitos de bajo monto"],
                recursos: [R.saberMas, R.fogafin],
            },
            [NIVELES.INTERMEDIO]: {
                perfil: "Ya ahorras, pero sin un objetivo claro",
                descripcion: "Construye un fondo de emergencia de 3 a 6 meses.",
                aprenderas: ["Calcular tu fondo de emergencia", "Comparar cuentas y CDT", "Qué cubre el seguro de depósitos de Fogafín"],
                recursos: [R.fogafin, R.superfinanciera],
            },
            [NIVELES.AVANZADO]: {
                perfil: "Fondo de emergencia completo",
                descripcion: "Ahorro de largo plazo y protección contra la inflación.",
                aprenderas: ["Inflación y poder adquisitivo", "Ahorro para pensión voluntaria", "Automatizar el ahorro"],
                recursos: [R.banrep, R.investopedia],
            },
        },
    },
    {
        nombre: "Manejo de deudas y crédito",
        palabrasClave: ["deuda", "deudas", "credito", "tarjeta", "tarjeta de credito", "prestamo", "datacredito", "reporte", "gota a gota"],
        niveles: {
            [NIVELES.BASICO]: {
                perfil: "Tienes (o vas a sacar) tu primera tarjeta",
                descripcion: "Cómo funciona un crédito y cuánto cuesta realmente.",
                aprenderas: ["Cuota de manejo, intereses y cuotas", "Por qué evitar el 'gota a gota'", "Qué es el historial crediticio"],
                recursos: [R.saberMas, R.superfinanciera],
            },
            [NIVELES.INTERMEDIO]: {
                perfil: "Varias deudas al mismo tiempo",
                descripcion: "Organiza y paga tus deudas con un método.",
                aprenderas: ["Método avalancha vs. bola de nieve", "Nivel sano de endeudamiento (< 30 % del ingreso)", "Negociar y refinanciar con el banco"],
                recursos: [R.khanFinanzas, R.superfinanciera],
            },
            [NIVELES.AVANZADO]: {
                perfil: "Pensando en crédito de vivienda o vehículo",
                descripcion: "Usa el crédito a tu favor.",
                aprenderas: ["Crédito hipotecario y leasing", "Compra de cartera", "Abonos a capital: cuota vs. plazo"],
                recursos: [R.superfinanciera, R.investopedia],
            },
        },
    },
    {
        nombre: "Tasas de interés y tasa de cambio",
        palabrasClave: ["interes", "tasa", "efectiva anual", "usura", "trm", "dolar", "tasa de cambio", "divisas", "inflacion"],
        niveles: {
            [NIVELES.BASICO]: {
                perfil: "Te confunden el E.A. y el M.V.",
                descripcion: "Lee una tasa de interés sin que te engañen.",
                aprenderas: ["Interés simple vs. compuesto", "Tasa efectiva anual (E.A.) y mes vencido (M.V.)", "Qué es la tasa de usura"],
                recursos: [R.khanFinanzas, R.superfinanciera],
            },
            [NIVELES.INTERMEDIO]: {
                perfil: "Comparas créditos o inversiones",
                descripcion: "Compara productos financieros con números.",
                aprenderas: ["Convertir tasas nominales a efectivas", "Costo total de un crédito", "Cómo la tasa del Banco de la República afecta tu bolsillo"],
                recursos: [R.banrep, R.superfinanciera],
            },
            [NIVELES.AVANZADO]: {
                perfil: "Compras, viajas o cobras en dólares",
                descripcion: "Tasa de cambio y cómo te afecta.",
                aprenderas: ["Qué es la TRM y dónde consultarla", "Riesgo cambiario en compras y deudas en dólares", "Inflación vs. devaluación"],
                recursos: [R.banrepTRM, R.investopedia],
            },
        },
    },
    {
        nombre: "Inversión",
        palabrasClave: ["invertir", "inversiones", "acciones", "bolsa", "fondos de inversion", "riesgo", "rentabilidad"],
        niveles: {
            [NIVELES.BASICO]: {
                perfil: "Nunca has invertido",
                descripcion: "Riesgo, rentabilidad y plazo: las tres preguntas clave.",
                aprenderas: ["Ahorrar no es lo mismo que invertir", "Perfil de riesgo", "Identificar promesas de rentabilidad sospechosas (pirámides)"],
                recursos: [R.amv, R.saberMas],
            },
            [NIVELES.INTERMEDIO]: {
                perfil: "Tienes fondo de emergencia y quieres hacer crecer tu dinero",
                descripcion: "Primeros productos de inversión en Colombia.",
                aprenderas: ["CDT vs. fondos de inversión colectiva (FIC)", "Cómo verificar que una entidad está vigilada", "Interés compuesto a largo plazo"],
                recursos: [R.superfinanciera, R.amv],
            },
            [NIVELES.AVANZADO]: {
                perfil: "Inversionista con metas de largo plazo",
                descripcion: "Mercado de valores y diversificación.",
                aprenderas: ["Acciones, bonos y ETF", "Diversificar un portafolio", "Impuestos sobre rendimientos"],
                recursos: [R.bvc, R.investopedia],
            },
        },
    },
];

/**
 * Construye el árbol a partir de TEMAS.
 * Raíz → Tema (General) → Básico → Intermedio → Avanzado
 */
function construirArbol(temas) {
    const raiz = new Nodos("Finanzas personales", NIVELES.RAIZ);

    for (const tema of temas) {
        const nodoTema = raiz.agregarHijos(
            new Nodos(tema.nombre, NIVELES.GENERAL, { palabrasClave: tema.palabrasClave })
        );

        // Cada nivel cuelga del anterior: la cadena expresa los prerrequisitos.
        let padre = nodoTema;
        for (const nivel of [NIVELES.BASICO, NIVELES.INTERMEDIO, NIVELES.AVANZADO]) {
            padre = padre.agregarHijos(new Nodos(tema.nombre, nivel, tema.niveles[nivel]));
        }
    }
    return raiz;
}

const raiz = construirArbol(TEMAS);

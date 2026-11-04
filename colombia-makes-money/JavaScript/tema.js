/**
 * tema.js — Paleta de Colombia Makes Money (amarillo + crema).
 *
 * Se carga JUSTO DESPUÉS del script de Tailwind (CDN). Tailwind Play CDN lee
 * el objeto global `tailwind.config` y genera clases a partir de él, así que
 * definimos aquí nuestros colores UNA sola vez y todas las páginas los usan
 * como `bg-crema-100`, `text-amarillo-600`, `border-cafe-900/20`, etc.
 */
tailwind.config = {
    theme: {
        extend: {
            colors: {
                // Fondos y superficies
                crema: {
                    50: "#FFFDF7",
                    100: "#FFF8E7",
                    200: "#F8EDD3",
                    300: "#EFDDB4",
                },
                // Color de marca: acentos, botones y la "moneda"
                amarillo: {
                    200: "#FFEB9C",
                    300: "#FFD84D",
                    400: "#F9C80E",
                    500: "#F4B400",
                    600: "#D99A00",
                    700: "#A87400",
                },
                // Texto: café oscuro en vez de negro puro (contrasta bien sobre crema y amarillo)
                cafe: {
                    500: "#7A6A48",
                    700: "#54452A",
                    900: "#3B2F14",
                },
            },
            fontFamily: {
                sans: ["Poppins", "system-ui", "sans-serif"],
            },
        },
    },
};

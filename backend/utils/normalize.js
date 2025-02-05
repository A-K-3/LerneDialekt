// Función para normalizar texto (sin símbolos, tildes ni mayúsculas)
const normalizeText = (text) => {
    return text
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "") // Elimina tildes
        .replace(/[^\w\s]/gi, "") // Elimina símbolos
        .trim();
};

// Función para limpiar solo tildes y mayúsculas (pero deja símbolos)
const normalizeWithoutSymbols = (text) => {
    return text
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "") // Elimina tildes
        .trim();
};

module.exports = {normalizeText, normalizeWithoutSymbols};

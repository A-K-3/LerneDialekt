const express = require("express");
const fs = require("fs");
const cors = require("cors");
const bodyParser = require("body-parser");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;
const FILE_PATH = path.join(__dirname, "questions.json");

app.use(cors());
app.use(express.json());

// 🔹 Verificar si `questions.json` existe
if (!fs.existsSync(FILE_PATH)) {
    fs.writeFileSync(FILE_PATH, JSON.stringify([]), "utf8");
    console.log("✅ Archivo questions.json creado.");
}

// 🔹 Función para normalizar texto (sin símbolos, tildes ni mayúsculas)
const normalizeText = (text) => {
    return text
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "") // Elimina tildes
        .replace(/[^\w\s]/gi, "") // Elimina símbolos
        .trim();
};

// 🔹 Obtener preguntas
app.get("/questions", (req, res) => {
    fs.readFile(FILE_PATH, "utf8", (err, data) => {
        if (err) return res.status(500).json({error: "Error al leer el archivo"});
        res.json(JSON.parse(data));
    });
});

// 🔹 Agregar una pregunta con múltiples respuestas
app.post("/questions", (req, res) => {
    const {question, answers} = req.body;

    if (!question || !Array.isArray(answers) || answers.length === 0) {
        return res.status(400).json({error: "Formato incorrecto, se requiere pregunta y respuestas en array."});
    }

    fs.readFile(FILE_PATH, "utf8", (err, data) => {
        if (err) return res.status(500).json({error: "Error al leer el archivo"});

        let questions = JSON.parse(data);
        questions.push({question, answers});

        fs.writeFile(FILE_PATH, JSON.stringify(questions, null, 2), (err) => {
            if (err) return res.status(500).json({error: "Error al guardar la pregunta"});
            res.json({message: "Pregunta agregada correctamente", question});
        });
    });
});

// 🔹 Comprobar respuesta del usuario
app.post("/check-answer", (req, res) => {
    const {question, userAnswer} = req.body;

    if (!question || !userAnswer) {
        return res.status(400).json({error: "Se requiere pregunta y respuesta del usuario."});
    }

    fs.readFile(FILE_PATH, "utf8", (err, data) => {
        if (err) return res.status(500).json({error: "Error al leer el archivo"});

        let questions = JSON.parse(data);
        const questionData = questions.find((q) => q.question === question);

        if (!questionData) {
            return res.status(404).json({error: "Pregunta no encontrada."});
        }

        const normalizedUserAnswer = normalizeText(userAnswer);

        const isCorrect = questionData.answers.some((ans) => normalizeText(ans) === normalizedUserAnswer);
        const isPartial = questionData.answers.some((ans) => normalizedUserAnswer.includes(normalizeText(ans)));

        if (isCorrect) {
            return res.json({result: "¡Correcto!"});
        } else if (isPartial) {
            return res.json({result: "Parcialmente correcta: revisa los símbolos."});
        } else {
            return res.json({result: "Incorrecto. Inténtalo de nuevo."});
        }
    });
});

// 🔹 Servir `index.html` si Flutter Web no encuentra una ruta API
app.get("*", (req, res) => {
    res.sendFile(path.join(__dirname, "../build/web/index.html"));
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});

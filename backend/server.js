const express = require("express");
const fs = require("fs");
const cors = require("cors");
const bodyParser = require("body-parser");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;
const FILE_PATH = path.join(__dirname, "questions.json");

app.use(cors());
app.use(bodyParser.json());

// 🔹 Verificar si `questions.json` existe, si no, crearlo con un array vacío
if (!fs.existsSync(FILE_PATH)) {
    fs.writeFileSync(FILE_PATH, JSON.stringify([]), "utf8");
    console.log("✅ Archivo questions.json creado.");
}

// 🔹 Servir Flutter Web desde la carpeta `/build/web/`
app.use(express.static(path.join(__dirname, "../build/web")));

// Obtener preguntas
app.get("/questions", (req, res) => {
    fs.readFile(FILE_PATH, "utf8", (err, data) => {
        if (err) return res.status(500).json({ error: "Error al leer el archivo" });
        res.json(JSON.parse(data));
    });
});

// Agregar pregunta
app.post("/questions", (req, res) => {
    const newQuestion = req.body;

    fs.readFile(FILE_PATH, "utf8", (err, data) => {
        if (err) return res.status(500).json({ error: "Error al leer el archivo" });

        let questions = JSON.parse(data);
        questions.push(newQuestion);

        fs.writeFile(FILE_PATH, JSON.stringify(questions, null, 2), (err) => {
            if (err) return res.status(500).json({ error: "Error al guardar la pregunta" });
            res.json({ message: "Pregunta agregada correctamente", question: newQuestion });
        });
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

const fs = require("fs");
const path = require("path");
const { normalizeText, normalizeWithoutSymbols } = require("../utils/normalize");

const FILE_PATH = path.join(__dirname, "../questions.json");

const getQuestions = (req, res) => {
    const { category } = req.query; // Obtener la categoría de los query parameters

    fs.readFile(FILE_PATH, "utf8", (err, data) => {
        if (err) return res.status(500).json({ error: "Error al leer el archivo" });

        let questions = JSON.parse(data);

        // Filtrar por categoría si se proporciona
        if (category) {
            questions = questions.filter(q => q.category === category);
        }

        res.json(questions);
    });
};

const addQuestion = (req, res) => {
    const { question, answers, category } = req.body;

    if (!question || !Array.isArray(answers) || answers.length === 0 || !category) {
        return res.status(400).json({ error: "Formato incorrecto, se requiere pregunta, respuestas en array y categoría." });
    }

    fs.readFile(FILE_PATH, "utf8", (err, data) => {
        if (err) return res.status(500).json({ error: "Error al leer el archivo" });

        let questions = JSON.parse(data);
        questions.push({ question, answers, category });

        fs.writeFile(FILE_PATH, JSON.stringify(questions, null, 2), (err) => {
            if (err) return res.status(500).json({ error: "Error al guardar la pregunta" });
            res.json({ message: "Pregunta agregada correctamente", question });
        });
    });
};

const checkAnswer = (req, res) => {
    const { question, userAnswer, category } = req.body;

    if (!question || !userAnswer || !category) {
        return res.status(400).json({ error: "Se requiere pregunta, respuesta del usuario y categoría." });
    }

    fs.readFile(FILE_PATH, "utf8", (err, data) => {
        if (err) return res.status(500).json({ error: "Error al leer el archivo" });

        let questions = JSON.parse(data);
        const questionData = questions.find((q) => q.question === question && q.category === category);

        if (!questionData) {
            return res.status(404).json({ error: "Pregunta no encontrada en la categoría especificada." });
        }

        const normalizedUserAnswer = normalizeText(userAnswer);
        const normalizedUserAnswerWithoutSymbols = normalizeWithoutSymbols(userAnswer);

        const isCorrect = questionData.answers.some((ans) => normalizeText(ans) === normalizedUserAnswer);
        const isPartial = questionData.answers.some((ans) => normalizeText(ans) === normalizedUserAnswerWithoutSymbols);

        if (isCorrect) {
            return res.json({ result: "¡Correcto!" });
        } else if (isPartial) {
            return res.json({ result: "Parcialmente correcta: revisa los símbolos." });
        } else {
            return res.json({ result: "Incorrecto. Inténtalo de nuevo." });
        }
    });
};

module.exports = { getQuestions, addQuestion, checkAnswer };
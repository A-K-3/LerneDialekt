const express = require("express");
const { getQuestions, addQuestion, checkAnswer } = require("../controllers/questionsController");

const router = express.Router();

router.get("/", getQuestions);
router.post("/", addQuestion);
router.post("/check-answer", checkAnswer);

module.exports = router;

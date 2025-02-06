const express = require("express");
const cors = require("cors");
const path = require("path");
const questionsRoutes = require("./routes/questions");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use("/questions", questionsRoutes);


app.listen(PORT, () => {
    console.log(`🚀 Server running at ${PORT}`);
});
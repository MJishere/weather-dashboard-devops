import express from "express";
import fetch from "node-fetch";
import cors from "cors";

const app = express();
const PORT = 5000;
const API_KEY = "5030d5694f2052684814e835d85ff0ef"; // Get it from https://openweathermap.org/api

app.use(cors());

app.get("/weather", async (req, res) => {
  const city = req.query.city || "Delhi";
  const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${API_KEY}`;
  try {
    const response = await fetch(url);
    const data = await response.json();
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch weather data" });
  }
});

app.listen(PORT, () => console.log(`Backend running at http://localhost:${PORT}`));

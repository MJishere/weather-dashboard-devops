import express from "express";
import fetch from "node-fetch";
import cors from "cors";

const app = express();
const PORT = process.env.PORT || 5000;
const API_KEY = process.env.OPENWEATHER_API_KEY; // Get it from https://openweathermap.org/api

app.use(cors());

// Weather API route

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

// City Search Suggestions route
app.get("/search", async (req, res) => {
  const query = req.query.query;
  if (!query) return res.json([]);

  const url = `https://api.openweathermap.org/geo/1.0/direct?q=${query}&limit=5&appid=${API_KEY}`;
  try {
    const response = await fetch(url);
    const data = await response.json();
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch city suggestions" });
  }
});

app.listen(PORT, () => console.log(`Backend running at http://0.0.0.0:${PORT}`));

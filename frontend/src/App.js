import { useState } from "react";
import "./App.css";

function App() {
  const [city, setCity] = useState("");
  const [weather, setWeather] = useState(null);
  const [suggestions, setSuggestions] = useState([]);

  // 🧠 Fetch city suggestions as user types
  const fetchSuggestions = async (query) => {
    setCity(query);
    if (query.length < 2) {
      setSuggestions([]);
      return;
    }
    const res = await fetch(`http://localhost:5000/search?query=${query}`);
    const data = await res.json();
    setSuggestions(data);
  };

  // 🌦️ Fetch weather for selected city
  const getWeather = async (selectedCity) => {
    const cityName = selectedCity || city;
    const res = await fetch(`http://localhost:5000/weather?city=${cityName}`);
    const data = await res.json();
    setWeather(data);
    setSuggestions([]); // hide suggestions
  };

  return (
    <div className="container">
      <h1>🌤️ Live Weather Dashboard</h1>

      <div className="search">
        <input
          type="text"
          placeholder="Enter city..."
          value={city}
          onChange={(e) => fetchSuggestions(e.target.value)}
        />
        <button onClick={() => getWeather()}>
          ☀️ Get Weather
        </button>

        

        {/* 🔽 Suggestions dropdown */}
        {suggestions.length > 0 && (
          <ul className="suggestions">
            {suggestions.map((s, i) => (
              <li
                key={i}
                onClick={() => {
                  setCity(s.name);
                  getWeather(s.name);
                }}
              >
                {s.name} ({s.country})
              </li>
            ))}
          </ul>
        )}
      </div>

      {weather && weather.main && (
        <div className="card">
          <h3>
            {weather.name}, {weather.sys?.country}
          </h3>
          <p>🌡️ Temp: {(weather.main.temp - 273.15).toFixed(1)}°C</p>
          <p>🤔 Feels Like: {(weather.main.feels_like - 273.15).toFixed(1)}°C</p>
          <p>💧 Humidity: {weather.main.humidity}%</p>
          <p>💨 Wind: {weather.wind.speed} m/s</p>
          <p>☁️ {weather.weather[0].description}</p>
        </div>      
      )}
    </div>
  );
}

export default App;

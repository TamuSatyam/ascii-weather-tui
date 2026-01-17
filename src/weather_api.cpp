#include "../include/weather_api.hpp"
#include <exception>
#include <httplib.h>
#include <iostream>
#include <optional>
#include <simdjson.h>

namespace WeatherAPI {
std::optional<WeatherData> fetchWeather(const std::string &city,
                                        const std::string &apiKey,
                                        const std::string &units) {
  if (city.empty()) {
    std::cerr << "Error: City name cannot be empty." << std::endl;

    return std::nullopt;
  }

  if (apiKey.empty()) {
    std::cerr << "Error: API key is required." << std::endl;

    return std::nullopt;
  }

  std::string host = "api.openweathermap.org";
  std::string path = "/data/2.5/weather";
  std::string query = "?q=" + city + "&appid=" + apiKey + "&units=" + units;

  try {
    httplib::Client client("https://" + host);
    client.set_connection_timeout(5, 0);

    auto response = client.Get((path + query).c_str());

    if (!response) {
      std::cerr
          << "Error: Network request failed. Check your internet connection."
          << std::endl;

      return std::nullopt;
    }

    switch (response->status) {
    case 200:
      break;
    case 401:
      std::cerr << "Error: Invalid API key. Check your config file."
                << std::endl;

      return std::nullopt;
    case 404:
      std::cerr << "Error: City '" << city << "' not found." << std::endl;

      return std::nullopt;
    case 429:
      std::cerr << "Error: API rate limited exceeded. Try again later."
                << std::endl;

      return std::nullopt;
    default:
      std::cerr << "Error: API returned status " << response->status
                << std::endl;

      return std::nullopt;
    }
    simdjson::dom::parser parser;
    auto doc = parser.parse(response->body);

    WeatherData data;
    data.city = std::string(doc["name"].get_string().value());
    data.country = std::string(doc["sys"]["country"].get_string().value());
    data.condition =
        std::string(doc["weather"].at(0)["main"].get_string().value());
    data.description =
        std::string(doc["weather"].at(0)["description"].get_string().value());
    data.temperature = doc["main"]["feels_like"].get_double().value();
    data.feelsLike = doc["main"]["temp"].get_double().value();
    data.tempMin = doc["main"]["temp_min"].get_double().value();
    data.tempMax = doc["main"]["temp_max"].get_double().value();
    data.windSpeed = doc["wind"]["speed"].get_double().value();
    data.humidity =
        static_cast<int>(doc["main"]["humidity"].get_int64().value());

    return data;
  } catch (const simdjson::simdjson_error &e) {
    std::cerr << "Error parsing API response: " << e.what() << std::endl;

    return std::nullopt;
  } catch (const std::exception &e) {
    std::cerr << "Unexpected error: " << e.what() << std::endl;

    return std::nullopt;
  }
}
} // namespace WeatherAPI

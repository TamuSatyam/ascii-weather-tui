#pragma once

#include <optional>
#include <string>

namespace WeatherAPI {
struct WeatherData {
  std::string city;
  std::string country;
  std::string condition;
  std::string description;

  double temperature;
  double feelsLike;
  double tempMin;
  double tempMax;
  double windSpeed;
  int humidity;
};

std::optional<WeatherData> fetchWeather(const std::string &city,
                                        const std::string &apiKey,
                                        const std::string &units = "metric");
} // namespace WeatherAPI

#include "../include/display.hpp"
#include "../include/ascii_art.hpp"
#include <iomanip>
#include <ios>
#include <iostream>

namespace Display {
namespace Colors {
const std::string RESET = "\033[0m";
const std::string BOLD = "\033[1m";
const std::string RED = "\033[31m";
const std::string GREEN = "\033[32m";
const std::string YELLOW = "\033[33m";
const std::string BLUE = "\033[34m";
const std::string CYAN = "\033[36m";
const std::string WHITE = "\033[37m";
const std::string GRAY = "\033[90m";
const std::string BRIGHT_YELLOW = "\033[93m";
const std::string BRIGHT_BLUE = "\033[94m";
const std::string BRIGHT_CYAN = "\033[96m";
} // namespace Colors

std::string getTempColor(double temp, const std::string &units) {
  double hot = (units == "imperial") ? 80.0 : 25.0;
  double cold = (units == "imperial") ? 50.0 : 10.0;

  if (temp >= hot)
    return Colors::RED;
  if (temp <= cold)
    return Colors::BLUE;

  return Colors::GREEN;
}

std::string getUnitSymbol(const std::string &units) {
  return (units == "imperial") ? "℉" : "℃";
}

void displayWeather(const WeatherAPI::WeatherData &data,
                    const std::string &units, DisplayMode mode, bool useColor) {
  std::string unitSymbol = getUnitSymbol(units);

  std::string icon = useColor ? AsciiArt::getColoredIcon(data.condition)
                              : AsciiArt::getColoredIcon(data.condition);

  std::string tempColor = useColor ? getTempColor(data.temperature, units) : "";
  std::string reset = useColor ? Colors::RESET : "";
  std::string bold = useColor ? Colors::BOLD : "";

  switch (mode) {
  case DisplayMode::MINIMAL: {
    std::cout << bold << data.city << reset << std::endl;
    std::cout << icon << std::endl;
    std::cout << tempColor << std::fixed << std::setprecision(1)
              << data.temperature << unitSymbol << reset << std::endl;
    break;
  }

  case DisplayMode::NORMAL: {
    std::cout << std::string(50, '-') << std::endl;
    std::cout << bold << data.city << ", " << data.country << reset
              << std::endl;
    std::cout << std::string(50, '-') << std::endl;
    std::cout << std::endl;

    std::cout << icon << std::endl;

    std::cout << bold << "Condition: " << reset << data.description
              << std::endl;
    std::cout << bold << "Temperature: " << reset << tempColor << std::fixed
              << std::setprecision(1) << data.temperature << unitSymbol << reset
              << std::endl;
    std::cout << bold << "Feels like: " << reset << std::fixed
              << std::setprecision(1) << data.feelsLike << unitSymbol
              << std::endl;
    std::cout << bold << "Humidity: " << reset << data.humidity << "%"
              << std::endl;
    std::cout << std::endl;
    std::cout << std::string(50, '-') << std::endl;
    break;
  }

  case DisplayMode::VERBOSE: {
    std::cout << bold << "Weather Report: " << data.city << ", " << data.country
              << reset << std::endl;
    std::cout << std::string(50, '-') << std::endl;
    std::cout << icon << std::endl;
    std::cout << bold << "Condition:" << reset << " " << data.description
              << std::endl;
    std::cout << std::endl;

    std::cout << bold << "Temperature:" << reset << std::endl;
    std::cout << "  Current: " << tempColor << std::fixed
              << std::setprecision(1) << data.temperature << unitSymbol << reset
              << std::endl;
    std::cout << "  Feels like: " << std::fixed << std::setprecision(1)
              << data.feelsLike << unitSymbol << std::endl;
    std::cout << "  Min: " << std::fixed << std::setprecision(1) << data.tempMin
              << unitSymbol << std::endl;
    std::cout << "  Max: " << std::fixed << std::setprecision(1) << data.tempMax
              << unitSymbol << std::endl;
    std::cout << std::endl;

    std::cout << bold << "Other:" << reset << std::endl;
    std::cout << "  Humidity: " << data.humidity << "%" << std::endl;
    std::cout << "  Wind Speed: " << std::fixed << std::setprecision(1)
              << data.windSpeed;
    if (units == "imperial") {
      std::cout << "mph";
    } else {
      std::cout << "m/s";
    }
    std::cout << std::endl;
    std::cout << std::string(50, '-') << std::endl;
    break;
  }
  }
}
} // namespace Display

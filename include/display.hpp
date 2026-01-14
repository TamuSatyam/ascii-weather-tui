#pragma once

#include "weather_api.hpp"
#include <string>

namespace Display {
namespace Colors {
extern const std::string RESET;
extern const std::string BOLD;
extern const std::string RED;
extern const std::string GREEN;
extern const std::string YELLOW;
extern const std::string CYAN;
extern const std::string BLUE;
extern const std::string WHITE;
extern const std::string GRAY;
extern const std::string BRIGHT_YELLOW;
extern const std::string BRIGHT_BLUE;
extern const std::string BRIGHT_CYAN;
} // namespace Colors

enum class DisplayMode { MINIMAL, NORMAL, VERBOSE };

void displayWeather(const WeatherAPI::WeatherData &data,
                    const std::string &units,
                    DisplayMode mode = DisplayMode::NORMAL,
                    bool useColor = true);

std::string getTempColor(double temp, const std::string &units);
std::string getUnitSymbol(const std::string &units);
} // namespace Display

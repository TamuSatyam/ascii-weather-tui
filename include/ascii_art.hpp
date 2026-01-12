#pragma once
#include <string>

namespace AsciiArt {
extern const std::string SUNNY;
extern const std::string CLOUDY;
extern const std::string RAINY;
extern const std::string SNOWY;
extern const std::string THUNDERSTORM;
extern const std::string MIST;
extern const std::string UNKNOWN;

std::string getIcon(const std::string &condition);
std::string getColoredIcon(const std::string &condition);
} // namespace AsciiArt

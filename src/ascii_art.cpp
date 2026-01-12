#include <string>
#include <unordered_map>

namespace AsciiArt {
const std::string SUNNY = R"(
    \   /
     .-.
---- (  ) ---
     `-'
    /   \
    )";

const std::string CLOUDY = R"(
    .--.
 .-(   ).
(___.__)__)
)";

const std::string RAINY = R"(
    .--.
 .-(    ).
(___.__)__)
 ' ' ' ' '
)";

const std::string SNOWY = R"(
    .--.
 .-(    ).
(___.__)__)
 * * * * *
)";

const std::string THUNDERSTORM = R"(
    .--.
 .-(    ).
(___.__)__)
 ⚡ ⚡ ⚡ ⚡ ⚡
)";

const std::string MIST = R"(
  _ - _ - _
 _ - _ - _ -
  _ - _ - _
)";

const std::string UNKNOWN = R"(
    .--.
 .-( ? ).
(___.__)__)
)";

std::string getIcon(const std::string &condition) {
  static const std::unordered_map<std::string, std::string> iconMap = {
      {"Clear", SUNNY},
      {"Cloudy", CLOUDY},
      {"Rain", RAINY},
      {"Drizzle", RAINY},
      {"Snow", SNOWY},
      {"Thunderstorm", THUNDERSTORM},
      {"Mist", MIST},
      {"Haze", MIST},
      {"Fog", MIST},
      {"Tornado", THUNDERSTORM},
      {"Squall", THUNDERSTORM},
      {"Unknown", UNKNOWN}};

  auto it = iconMap.find(condition);
  if (it != iconMap.end()) {
    return it->second;
  }
  return UNKNOWN;
}

namespace Colors {
const std::string RESET = "\033[0m";

const std::string YELLOW = "\033[93m";
const std::string CYAN = "\033[96m";
const std::string BLUE = "\033[34m";
const std::string WHITE = "\033[37m";
const std::string GRAY = "\033[90m";
} // namespace Colors

std::string getColoredIcon(const std::string &condition) {
  std::string icon = getIcon(condition);

  if (condition == "Clear") {
    return Colors::YELLOW + icon + Colors::RESET;
  } else if (condition == "Cloudy") {
    return Colors::GRAY + icon + Colors::RESET;
  } else if (condition == "Rain") {
    return Colors::BLUE + icon + Colors::RESET;
  } else if (condition == "Snow") {
    return Colors::CYAN + icon + Colors::RESET;
  } else if (condition == "Thunderstorm") {
    return Colors::YELLOW + icon + Colors::RESET;
  } else {
    return Colors::WHITE + icon + Colors::RESET;
  }
}
} // namespace AsciiArt

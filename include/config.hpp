#pragma once

#include <optional>
#include <string>

namespace Config {
struct AppConfig {
  std::string apiKey;
  std::string defaultCity;
  std::string defaultUnits;
};
std::optional<AppConfig>
loadConfig(const std::string &configPath = "config.json");

bool createDefaultConfig(const std::string &configPath = "config.json");
} // namespace Config

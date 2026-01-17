#include "../include/config.hpp"
#include "../external/simdjson.h"
#include <fstream>
#include <iostream>

namespace Config {
std::optional<AppConfig> loadConfig(const std::string &configPath) {
  std::ifstream file(configPath);
  if (!file.is_open()) {
    std::cerr << "Warning: Config file '" << configPath << "' not found"
              << std::endl;
    std::cerr << "Please create a config.json file with your API key."
              << std::endl;
    std::cerr << "Example format:" << std::endl;
    std::cerr << R"(
    {
      "api_key": "your_openweather_api_key",
      "default_city": "Kathmandu",
      "default_units": "metric"
    })" << std::endl;

    return std::nullopt;
  }
  std::string content((std::istreambuf_iterator<char>(file)),
                      std::istreambuf_iterator<char>());
  file.close();

  simdjson::dom::parser parser;
  simdjson::dom::element doc;

  try {
    doc = parser.parse(content);
  } catch (const simdjson::simdjson_error &e) {
    std::cerr << "Error: Failed to parse config file: " << e.what()
              << std::endl;

    return std::nullopt;
  }
  AppConfig config;

  try {
    config.apiKey = std::string(doc["api_key"].get_string().value());

    if (doc["default_city"].error() == simdjson::SUCCESS) {
      config.defaultCity =
          std::string(doc["default_city"].get_string().value());
    } else {
      config.defaultCity = "Kathmandu";
    }

    if (doc["default_units"].error() == simdjson::SUCCESS) {
      config.defaultUnits =
          std::string(doc["default_units"].get_string().value());
    } else {
      config.defaultUnits = "metric";
    }

  } catch (const simdjson::simdjson_error &e) {
    std::cerr << "Error: Invalid config format: " << e.what() << std::endl;

    return std::nullopt;
  }
  return config;
}
bool createDefaultConfig(const std::string &configPath) {
  std::ofstream file(configPath);
  if (!file.is_open()) {
    std::cerr << "Error: Could not create config file" << std::endl;

    return false;
  }
  file << R"({
  "api_key": "your_openweather_api_key",
  "default_city": "Kathmandu",
  "default_units": "metric"
  })";
  file.close();
  std::cout << "Created default config file: " << configPath << std::endl;
  std::cout << "Please edit it and add your OpenWeatherMap API key."
            << std::endl;

  return true;
}
} // namespace Config

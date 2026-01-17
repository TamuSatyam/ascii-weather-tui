#include "../external/CLI11/CLI.hpp"
#include "../include/config.hpp"
#include "../include/display.hpp"
#include "../include/weather_api.hpp"
#include <string>

int main(int argc, char **argv) {
  for (int i = 1; i < argc; i++) {
    if (std::string(argv[i]) == "--create-config") {
      if (Config::createDefaultConfig("config.json")) {
        std::cout << "Config file created successfully at: config.json"
                  << std::endl;

        return 0;
      } else {
        return 1;
      }
    }
  }

  CLI::App app{"ASCII Weather TUI"};

  std::string city;
  std::string units = "metric";
  std::string configPath = "config.json";

  bool minimal = false;
  bool verbose = false;
  bool noColor = false;
  bool createConfig = false;

  app.add_option("city", city, "City name to get weather for");
  app.add_option("--units,-u", units,
                 "Units: metric or imperial (default: metric)");
  app.add_option("--config", configPath,
                 "Path to config file (default: config.json)");
  app.add_flag("--minimal,-m", minimal, "Minimal output mode");
  app.add_flag("--verbose,-v", verbose, "Verbose output mode");
  app.add_flag("--no-color", noColor, "Disable colored output");
  app.add_flag("--create-config", configPath, "Create a default config file");

  try {
    app.parse(argc, argv);
  } catch (const CLI::ParseError &e) {
    return app.exit(e);
  }

  if (createConfig) {
    if (Config::createDefaultConfig(configPath)) {
      std::cout << "Config file created successfully at: " << configPath
                << std::endl;

      return 0;
    } else {
      return 1;
    }
  }

  auto config = Config::loadConfig(configPath);
  if (!config) {
    std::cerr << std::endl;
    std::cerr << "Tip: Run with --create-config to generate a config file"
              << std::endl;

    return 1;
  }

  std::string targetCity = city.empty() ? config->defaultCity : city;

  if (targetCity.empty()) {
    std::cerr << "Error: No city specified and no default city in config"
              << std::endl;
    std::cerr << "Usage: " << argv[0] << "  <city>" << std::endl;

    return 1;
  }

  std::cout << "Fetching weather for " << targetCity << "..." << std::endl;
  auto weatherData =
      WeatherAPI::fetchWeather(targetCity, config->apiKey, units);

  if (!weatherData) {
    std::cerr << "Failed to fetch weather data" << std::endl;

    return 1;
  }

  std::cout << std::endl;

  Display::DisplayMode mode = Display::DisplayMode::NORMAL;
  if (minimal) {
    mode = Display::DisplayMode::MINIMAL;
  } else if (verbose) {
    mode = Display::DisplayMode::VERBOSE;
  }

  Display::displayWeather(*weatherData, units, mode, !noColor);

  return 0;
}

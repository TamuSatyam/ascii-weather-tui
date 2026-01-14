# ASCII Weather TUI

A simple terminal user interface written in C++20 that displays weather information with ASCII art.

### Prerequisites

- Clang/GCC
- vcpkg
- CMake 3.20 or higher
- Internet connection
- OpenWeatherMap API key

### Dependecies

All dependencies are managed via [vcpkg](https://vcpkg.io/):

- [simdjson](https://github.com/simdjson/simdjson)
- [CLI11](https://github.com/CLIUtils/CLI11)
- [cpp-httplib](https://github.com/yhirose/cpp-httplib)
- [OpenSSL](https://github.com/openssl/openssl)

### Installation

1. Clone the repository (no binaries)

```
git clone https://github.com/TamuSatyam/ascii-weather-tui.git awt
cd awt
```

2. Install dependencies

```
vcpkg install simdjson cli11 cpp-httplib[openssl] openssl
```

3. Get an API key

- Go to [OpenWeatherMap](https://openweathermap.org/api)
- Sign up for a free account
- Generate an API key

4. Create configuration file

```
./ascii-weather-tui --create-config
```

Then edit `config.json` and add your API key:

```
{
    "api_key": "your_openweathermap_api_key",
    "default_city": "Kathmandu",
    "default_units": "metric"
}
```

5. Build the project

```
mkdir build
cd build
cmake ..
make
```

### Usage

#### Basic usage

```
# Using default city from config
./ascii-weather-tui

# Specifying a city
./ascii-weather-tui Muscat
./ascii-weather-tui "Vienna"
```

#### Command line options

```
# Using imperial units
./ascii-weather-tui Valleta -u imperial

# Minimal output
./ascii-weather-tui Astana --minimal

# Verbose output with all details
./ascii-weather-tui Ulaanbaatar --verbose

# Disable colors
./ascii-weather-tui London --no-color

# Custom config file
./ascii-weather-tui Tripoli -c /path/to/config.json
```

### Display Modes

Minimal Mode

```
Fetching weather for Vienna...

Vienna

  _ - _ - _
 _ - _ - _ -
  _ - _ - _

-7.2℃
```

Normal Mode (default)

```
Fetching weather for Kathmandu...

--------------------------------------------------
Kathmandu, NP
--------------------------------------------------


  _ - _ - _
 _ - _ - _ -
  _ - _ - _

Condition: haze
Temperature: 8.8℃
Feels like: 10.1℃
Humidity: 62%

--------------------------------------------------
```

Verbose Mode 

```
Fetching weather for Muscat...

Weather Report: Muscat, OM
--------------------------------------------------

    \   /
     .-.
---- (  ) ---
     `-'
    /   \
    
Condition: clear sky

Temperature:
  Current: 21.1℃
  Feels like: 21.0℃
  Min: 21.0℃
  Max: 21.0℃

Other:
  Humidity: 76%
  Wind Speed: 1.5m/s
--------------------------------------------------
```


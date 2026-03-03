cmake_minimum_required(VERSION 3.14)
project(ascii-weather-tui)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_POLICY_VERSION_MINIMUM 3.5)

include(FetchContent)

FetchContent_Declare(cli11 GIT_REPOSITORY https://github.com/CLIUtils/CLI11.git GIT_TAG v2.3.2)
FetchContent_Declare(simdjson GIT_REPOSITORY https://github.com/simdjson/simdjson.git GIT_TAG v3.6.0)
FetchContent_Declare(httplib GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git GIT_TAG v0.14.3)

FetchContent_MakeAvailable(cli11 simdjson httplib)

find_package(OpenSSL REQUIRED)

add_executable(ascii-weather-tui 
    src/main.cpp 
    src/config.cpp 
    src/weather_api.cpp 
    src/ascii_art.cpp 
    src/display.cpp
)

target_link_libraries(ascii-weather-tui PRIVATE 
    CLI11::CLI11
    simdjson::simdjson
    httplib::httplib
    OpenSSL::SSL 
    OpenSSL::Crypto
)

if(WIN32)
    target_link_libraries(ascii-weather-tui PRIVATE ws2_32 crypt32)
endif()
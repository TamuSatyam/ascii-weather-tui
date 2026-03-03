cmake_minimum_required(VERSION 3.20)
project(ascii-weather-tui)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(include)
include_directories(external)
include_directories(external/CLI11/include)

find_package(OpenSSL REQUIRED)

set(SOURCES
    src/main.cpp
    src/config.cpp
    src/weather_api.cpp
    src/ascii_art.cpp
    src/display.cpp
    external/simdjson.cpp
)

add_executable(ascii-weather-tui ${SOURCES})

target_link_libraries(ascii-weather-tui PRIVATE OpenSSL::SSL OpenSSL::Crypto)

if(WIN32)
    target_link_libraries(ascii-weather-tui PRIVATE ws2_32 crypt32)
endif()
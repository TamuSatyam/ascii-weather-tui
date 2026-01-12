cmake_minimum_required(VERSION 3.20)
project(ascii-weather-tui)

if (NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{HOME}/vcpkg/scripts/buildsystems/vcpkg.cmake"
            CACHE STRING "Vcpkg toolchain file")
endif ()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -Wall -Wextra -Wpedantic -fsanitize=address,undefined")
    set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -march=native")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
endif ()

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif ()

find_package(simdjson CONFIG REQUIRED)
find_package(CLI11 CONFIG REQUIRED)
find_package(httplib CONFIG REQUIRED)

set(SOURCES
    src/main.cpp
    src/weather_api.cpp
    src/ascii_art.cpp
)

add_executable(ascii-weather-tui ${SOURCES})

target_link_directories(ascii-weather-tui PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

target_link_libraries(ascii-weather-tui PRIVATE
        simdjson::simdjson
        CLI11::CLI11
        httplib::httplib
)

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "C++ standard: ${CMAKE_CXX_STANDARD}")

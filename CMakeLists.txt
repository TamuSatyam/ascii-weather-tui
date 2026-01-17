cmake_minimum_required(VERSION 3.20)
project(ascii-weather-tui)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(WIN32)
    add_compile_definitions(_WIN32_WINNT=0x0601)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")
endif()

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

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

target_include_directories(ascii-weather-tui PRIVATE
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/external
    ${CMAKE_SOURCE_DIR}/external/CLI11
)

target_compile_definitions(ascii-weather-tui PRIVATE
    CPPHTTPLIB_OPENSSL_SUPPORT
)

target_link_libraries(ascii-weather-tui PRIVATE
    OpenSSL::SSL
    OpenSSL::Crypto
)

if(WIN32)
    target_link_libraries(ascii-weather-tui PRIVATE ws2_32 crypt32)
endif()

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ compiler: ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "OpenSSL version: ${OPENSSL_VERSION}")

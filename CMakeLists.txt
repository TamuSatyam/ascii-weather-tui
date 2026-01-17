cmake_minimum_required(VERSION 3.20)
project(ascii-weather-tui)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build static libs" FORCE)
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")

if(WIN32)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    add_compile_definitions(_WIN32_WINNT=0x0601)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -Wall -Wextra -Wpedantic")
    set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
    set(CMAKE_CXX_FLAGS_MINSIZEREL "-Os -DNDEBUG")
endif()

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

find_package(simdjson CONFIG REQUIRED)
find_package(CLI11 CONFIG REQUIRED)
find_package(httplib CONFIG REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Threads REQUIRED)

set(SOURCES
    src/main.cpp
    src/config.cpp
    src/weather_api.cpp
    src/ascii_art.cpp
    src/display.cpp
)

add_executable(ascii-weather-tui ${SOURCES})

target_include_directories(ascii-weather-tui PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

target_compile_definitions(ascii-weather-tui PRIVATE
    CPPHTTPLIB_OPENSSL_SUPPORT
)

target_link_libraries(ascii-weather-tui PRIVATE
    simdjson::simdjson
    CLI11::CLI11
    httplib::httplib
    OpenSSL::SSL
    OpenSSL::Crypto
    Threads::Threads
)

if(WIN32)
    target_link_libraries(ascii-weather-tui PRIVATE ws2_32 crypt32)
elseif(UNIX AND NOT APPLE)
    target_link_libraries(ascii-weather-tui PRIVATE ${CMAKE_DL_LIBS})
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set_property(TARGET ascii-weather-tui PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ compiler: ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "C++ standard: ${CMAKE_CXX_STANDARD}")
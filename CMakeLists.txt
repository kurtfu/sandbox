cmake_minimum_required(VERSION 3.21.0)
project(utils LANGUAGES CXX)

if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 17)
endif()

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(Coverage)
include(Docs)
include(Linter)
include(Optimization)
include(Utils)

find_package(benchmark)
find_package(Catch2)

include(CTest)
include(Catch)

setup_executable(sandbox
    SOURCES
        src/main.cpp
    INCLUDES
        include
)

setup_executable(sandbox-benchmark
    SOURCES
        benchmark/accumulator.cpp
    INCLUDES
        include
    DEPENDENCIES
        benchmark::benchmark_main
)

setup_executable(sandbox-test
    SOURCES
        tests/widget.cpp
    INCLUDES
        include
    DEPENDENCIES
        Catch2::Catch2WithMain
)

catch_discover_tests(sandbox-test)
add_coverage(sandbox-test)

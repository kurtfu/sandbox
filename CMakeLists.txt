cmake_minimum_required(VERSION 3.21.0)
project(utils LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(Docs)
include(Linter)
include(Optimization)
include(Utils)

setup_executable(
    TARGET
        sandbox
    SOURCES
        src/main.cpp
    INCLUDES
        include
)

setup_benchmark(
    TARGET
        sandbox-benchmark
    SOURCES
        benchmark/dummy.cpp
    INCLUDES
        include
)

setup_test(
    TARGET
        sandbox-test
    SOURCES
        tests/dummy.cpp
    INCLUDES
        include
)

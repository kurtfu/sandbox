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
include(CPM)
include(Docs)
include(Linter)
include(Optimization)
include(Utils)

if(DEFINED ENV{VCPKG_ROOT})
    find_package(benchmark)
    find_package(Catch2)
else()
    CPMAddPackage("gh:google/googletest#v1.14.0")
    CPMAddPackage("gh:google/benchmark#v1.8.3")
    CPMAddPackage("gh:catchorg/Catch2#v3.6.0")

    list(APPEND CMAKE_MODULE_PATH "${Catch2_SOURCE_DIR}/extras")
endif()

include(CTest)
include(Catch)

setup_executable(
    TARGET
        sandbox
    SOURCES
        src/main.cpp
    INCLUDES
        include
)

setup_executable(
    TARGET
        sandbox-benchmark
    SOURCES
        benchmark/dummy.cpp
    INCLUDES
        include
    DEPENDENCIES
        LIBRARIES
            benchmark::benchmark_main
)

setup_executable(
    TARGET
        sandbox-test
    SOURCES
        tests/dummy.cpp
    INCLUDES
        include
    DEPENDENCIES
        Catch2::Catch2WithMain
)

catch_discover_tests(sandbox-test)
add_coverage(sandbox-test)

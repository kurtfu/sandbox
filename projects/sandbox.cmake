find_package(Boost CONFIG COMPONENTS range)

setup_executable(sandbox
    SOURCES
        src/main.cpp
    INCLUDES
        src
)

setup_executable(sandbox-benchmark
    SOURCES
        benchmarks/accumulator.cpp
    INCLUDES
        src
        SYSTEM ${Boost_INCLUDE_DIRS}
    DEPENDENCIES
        benchmark::benchmark_main
)

setup_test(sandbox-test
    SOURCES
        tests/widget.cpp
    INCLUDES
        src
    DEPENDENCIES
        Catch2::Catch2WithMain
)

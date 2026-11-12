find_package(Boost CONFIG REQUIRED COMPONENTS range)

setup_executable(sandbox
    SOURCES
        src/main.cpp
    INCLUDES
        src
)

setup_benchmark(sandbox-benchmark
    SOURCES
        benchmarks/accumulator.cpp
    INCLUDES
        src
    DEPENDENCIES
        benchmark::benchmark_main
        Boost::headers
)

setup_test(sandbox-test
    SOURCES
        tests/widget.cpp
    INCLUDES
        src
    DEPENDENCIES
        Catch2::Catch2WithMain
)

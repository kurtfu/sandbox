find_package(Boost COMPONENTS range)

setup_executable(sandbox
    SOURCES
        src/main.cpp
    INCLUDES
        include
)

setup_executable(sandbox-benchmark
    SOURCES
        benchmarks/accumulator.cpp
    INCLUDES
        include
        SYSTEM ${Boost_INCLUDE_DIRS}
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

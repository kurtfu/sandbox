/*****************************************************************************/
/*** HEADER INCLUDES *********************************************************/

#include <benchmark/benchmark.h>

/// \cond
#include <random>

/// \endcond

/*****************************************************************************/
/*** MACRO DEFINITIONS *******************************************************/

#if __cplusplus < 201703L
    #define BENCHMARK_MAYBE_UNUSED
#else
    #define BENCHMARK_MAYBE_UNUSED [[maybe_unused]]
#endif  // __cplusplus

/*****************************************************************************/
/*** FREE FUNCTIONS **********************************************************/

auto random_number_generator()
{
    constexpr std::mt19937::result_type seed = 1;

    constexpr int lower_bound = 0;
    constexpr int upper_bound = 1'000;

    return [rng = std::mt19937(seed)]() mutable {
        std::uniform_int_distribution<int> dist(lower_bound, upper_bound);
        return dist(rng);
    };
}

/*****************************************************************************/
/*** BENCHMARKS **************************************************************/

static void accumulator(benchmark::State& state)
{
    constexpr std::size_t num_of_items = 1'000;

    auto generator = random_number_generator();

    std::vector<int> numbers(num_of_items);
    std::generate(numbers.begin(), numbers.end(), generator);

    for (BENCHMARK_MAYBE_UNUSED const auto& _ : state)
    {
        auto result = std::accumulate(numbers.begin(), numbers.end(), 0);
        benchmark::DoNotOptimize(result);
    }
}

BENCHMARK(accumulator);

/*****************************************************************************/
/*** HEADER INCLUDES *********************************************************/

#include <benchmark/benchmark.h>

#include <boost/range/numeric.hpp>

/// \cond
#include <algorithm>
#include <random>

/// \endcond

/*****************************************************************************/
/*** FREE FUNCTIONS **********************************************************/

static auto random_number_generator()
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
    std::ranges::generate(numbers, generator);

    for ([[maybe_unused]] const auto& _ : state)
    {
        auto result = boost::accumulate(numbers, 0);
        benchmark::DoNotOptimize(result);
    }
}

BENCHMARK(accumulator);

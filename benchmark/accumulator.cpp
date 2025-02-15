/*****************************************************************************/
/*** HEADER INCLUDES *********************************************************/

#include <benchmark/benchmark.h>

#include <boost/range/algorithm.hpp>
#include <boost/range/numeric.hpp>

/// \cond
#include <random>

/// \endcond

/*****************************************************************************/
/*** FREE FUNCTIONS **********************************************************/

static auto random_number_generator()
{
    constexpr std::mt19937::result_type seed = 1;

    return [rng = std::mt19937(seed)]() mutable {
        std::uniform_int_distribution<int> dist(0, 1'000);
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
    boost::range::generate(numbers, generator);

    for ([[maybe_unused]] const auto& _ : state)
    {
        auto result = boost::accumulate(numbers, 0);
        benchmark::DoNotOptimize(result);
    }
}

BENCHMARK(accumulator);

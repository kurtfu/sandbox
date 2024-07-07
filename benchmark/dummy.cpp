/*****************************************************************************/
/*** HEADER INCLUDES *********************************************************/

#include <benchmark/benchmark.h>

/// \cond
#include <memory>  // IWYU pragma: keep
#include <string>  // IWYU pragma: keep

/// \endcond

/*****************************************************************************/
/*** MACRO DEFINITIONS *******************************************************/

#if __cplusplus < 201703L
    #define BENCHMARK_MAYBE_UNUSED
#else
    #define BENCHMARK_MAYBE_UNUSED [[maybe_unused]]
#endif  // __cplusplus

/*****************************************************************************/
/*** BENCHMARKS **************************************************************/

static void bm_dummy(benchmark::State& state)
{
    for (BENCHMARK_MAYBE_UNUSED const auto& _ : state)
    {}
}

BENCHMARK(bm_dummy);

/*****************************************************************************/
/*** HEADER INCLUDES *********************************************************/

#include <benchmark/benchmark.h>

#include <memory>  // IWYU pragma: keep
#include <string>  // IWYU pragma: keep

/*****************************************************************************/
/*** BENCHMARKS **************************************************************/

static void bm_dummy(benchmark::State& state)
{
    for (auto _ : state)
    {}
}

BENCHMARK(bm_dummy);

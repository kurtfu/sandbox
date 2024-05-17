find_package(benchmark)

function(setup_target_for_benchmark target)
    if(NOT benchmark_FOUND)
        return()
    endif()

    target_link_libraries(${target}
        PRIVATE
            benchmark::benchmark_main
    )
endfunction()

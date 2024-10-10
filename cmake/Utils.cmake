include(Linker)
include(Sanitizer)
include(Warnings)

function(setup_executable target)
    set(multiValueArgs SOURCES INCLUDES DEPENDENCIES)

    cmake_parse_arguments(TARGET "" "" "${multiValueArgs}" ${ARGN})

    _setup_executable_sources(${target})
    _setup_executable_includes(${target})
    _setup_target_dependencies(${target})

    setup_target_link_strategy(${target})

    setup_target_warnings(${target})
    setup_target_for_sanitizer(${target})
endfunction()

function(setup_library target)
    set(multiValueArgs TYPE SOURCES INCLUDES DEPENDENCIES)

    cmake_parse_arguments(TARGET "" "" "${multiValueArgs}" ${ARGN})

    _setup_library_sources(${target})
    _setup_library_includes(${target})
    _setup_target_dependencies(${target})

    setup_target_link_strategy(${target})

    setup_target_warnings(${target})
    setup_target_for_sanitizer(${target})
endfunction()

macro(_setup_executable_sources target)
    add_executable(${target}
        ${TARGET_SOURCES}
    )
endmacro()

macro(_setup_executable_includes target)
    set(multiValueArgs SYSTEM)

    cmake_parse_arguments(INCLUDES "" "" "${multiValueArgs}" ${TARGET_INCLUDES})

    target_include_directories(${target}
        PRIVATE
            ${INCLUDES_UNPARSED_ARGUMENTS}
    )

    target_include_directories(${target} SYSTEM
        PRIVATE
            ${INCLUDES_SYSTEM}
    )
endmacro()

macro(_setup_library_sources target type)
    add_library(${target} ${type}
        ${TARGET_SOURCES}
    )
endmacro()

macro(_setup_library_includes target)
    set(multiValueArgs SYSTEM)

    cmake_parse_arguments(INCLUDES "" "" "${multiValueArgs}" ${TARGET_INCLUDES})

    target_include_directories(${target}
        PUBLIC
            ${INCLUDES_UNPARSED_ARGUMENTS}
    )

    target_include_directories(${target} SYSTEM
        PRIVATE
            ${INCLUDES_SYSTEM}
    )
endmacro()

macro(_setup_target_dependencies target)
    target_link_libraries(${target}
        PRIVATE
            ${TARGET_DEPENDENCIES}
    )
endmacro()

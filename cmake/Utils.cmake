include(Linker)
include(Sanitizer)
include(Warnings)

function(setup_executable)
    set(oneValueArgs TARGET)
    set(multiValueArgs SOURCES INCLUDES DEPENDENCIES)

    cmake_parse_arguments(EXECUTABLE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _setup_executable_sources(${EXECUTABLE_TARGET} ${EXECUTABLE_SOURCES})
    _setup_target_includes(${EXECUTABLE_TARGET} ${EXECUTABLE_INCLUDES})
    _setup_target_dependencies(${EXECUTABLE_TARGET} ${EXECUTABLE_DEPENDENCIES})

    setup_target_link_strategy(${EXECUTABLE_TARGET})

    setup_target_warnings(${EXECUTABLE_TARGET})
    setup_target_for_sanitizer(${EXECUTABLE_TARGET})
endfunction()

function(setup_library)
    set(oneValueArgs TARGET)
    set(multiValueArgs TYPE SOURCES INCLUDES DEPENDENCIES)

    cmake_parse_arguments(LIBRARY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _setup_library_sources(${LIBRARY_TARGET} ${LIBRARY_TYPE} ${LIBRARY_SOURCES})
    _setup_target_includes(${LIBRARY_TARGET} ${LIBRARY_INCLUDES})
    _setup_target_dependencies(${LIBRARY_TARGET} ${LIBRARY_DEPENDENCIES})

    setup_target_link_strategy(${LIBRARY_TARGET})

    setup_target_warnings(${LIBRARY_TARGET})
    setup_target_for_sanitizer(${LIBRARY_TARGET})
endfunction()

macro(_setup_executable_sources target)
    add_executable(${target}
        ${ARGN}
    )
endmacro()

macro(_setup_library_sources target type)
    add_library(${target} ${type}
        ${ARGN}
    )
endmacro()

macro(_setup_target_includes target)
    set(multiValueArgs SYSTEM)

    cmake_parse_arguments(INCLUDES "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    target_include_directories(${target}
        PRIVATE
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
            ${ARGN}
    )
endmacro()

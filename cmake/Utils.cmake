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
    set(multiValueArgs SOURCES INCLUDES DEPENDENCIES)

    cmake_parse_arguments(LIBRARY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    _setup_library_sources(${LIBRARY_TARGET} ${LIBRARY_SOURCES})
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

macro(_setup_library_sources target)
    add_library(${target}
        ${ARGN}
    )
endmacro()

macro(_setup_target_includes target)
    target_include_directories(${target}
        PRIVATE
            ${ARGN}
    )
endmacro()

macro(_setup_target_dependencies target)
    set(multiValueArgs LINK_PATHS LIBRARIES)

    cmake_parse_arguments(DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    target_link_directories(${target}
        PRIVATE
            ${DEPENDENCY_LINK_PATHS}
    )

    target_link_libraries(${target}
        PRIVATE
            ${DEPENDENCY_LIBRARIES}
    )
endmacro()

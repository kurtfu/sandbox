if(WIN32)
    if(${CMAKE_C_COMPILER} MATCHES "clang|gcc")
        set(VCPKG_TARGET_TRIPLET x86-mingw-static)
    endif()

    if(${CMAKE_CXX_COMPILER} MATCHES "clang\\+\\+|g\\+\\+")
        set(VCPKG_TARGET_TRIPLET x86-mingw-static)
    endif()
endif()

include($ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake)

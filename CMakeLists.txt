cmake_minimum_required(VERSION 3.24...3.31)
project(ungyp VERSION 1.0.0 LANGUAGES NONE)
include(cmake/ungyp.cmake)

option(UNGYP_INSTALL "Generate installation rules" ${PROJECT_IS_TOP_LEVEL})
if(UNGYP_INSTALL)
    include(CMakePackageConfigHelpers)
    set(UNGYP_INSTALL_CMAKEDIR "share/ungyp/cmake" CACHE STRING "CMake package installation directory")
    configure_package_config_file(cmake/ungypConfig.cmake.in
        "${CMAKE_CURRENT_BINARY_DIR}/ungypConfig.cmake"
        INSTALL_DESTINATION "${UNGYP_INSTALL_CMAKEDIR}")
    write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/ungypConfigVersion.cmake"
        COMPATIBILITY SameMajorVersion ARCH_INDEPENDENT)
    install(DIRECTORY cmake/ DESTINATION "${UNGYP_INSTALL_CMAKEDIR}"
        FILES_MATCHING PATTERN "*.cmake" PATTERN "*.c" PATTERN "*.h"
        PATTERN "*.def" PATTERN "LICENSE")
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/ungypConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/ungypConfigVersion.cmake"
        DESTINATION "${UNGYP_INSTALL_CMAKEDIR}")
    install(FILES LICENSE README.md DESTINATION share/ungyp)
endif()

option(UNGYP_BUILD_TESTS "Build and register integration tests" OFF)
if(UNGYP_BUILD_TESTS)
    enable_language(C)
    enable_language(CXX)
    enable_testing()
    add_subdirectory(tests)
endif()

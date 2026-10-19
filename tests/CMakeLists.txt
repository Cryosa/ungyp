include("${PROJECT_SOURCE_DIR}/cmake/ungyp.cmake")
find_program(UNGYP_TEST_NODE_EXECUTABLE NAMES node nodejs REQUIRED)
ungyp_addon(test_node_api_c SOURCES "${PROJECT_SOURCE_DIR}/examples/node-api-c/addon.c")
ungyp_addon(test_node_api_cpp SOURCES "${PROJECT_SOURCE_DIR}/examples/node-api-cpp/addon.cpp")
add_subdirectory(projects/node-api-v10)
ungyp_addon(test_node_v8 SOURCES "${PROJECT_SOURCE_DIR}/examples/node-v8/addon.cpp" V8)
add_library(test_existing_target MODULE "${PROJECT_SOURCE_DIR}/examples/node-api-c/addon.c")
set_target_properties(test_existing_target PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
ungyp_configure_target(test_existing_target NAPI_VERSION 8)
get_target_property(existing_runtime test_existing_target MSVC_RUNTIME_LIBRARY)
if(NOT existing_runtime STREQUAL "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    message(FATAL_ERROR "ungyp must preserve the caller's target runtime library")
endif()
add_subdirectory(projects/cmake-js)
foreach(target test_node_api_c test_node_api_cpp test_node_api_v10 test_node_v8 test_existing_target test_cmake_js)
    string(REGEX REPLACE "^test_" "" name "${target}")
    add_test(NAME "load.${name}" COMMAND "${UNGYP_TEST_NODE_EXECUTABLE}"
        "${CMAKE_CURRENT_SOURCE_DIR}/js/assert-addon.cjs" "$<TARGET_FILE:${target}>")
endforeach()

foreach(case roundtrip offline offline_corrupt checksum missing_checksum invalid_archive)
    add_test(NAME "download.${case}" COMMAND "${CMAKE_COMMAND}"
        "-DSOURCE_DIR=${PROJECT_SOURCE_DIR}" "-DTEST_DIR=${CMAKE_CURRENT_BINARY_DIR}/download ${case}"
        "-DTEST_ROOT=${CMAKE_CURRENT_BINARY_DIR}"
        "-DCASE=${case}" -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/download.cmake")
endforeach()
foreach(case invalid_version invalid_runtime architecture node_version electron_version universal_architecture)
    add_test(NAME "runtime.${case}" COMMAND "${CMAKE_COMMAND}"
        "-DSOURCE_DIR=${PROJECT_SOURCE_DIR}" "-DCASE=${case}"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/runtime.cmake")
endforeach()
add_test(NAME runtime.cross_architecture COMMAND "${CMAKE_COMMAND}"
    "-DSOURCE_DIR=${PROJECT_SOURCE_DIR}" -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/architecture.cmake")
add_test(NAME runtime.abi COMMAND "${CMAKE_COMMAND}" "-DSOURCE_DIR=${PROJECT_SOURCE_DIR}"
    "-DTEST_DIR=${CMAKE_CURRENT_BINARY_DIR}/abi" -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/abi.cmake")

add_test(NAME install.offline_consumer COMMAND "${CMAKE_COMMAND}"
    "-DSOURCE_DIR=${PROJECT_SOURCE_DIR}" "-DBINARY_DIR=${PROJECT_BINARY_DIR}"
    "-DTEST_DIR=${CMAKE_CURRENT_BINARY_DIR}/installed consumer"
    "-DGENERATOR=${CMAKE_GENERATOR}" "-DPLATFORM=${CMAKE_GENERATOR_PLATFORM}"
    "-DTOOLSET=${CMAKE_GENERATOR_TOOLSET}" "-DTOOLCHAIN=${CMAKE_TOOLCHAIN_FILE}"
    "-DMAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}" "-DC_COMPILER=${CMAKE_C_COMPILER}"
    "-DCXX_COMPILER=${CMAKE_CXX_COMPILER}"
    "-DNODE=${UNGYP_TEST_NODE_EXECUTABLE}" "-DCONFIG=$<CONFIG>"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/installed-consumer.cmake")

if(WIN32)
    add_test(NAME load.renamed_host COMMAND "${CMAKE_COMMAND}"
        "-DNODE=${UNGYP_TEST_NODE_EXECUTABLE}" "-DTEST_DIR=${CMAKE_CURRENT_BINARY_DIR}/renamed host"
        "-DASSERT_SCRIPT=${CMAKE_CURRENT_SOURCE_DIR}/js/assert-addon.cjs"
        "-DADDON=$<TARGET_FILE:test_node_api_c>" -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/renamed-host.cmake")
endif()

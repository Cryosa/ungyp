cmake_minimum_required(VERSION 3.24)
set(prefix "${TEST_DIR}/prefix")
execute_process(COMMAND "${CMAKE_COMMAND}" --install "${BINARY_DIR}" --prefix "${prefix}"
    --config "${CONFIG}" COMMAND_ERROR_IS_FATAL ANY)
set(generator_args -G "${GENERATOR}")
if(PLATFORM)
    list(APPEND generator_args -A "${PLATFORM}")
endif()
if(TOOLSET)
    list(APPEND generator_args -T "${TOOLSET}")
endif()
if(TOOLCHAIN)
    list(APPEND generator_args "-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN}")
endif()
if(MAKE_PROGRAM)
    list(APPEND generator_args "-DCMAKE_MAKE_PROGRAM=${MAKE_PROGRAM}")
endif()
foreach(example node-api-c node-api-cpp)
    if(example STREQUAL "node-api-c")
        set(compiler_arg "-DCMAKE_C_COMPILER=${C_COMPILER}")
        set(target node_api_c)
    else()
        set(compiler_arg "-DCMAKE_CXX_COMPILER=${CXX_COMPILER}")
        set(target node_api_cpp)
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -S "${SOURCE_DIR}/examples/${example}"
        -B "${TEST_DIR}/${example}" ${generator_args} "${compiler_arg}"
        "-DCMAKE_PREFIX_PATH=${prefix}" "-DCMAKE_BUILD_TYPE=${CONFIG}"
        -DUNGYP_USE_INSTALLED=ON -DUNGYP_OFFLINE=ON
        "-DUNGYP_CACHE_DIR=${TEST_DIR}/empty-sdk-cache"
        COMMAND_ERROR_IS_FATAL ANY)
    execute_process(COMMAND "${CMAKE_COMMAND}" --build "${TEST_DIR}/${example}" --config "${CONFIG}"
        COMMAND_ERROR_IS_FATAL ANY)
    execute_process(COMMAND "${NODE}" "${SOURCE_DIR}/tests/js/assert-addon.cjs"
        "${TEST_DIR}/${example}/${CONFIG}/${target}.node" COMMAND_ERROR_IS_FATAL ANY)
endforeach()
if(EXISTS "${TEST_DIR}/empty-sdk-cache")
    message(FATAL_ERROR "Node-API builds must not create an SDK cache")
endif()

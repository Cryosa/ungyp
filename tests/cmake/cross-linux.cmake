cmake_minimum_required(VERSION 3.25)
get_filename_component(source_dir "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
if(TARGET_ARCH STREQUAL "x86_64")
    set(MACHINE 3e00)
elseif(TARGET_ARCH STREQUAL "aarch64")
    set(MACHINE b700)
else()
    message(FATAL_ERROR "Set TARGET_ARCH to x86_64 or aarch64")
endif()
# TOOLCHAIN_OPTIONS is a CMake list of explicit -D arguments for the toolchain.
foreach(project examples/node-api-c examples/node-api-cpp tests/projects/cross-link)
    get_filename_component(name "${project}" NAME)
    string(REPLACE "-" "_" target "${name}")
    set(binary_dir "${TEST_DIR}/${TARGET_ARCH}/${name}")
    execute_process(COMMAND "${CMAKE_COMMAND}"
        -S "${source_dir}/${project}" -B "${binary_dir}" -G Ninja
        --toolchain "${TOOLCHAIN_FILE}" ${TOOLCHAIN_OPTIONS}
        "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
        -DUNGYP_OFFLINE=ON -DCMAKE_BUILD_TYPE=Release
        COMMAND_ERROR_IS_FATAL ANY)
    execute_process(COMMAND "${CMAKE_COMMAND}" --build "${binary_dir}" --parallel
        COMMAND_ERROR_IS_FATAL ANY)
    set(ADDON "${binary_dir}/Release/${target}.node")
    include("${CMAKE_CURRENT_LIST_DIR}/assert-elf-machine.cmake")
    file(MAKE_DIRECTORY "${TEST_DIR}/artifacts/${TARGET_ARCH}")
    file(COPY_FILE "${ADDON}" "${TEST_DIR}/artifacts/${TARGET_ARCH}/${target}.node" ONLY_IF_DIFFERENT)
endforeach()

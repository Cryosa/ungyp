cmake_minimum_required(VERSION 3.24)
file(MAKE_DIRECTORY "${TEST_DIR}")
file(COPY_FILE "${NODE}" "${TEST_DIR}/custom-host.exe" ONLY_IF_DIFFERENT)
execute_process(COMMAND "${TEST_DIR}/custom-host.exe" "${ASSERT_SCRIPT}" "${ADDON}"
    RESULT_VARIABLE result)
file(REMOVE "${TEST_DIR}/custom-host.exe")
if(NOT result STREQUAL "0")
    message(FATAL_ERROR "Renamed host failed: ${result}")
endif()

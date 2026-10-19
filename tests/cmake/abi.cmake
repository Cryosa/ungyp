cmake_minimum_required(VERSION 3.24)
include("${SOURCE_DIR}/cmake/internal/ABI.cmake")
file(MAKE_DIRECTORY "${TEST_DIR}")
file(WRITE "${TEST_DIR}/config.gypi" "{
  'v8_enable_pointer_compression': 1,
  'v8_enable_pointer_compression_shared_cage': 0,
  'v8_enable_sandbox': 'true',
  \"v8_enable_direct_local\": 1,
  'v8_enable_external_code_space': 0,
  'v8_enable_map_packing': 10
}")
_ungyp_sdk_definitions("${TEST_DIR}" electron definitions)
foreach(required V8_COMPRESS_POINTERS V8_COMPRESS_POINTERS_IN_ISOLATE_CAGE
        V8_31BIT_SMIS_ON_64BIT_ARCH V8_ENABLE_SANDBOX V8_ENABLE_DIRECT_LOCAL USING_ELECTRON_CONFIG_GYPI)
    if(NOT required IN_LIST definitions)
        message(FATAL_ERROR "Missing ABI definition: ${required}")
    endif()
endforeach()
foreach(disabled V8_COMPRESS_POINTERS_IN_SHARED_CAGE V8_EXTERNAL_CODE_SPACE V8_MAP_PACKING)
    if(disabled IN_LIST definitions)
        message(FATAL_ERROR "Unexpected ABI definition: ${disabled}")
    endif()
endforeach()

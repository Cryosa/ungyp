cmake_minimum_required(VERSION 3.25...3.31)
project(node_api_c LANGUAGES C)
if(UNGYP_USE_INSTALLED)
    find_package(ungyp CONFIG REQUIRED)
else()
    include(FetchContent)
    FetchContent_Declare(ungyp SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/../..")
    FetchContent_MakeAvailable(ungyp)
endif()
ungyp_addon(node_api_c SOURCES addon.c)
set_target_properties(node_api_c PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>")

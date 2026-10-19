cmake_minimum_required(VERSION 3.25...3.31)
project(node_v8 LANGUAGES CXX)
if(UNGYP_USE_INSTALLED)
    find_package(ungyp CONFIG REQUIRED)
else()
    include(FetchContent)
    FetchContent_Declare(ungyp SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/../..")
    FetchContent_MakeAvailable(ungyp)
endif()
ungyp_addon(node_v8 SOURCES addon.cpp V8)
set_target_properties(node_v8 PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>")

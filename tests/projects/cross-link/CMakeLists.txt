cmake_minimum_required(VERSION 3.25...3.31)
project(cross_link LANGUAGES C CXX)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
include("${CMAKE_CURRENT_LIST_DIR}/../../../cmake/ungyp.cmake")
add_library(greeting STATIC greeting.c)
set_target_properties(greeting PROPERTIES POSITION_INDEPENDENT_CODE ON)
ungyp_addon(cross_link SOURCES addon.cpp)
target_link_libraries(cross_link PRIVATE greeting)
set_target_properties(cross_link PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>")

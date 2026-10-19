include_guard(GLOBAL)

# node-api-headers 1.9.0, nodejs/node-api-headers@8d0ef96a771d67f79b5436604d8c697ea70b618e.
# The bundled .def uses lowercase node.exe to match /DELAYLOAD:node.exe.

function(_ungyp_setup_napi)
    if(TARGET ungyp::napi)
        return()
    endif()
    set(sdk "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../third_party/node-api-headers")
    add_library(ungyp::napi INTERFACE IMPORTED GLOBAL)
    set_target_properties(ungyp::napi PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${sdk}/include"
        INTERFACE_COMPILE_DEFINITIONS BUILDING_NODE_EXTENSION)
    if(WIN32 OR UNGYP_ARCH)
        _ungyp_architecture(arch)
        set_property(TARGET ungyp::napi PROPERTY UNGYP_ARCH "${arch}")
    endif()
    if(WIN32)
        set(machine "${arch}")
        if(arch STREQUAL "ia32")
            set(machine x86)
        endif()
        set(library "${CMAKE_CURRENT_BINARY_DIR}/ungyp/node-api.lib")
        add_custom_command(OUTPUT "${library}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/ungyp"
            COMMAND "${CMAKE_AR}" /nologo "/def:${sdk}/def/node_api.def"
                "/machine:${machine}" "/out:${library}"
            DEPENDS "${sdk}/def/node_api.def"
            COMMENT "Generating Node-API import library (${arch})" VERBATIM)
        # MSVC also emits .exp; llvm-lib emits only .lib. Do not make Ninja
        # rebuild the import library on every invocation when .exp is absent.
        set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_CLEAN_FILES
            "${CMAKE_CURRENT_BINARY_DIR}/ungyp/node-api.exp")
        add_custom_target(_ungyp_node_api_library DEPENDS "${library}")
        add_dependencies(ungyp::napi _ungyp_node_api_library)
        target_link_libraries(ungyp::napi INTERFACE "${library}")
    endif()
    _ungyp_platform_setup(ungyp::napi)
endfunction()

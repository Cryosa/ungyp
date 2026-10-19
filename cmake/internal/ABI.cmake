include_guard(GLOBAL)

# Read only literal, ABI-relevant switches. Never execute GYP/Python expressions.
function(_ungyp_sdk_definitions include_dir runtime output)
    set(definitions BUILDING_NODE_EXTENSION USING_UV_SHARED=1 USING_V8_SHARED=1
        _LARGEFILE_SOURCE _FILE_OFFSET_BITS=64)
    set(config "")
    if(EXISTS "${include_dir}/config.gypi")
        file(READ "${include_dir}/config.gypi" config)
        set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${include_dir}/config.gypi")
    elseif(runtime STREQUAL "electron")
        message(FATAL_ERROR "ungyp: Electron SDK requires config.gypi for V8 ABI settings")
    endif()
    set(mappings
        v8_enable_pointer_compression=V8_COMPRESS_POINTERS
        v8_enable_pointer_compression_shared_cage=V8_COMPRESS_POINTERS_IN_SHARED_CAGE
        v8_enable_31bit_smis_on_64bit_arch=V8_31BIT_SMIS_ON_64BIT_ARCH
        v8_enable_sandbox=V8_ENABLE_SANDBOX
        v8_enable_external_code_space=V8_EXTERNAL_CODE_SPACE
        v8_enable_direct_local=V8_ENABLE_DIRECT_LOCAL
        v8_enable_direct_handle=V8_ENABLE_DIRECT_HANDLE
        v8_enable_conservative_stack_scanning=V8_ENABLE_CONSERVATIVE_STACK_SCANNING
        v8_enable_map_packing=V8_MAP_PACKING
        v8_enable_zone_compression=V8_COMPRESS_ZONES
        v8_use_perfetto=V8_USE_PERFETTO)
    foreach(mapping IN LISTS mappings)
        string(REPLACE "=" ";" pair "${mapping}")
        list(GET pair 0 variable)
        list(GET pair 1 definition)
        set(${variable} OFF)
        if(config MATCHES "['\"]${variable}['\"][ \t\r\n]*:[ \t\r\n]*['\"]?(1|true)['\"]?[ \t\r\n]*[,}]")
            set(${variable} ON)
            list(APPEND definitions "${definition}")
        endif()
    endforeach()
    if(v8_enable_pointer_compression)
        list(APPEND definitions V8_31BIT_SMIS_ON_64BIT_ARCH)
        if(NOT v8_enable_pointer_compression_shared_cage)
            list(APPEND definitions V8_COMPRESS_POINTERS_IN_ISOLATE_CAGE)
        endif()
    endif()
    if(runtime STREQUAL "electron")
        list(APPEND definitions USING_ELECTRON_CONFIG_GYPI)
    endif()
    if(APPLE)
        list(APPEND definitions _DARWIN_USE_64_BIT_INODE=1)
    endif()
    list(REMOVE_DUPLICATES definitions)
    set(${output} "${definitions}" PARENT_SCOPE)
endfunction()

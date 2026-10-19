# ungyp

用 CMake 构建 Node.js / Electron 原生模块。需要 CMake 3.25+、Git 和 C++ 编译器；构建无需 Node.js、npm 或 Python。

`CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.25)
project(hello LANGUAGES CXX)

include(FetchContent)
FetchContent_Declare(ungyp
    GIT_REPOSITORY https://github.com/Cryosa/ungyp.git
    GIT_TAG v1.0.0
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(ungyp)

ungyp_addon(hello SOURCES addon.cpp)
set_target_properties(hello PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/$<CONFIG>")
```

`addon.cpp`

```cpp
#include <node_api.h>

static napi_value hello(napi_env env, napi_callback_info) {
    napi_value result;
    if (napi_create_string_utf8(env, "Hello from ungyp!", NAPI_AUTO_LENGTH, &result) != napi_ok)
        return nullptr;
    return result;
}

NAPI_MODULE_INIT() {
    napi_value function;
    if (napi_create_function(env, "hello", NAPI_AUTO_LENGTH, hello, nullptr, &function) != napi_ok)
        return nullptr;
    if (napi_set_named_property(env, exports, "hello", function) != napi_ok)
        return nullptr;
    return exports;
}
```

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --parallel
node -p "require('./build/Release/hello.node').hello()"
```

[MIT License](LICENSE) · 内置 node-api-headers 1.9.0，[许可证](cmake/third_party/node-api-headers/LICENSE)。

# ungyp

用 CMake 构建 Node.js / Electron 原生模块。不含GYP工具，兼容CmakeJs生态，不依赖Npm与Npx。

## 快速开始

创建以下两个文件，通过 FetchContent 引入 `v1.0.0`：

`CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.25)
project(hello LANGUAGES CXX)

include(FetchContent)
FetchContent_Declare(ungyp
    GIT_REPOSITORY https://github.com/Cryosa/ungyp.git
    GIT_TAG v1.0.1
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

## 交叉编译

### Windows → Linux：Clang 示例

```sh
cmake -S . -B build/linux-arm64 -G Ninja --toolchain /path/to/ungyp/cmake/toolchains/clang-linux.cmake "-DUNGYP_LLVM_ROOT=C:/tools/llvm" -DUNGYP_LINUX_TARGET=aarch64-linux-gnu "-DCMAKE_SYSROOT=C:/sdk/linux-arm64" -DCMAKE_BUILD_TYPE=Release
cmake --build build/linux-arm64 --parallel
```

## 示例与测试

| 路径 | 内容 |
| --- | --- |
| [examples/node-api-c](examples/node-api-c) | C Node-API 模块 |
| [examples/node-api-cpp](examples/node-api-cpp) | C++ Node-API 模块 |
| [examples/node-v8](examples/node-v8) | Node/V8 模块 |
| [tests/projects](tests/projects) | 集成用例 |

```sh
cmake -S . -B build/tests -DUNGYP_BUILD_TESTS=ON -DUNGYP_NODE_VERSION=22.14.0 -DCMAKE_BUILD_TYPE=Release
cmake --build build/tests --config Release --parallel
ctest --test-dir build/tests -C Release --output-on-failure
```

## 许可证

[MIT License](LICENSE)

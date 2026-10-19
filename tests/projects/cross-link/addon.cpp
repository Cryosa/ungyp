#include <node_api.h>
#include <string>

extern "C" const char *greeting(void);

static napi_value hello(napi_env env, napi_callback_info) {
    const std::string message = std::string("Hello from ") + greeting() + "!";
    napi_value result;
    if (napi_create_string_utf8(env, message.c_str(), message.size(), &result) != napi_ok)
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

#include <node_api.h>

static napi_value hello(napi_env env, napi_callback_info info) {
    napi_value result;
    (void)info;
    if (napi_create_string_utf8(env, "Hello from ungyp!", NAPI_AUTO_LENGTH, &result) != napi_ok)
        return NULL;
    return result;
}

NAPI_MODULE_INIT() {
    napi_value function;
    if (napi_create_function(env, "hello", NAPI_AUTO_LENGTH, hello, NULL, &function) != napi_ok)
        return NULL;
    if (napi_set_named_property(env, exports, "hello", function) != napi_ok)
        return NULL;
    return exports;
}

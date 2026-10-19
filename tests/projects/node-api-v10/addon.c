#include <node_api.h>

static napi_value hello(napi_env env, napi_callback_info info) {
    napi_value arraybuffer, buffer, result;
    void* data;
    (void)info;
    if (napi_create_arraybuffer(env, 1, &data, &arraybuffer) != napi_ok)
        return NULL;
    if (node_api_create_buffer_from_arraybuffer(env, arraybuffer, 0, 1, &buffer) != napi_ok)
        return NULL;
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

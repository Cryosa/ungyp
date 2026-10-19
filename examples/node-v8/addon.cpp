#include <node.h>

static void Hello(const v8::FunctionCallbackInfo<v8::Value>& args) {
    args.GetReturnValue().Set(v8::String::NewFromUtf8Literal(args.GetIsolate(), "Hello from ungyp!"));
}

static void Init(v8::Local<v8::Object> exports) {
    NODE_SET_METHOD(exports, "hello", Hello);
}

NODE_MODULE(NODE_GYP_MODULE_NAME, Init)

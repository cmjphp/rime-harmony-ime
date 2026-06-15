#include "rime_bridge.h"

#include <napi/native_api.h>

static napi_module g_rimeBridgeModule = {
    1,
    0,
    nullptr,
    RimeBridgeInit,
    "rime_bridge",
    nullptr,
    {nullptr},
};

extern "C" __attribute__((constructor)) void RegisterRimeBridgeModule()
{
    napi_module_register(&g_rimeBridgeModule);
}

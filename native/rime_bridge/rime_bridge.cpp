#include "rime_bridge.h"

#if defined(RIME_BRIDGE_USE_REAL_RIME)
#include "rime_engine_real.h"
#else
#include "rime_engine_stub.h"
#endif

#include <algorithm>
#include <memory>
#include <string>
#include <vector>

namespace {
#if defined(RIME_BRIDGE_USE_REAL_RIME)
using BridgeEngine = RimeEngineReal;
#else
using BridgeEngine = RimeEngineStub;
#endif

std::unique_ptr<RimeEngine> g_engine = std::make_unique<BridgeEngine>();

std::string ReadStringArg(napi_env env, napi_value value)
{
    size_t length = 0;
    napi_get_value_string_utf8(env, value, nullptr, 0, &length);
    std::vector<char> buffer(length + 1, '\0');
    napi_get_value_string_utf8(env, value, buffer.data(), buffer.size(), &length);
    return std::string(buffer.data(), length);
}

int32_t ReadIntArg(napi_env env, napi_value value)
{
    int32_t result = 0;
    napi_get_value_int32(env, value, &result);
    return result;
}

bool ReadBoolArg(napi_env env, napi_value value)
{
    bool result = false;
    napi_get_value_bool(env, value, &result);
    return result;
}

napi_value MakeBoolean(napi_env env, bool value)
{
    napi_value result = nullptr;
    napi_get_boolean(env, value, &result);
    return result;
}

napi_value MakeString(napi_env env, const std::string& value)
{
    napi_value result = nullptr;
    napi_create_string_utf8(env, value.c_str(), value.size(), &result);
    return result;
}

napi_value MakeUndefined(napi_env env)
{
    napi_value result = nullptr;
    napi_get_undefined(env, &result);
    return result;
}

napi_value Init(napi_env env, napi_callback_info info)
{
    try {
        size_t argc = 2;
        napi_value args[2] = {nullptr, nullptr};
        napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
        if (argc < 2) {
            return MakeBoolean(env, false);
        }
        return MakeBoolean(env, g_engine->Init(ReadStringArg(env, args[0]), ReadStringArg(env, args[1])));
    } catch (...) {
        return MakeBoolean(env, false);
    }
}

napi_value ProcessKey(napi_env env, napi_callback_info info)
{
    try {
        size_t argc = 2;
        napi_value args[2] = {nullptr, nullptr};
        napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
        if (argc < 2) {
            return MakeBoolean(env, false);
        }
        return MakeBoolean(env, g_engine->ProcessKey(ReadIntArg(env, args[0]), ReadIntArg(env, args[1])));
    } catch (...) {
        return MakeBoolean(env, false);
    }
}

napi_value GetComposition(napi_env env, napi_callback_info info)
{
    (void)info;
    try {
        return MakeString(env, g_engine->GetComposition());
    } catch (...) {
        return MakeString(env, "");
    }
}

napi_value GetCandidates(napi_env env, napi_callback_info info)
{
    (void)info;
    napi_value result = nullptr;
    napi_create_array(env, &result);
    try {
        auto candidates = g_engine->GetCandidates();
        for (size_t index = 0; index < candidates.size(); index++) {
            napi_set_element(env, result, static_cast<uint32_t>(index), MakeString(env, candidates[index]));
        }
    } catch (...) {
    }
    return result;
}

napi_value CommitCandidate(napi_env env, napi_callback_info info)
{
    try {
        size_t argc = 1;
        napi_value args[1] = {nullptr};
        napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
        size_t index = 0;
        if (argc > 0) {
            index = static_cast<size_t>(std::max(0, ReadIntArg(env, args[0])));
        }
        return MakeString(env, g_engine->CommitCandidate(index));
    } catch (...) {
        g_engine->ClearComposition();
        return MakeString(env, "");
    }
}

napi_value ClearComposition(napi_env env, napi_callback_info info)
{
    (void)info;
    try {
        g_engine->ClearComposition();
    } catch (...) {
    }
    return MakeUndefined(env);
}

napi_value SetOption(napi_env env, napi_callback_info info)
{
    try {
        size_t argc = 2;
        napi_value args[2] = {nullptr, nullptr};
        napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
        if (argc < 2) {
            return MakeBoolean(env, false);
        }
        return MakeBoolean(env, g_engine->SetOption(ReadStringArg(env, args[0]), ReadBoolArg(env, args[1])));
    } catch (...) {
        return MakeBoolean(env, false);
    }
}

napi_value Deploy(napi_env env, napi_callback_info info)
{
    (void)info;
    try {
        return MakeBoolean(env, g_engine->Deploy());
    } catch (...) {
        return MakeBoolean(env, false);
    }
}

napi_value GetStatus(napi_env env, napi_callback_info info)
{
    (void)info;
    napi_value result = nullptr;
    napi_create_object(env, &result);
    try {
        auto status = g_engine->GetStatus();
        napi_set_named_property(env, result, "ready", MakeBoolean(env, status.ready));
        napi_set_named_property(env, result, "nativeLoaded", MakeBoolean(env, status.nativeLoaded));
        napi_set_named_property(env, result, "engine", MakeString(env, status.engine));
        napi_value compositionLength = nullptr;
        napi_create_uint32(env, static_cast<uint32_t>(status.compositionLength), &compositionLength);
        napi_set_named_property(env, result, "compositionLength", compositionLength);
    } catch (...) {
    }
    return result;
}
}

napi_value RimeBridgeInit(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"init", nullptr, Init, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"processKey", nullptr, ProcessKey, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getComposition", nullptr, GetComposition, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCandidates", nullptr, GetCandidates, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"commitCandidate", nullptr, CommitCandidate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clearComposition", nullptr, ClearComposition, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setOption", nullptr, SetOption, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"deploy", nullptr, Deploy, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getStatus", nullptr, GetStatus, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}

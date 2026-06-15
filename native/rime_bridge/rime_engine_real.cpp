#include "rime_engine_real.h"

#include <rime_api.h>

namespace {
constexpr const char* kAppName = "RimeHarmonyIME";
constexpr const char* kDefaultSchema = "rime_harmony";
}

RimeEngineReal::RimeEngineReal() = default;

RimeEngineReal::~RimeEngineReal()
{
    if (api_ && sessionId_ != 0) {
        api_->destroy_session(sessionId_);
        sessionId_ = 0;
    }
    if (api_) {
        api_->finalize();
    }
}

bool RimeEngineReal::Init(const std::string& userDir, const std::string& sharedDataDir)
{
    api_ = rime_get_api();
    if (!api_) {
        return false;
    }

    RimeTraits traits = {0};
    RIME_STRUCT_INIT(RimeTraits, traits);
    traits.app_name = kAppName;
    traits.user_data_dir = userDir.c_str();
    traits.shared_data_dir = sharedDataDir.c_str();
    traits.distribution_name = "RimeHarmonyIME";
    traits.distribution_code_name = "rime_harmony_ime";
    traits.distribution_version = "0.1.0";

    api_->setup(&traits);
    api_->initialize(&traits);
    sessionId_ = api_->create_session();
    if (sessionId_ != 0) {
        api_->select_schema(sessionId_, kDefaultSchema);
        api_->set_option(sessionId_, "ascii_mode", false);
        api_->set_option(sessionId_, "simplification", true);
    }
    ready_ = sessionId_ != 0;
    return ready_;
}

bool RimeEngineReal::ProcessKey(int keyCode, int modifier)
{
    if (!ready_ || !api_) {
        return false;
    }
    return api_->process_key(sessionId_, keyCode, modifier);
}

std::string RimeEngineReal::GetComposition() const
{
    if (!ready_ || !api_) {
        return "";
    }

    RimeContext context = {0};
    RIME_STRUCT_INIT(RimeContext, context);
    if (!api_->get_context(sessionId_, &context)) {
        return "";
    }

    std::string result;
    if (context.composition.preedit) {
        result = context.composition.preedit;
    }
    api_->free_context(&context);
    return result;
}

std::vector<std::string> RimeEngineReal::GetCandidates() const
{
    std::vector<std::string> result;
    if (!ready_ || !api_) {
        return result;
    }

    RimeContext context = {0};
    RIME_STRUCT_INIT(RimeContext, context);
    if (!api_->get_context(sessionId_, &context)) {
        return result;
    }

    for (size_t index = 0; index < context.menu.num_candidates; ++index) {
        const RimeCandidate& candidate = context.menu.candidates[index];
        if (candidate.text) {
            result.emplace_back(candidate.text);
        }
    }
    api_->free_context(&context);
    return result;
}

std::string RimeEngineReal::CommitCandidate(size_t index)
{
    if (!ready_ || !api_) {
        return "";
    }

    std::string fallback;
    auto candidates = GetCandidates();
    if (index < candidates.size()) {
        fallback = candidates[index];
    }

    if (!api_->select_candidate_on_current_page(sessionId_, index)) {
        return fallback;
    }

    RimeCommit commit = {0};
    RIME_STRUCT_INIT(RimeCommit, commit);
    if (!api_->get_commit(sessionId_, &commit)) {
        return fallback;
    }

    std::string result;
    if (commit.text) {
        result = commit.text;
    }
    api_->free_commit(&commit);
    return result.empty() ? fallback : result;
}

void RimeEngineReal::ClearComposition()
{
    if (ready_ && api_) {
        api_->clear_composition(sessionId_);
    }
}

bool RimeEngineReal::SetOption(const std::string& option, bool value)
{
    if (!ready_ || !api_ || option.empty()) {
        return false;
    }
    api_->set_option(sessionId_, option.c_str(), value);
    return api_->get_option(sessionId_, option.c_str()) == value;
}

bool RimeEngineReal::Deploy()
{
    if (!api_) {
        return false;
    }
    api_->start_maintenance(true);
    api_->join_maintenance_thread();
    if (sessionId_ != 0) {
        api_->destroy_session(sessionId_);
    }
    sessionId_ = api_->create_session();
    if (sessionId_ != 0) {
        api_->select_schema(sessionId_, kDefaultSchema);
        api_->set_option(sessionId_, "ascii_mode", false);
        api_->set_option(sessionId_, "simplification", true);
    }
    ready_ = sessionId_ != 0;
    return ready_;
}

RimeEngineStatus RimeEngineReal::GetStatus() const
{
    RimeEngineStatus status;
    status.ready = ready_;
    status.nativeLoaded = true;
    status.engine = "librime";
    status.compositionLength = GetComposition().size();
    if (ready_ && api_) {
        RimeStatus rimeStatus = {0};
        RIME_STRUCT_INIT(RimeStatus, rimeStatus);
        if (api_->get_status(sessionId_, &rimeStatus)) {
            status.engine += "/";
            status.engine += rimeStatus.schema_id ? rimeStatus.schema_id : "no-schema";
            status.engine += rimeStatus.is_ascii_mode ? "/ascii" : "/zh";
            api_->free_status(&rimeStatus);
        }
        status.engine += "/cand=";
        status.engine += std::to_string(GetCandidates().size());
        status.engine += api_->get_option(sessionId_, "simplification") ? "/simp" : "/trad";
    }
    return status;
}

#include "rime_engine_stub.h"

bool RimeEngineStub::Init(const std::string& userDir, const std::string& sharedDataDir)
{
    ready_ = !userDir.empty() && !sharedDataDir.empty();
    return true;
}

bool RimeEngineStub::ProcessKey(int keyCode, int modifier)
{
    (void)modifier;
    char value = static_cast<char>(keyCode);
    if (value >= 'A' && value <= 'Z') {
        value = static_cast<char>(value - 'A' + 'a');
    }
    if (value < 'a' || value > 'z') {
        return false;
    }
    composition_.push_back(value);
    return true;
}

std::string RimeEngineStub::GetComposition() const
{
    return composition_;
}

std::vector<std::string> RimeEngineStub::GetCandidates() const
{
    return {};
}

std::string RimeEngineStub::CommitCandidate(size_t index)
{
    auto candidates = GetCandidates();
    std::string committed;
    if (index < candidates.size()) {
        committed = candidates[index];
    } else {
        committed = composition_;
    }
    ClearComposition();
    return committed;
}

void RimeEngineStub::ClearComposition()
{
    composition_.clear();
}

bool RimeEngineStub::SetOption(const std::string& option, bool value)
{
    if (option != "simplification") {
        return false;
    }
    simplification_ = value;
    return true;
}

bool RimeEngineStub::Deploy()
{
    return true;
}

RimeEngineStatus RimeEngineStub::GetStatus() const
{
    RimeEngineStatus status;
    status.ready = ready_;
    status.nativeLoaded = true;
    status.engine = simplification_ ? "cpp-stub/simp" : "cpp-stub/trad";
    status.compositionLength = composition_.size();
    return status;
}

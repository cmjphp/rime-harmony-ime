#pragma once

#include "rime_engine.h"

#include <memory>

struct rime_api_t;
typedef struct rime_api_t RimeApi;

class RimeEngineReal : public RimeEngine {
public:
    RimeEngineReal();
    ~RimeEngineReal() override;

    bool Init(const std::string& userDir, const std::string& sharedDataDir) override;
    bool ProcessKey(int keyCode, int modifier) override;
    std::string GetComposition() const override;
    std::vector<std::string> GetCandidates() const override;
    std::string CommitCandidate(size_t index) override;
    void ClearComposition() override;
    bool SetOption(const std::string& option, bool value) override;
    bool Deploy() override;
    RimeEngineStatus GetStatus() const override;

private:
    const RimeApi* api_ = nullptr;
    uintptr_t sessionId_ = 0;
    bool ready_ = false;
};

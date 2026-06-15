#pragma once

#include "rime_engine.h"

class RimeEngineStub : public RimeEngine {
public:
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
    std::string composition_;
    bool ready_ = false;
    bool simplification_ = true;
};

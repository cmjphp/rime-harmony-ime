#pragma once

#include <string>
#include <vector>

struct RimeEngineStatus {
    bool ready = false;
    bool nativeLoaded = true;
    std::string engine;
    size_t compositionLength = 0;
};

class RimeEngine {
public:
    virtual ~RimeEngine() = default;
    virtual bool Init(const std::string& userDir, const std::string& sharedDataDir) = 0;
    virtual bool ProcessKey(int keyCode, int modifier) = 0;
    virtual std::string GetComposition() const = 0;
    virtual std::vector<std::string> GetCandidates() const = 0;
    virtual std::string CommitCandidate(size_t index) = 0;
    virtual void ClearComposition() = 0;
    virtual bool SetOption(const std::string& option, bool value) = 0;
    virtual bool Deploy() = 0;
    virtual RimeEngineStatus GetStatus() const = 0;
};

# RimeHarmonyIME

HarmonyOS NEXT input method MVP using an ArkTS keyboard frontend and a Rime-compatible native bridge boundary.

## Current scope

- InputMethodExtensionAbility registration.
- Minimal keyboard UI with letters, space, delete, enter, composition, and candidates.
- ArkTS mock Rime engine with safe fallback when `librime_bridge.so` is not loadable.
- C++ NAPI stub exposing the future librime API surface.

## Recommended structure

```text
entry/
  src/main/
    ets/
      entryability/
      inputmethod/
      pages/
      components/
      native/
    resources/base/profile/
native/
  rime_bridge/
docs/
```

No third-party frontend code is copied into this repository.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Input Method Lock** (target name: `InputMethodGuard`) — a macOS menu-bar utility that locks the active input method to a user-selected source. When any app is frontmost and the input method changes away from the selected one, the app immediately switches it back. This prevents accidental input method switches during normal usage.

## Build & Run

```bash
# Build (Debug)
xcodebuild -project InputMethodGuard.xcodeproj -scheme InputMethodGuard -configuration Debug build

# Build (Release)
xcodebuild -project InputMethodGuard.xcodeproj -scheme InputMethodGuard -configuration Release build

# Open in Xcode
open InputMethodGuard.xcodeproj
```

No test targets exist. No external dependencies (SPM/CocoaPods/Carthage).

## Architecture

Pure AppKit macOS app (no SwiftUI). Uses `NSApplication` programmatic setup via `main.swift` instead of `@main`.

**Flow:** `main.swift` → creates `AppDelegate` → creates `InputMonitor` → listens for `kTISNotifySelectedKeyboardInputSourceChanged` distributed notifications → if input source changed away from target, switches back immediately.

**Key components:**

- **`main.swift`** — Manual `NSApplication` bootstrap. No `@NSApplicationMain` / `@main`.
- **`AppDelegate`** — Status bar item with menu: toggle guard on/off, select target input method from list, quit. Calls `refreshMenu()` after every config change.
- **`InputMonitor`** — Observes system input source change notifications. Applies debouncing (0.3s) to handle rapid system events. Checks whitelist before forcing switch back.
- **`InputSourceManager`** — Carbon `TIS` API wrapper: enumerates keyboard input sources, gets current source ID, switches to a given source ID. Filters out `com.tencent.inputmethod.wetype` from the source list.
- **`Config`** — `UserDefaults`-backed config with `Codable` model (`ConfigModel`). Stores `enabled`, `targetIM`, `whitelistApps`.

**Important details:**
- App runs as `.accessory` (no dock icon, menu-bar only).
- App Sandbox is enabled (`ENABLE_APP_SANDBOX = YES`). The Carbon TIS API calls require appropriate entitlements.
- Deployment target: macOS 15.7. Swift 5.0. Xcode 26.3 (objectVersion 77).
- Product bundle identifier: `com.huangjia.pw.InputMethodGuard`.
- Build product name: `Input Method Lock.app`.

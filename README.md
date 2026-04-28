# Input Method Lock

[English](#english)

macOS 状态栏小工具，锁定当前输入法，防止意外切换。

![screenshot](screenshot.png)

## 下载

不想自己拉源码打包的话，可以直接下载我已经编译好的 app：[Releases](https://github.com/a471640241/InputMethod-Lock/releases)

当前构建环境：macOS 15.7，Apple Silicon (M1)。其他环境未测试，如有问题欢迎提 Issue。

## 背景

在使用 Mac 时，系统或某些应用会自动切换输入法（比如从英文切到中文，或反过来），导致打字时出现意想不到的中英文混合。这个工具会在输入法被意外切走时，立即将其切换回你选定的输入法。

## 功能

- **锁定输入法** — 选择一个目标输入法，任何非预期的切换都会被自动纠正
- **开关守护** — 随时启用/禁用，不重启应用
- **开机自启** — 可选开机自动启动，在系统设置中管理
- **隐藏图标** — 隐藏状态栏图标，守护仍在后台运行，下次启动自动恢复

## 系统要求

- macOS 15.7+
- Xcode 26.3+

## 构建

```bash
git clone https://github.com/a471640241/InputMethod-Lock.git
cd InputMethodGuard
open InputMethodGuard.xcodeproj
```

在 Xcode 中点击 Build & Run（⌘R）即可运行。

## 安装提示

macOS 可能会提示"无法验证开发者"而阻止打开应用，处理方法：

1. 先尝试打开应用，弹出安全提示后关闭
2. 打开 **系统设置 → 隐私与安全性**
3. 在底部找到被阻止的应用，点击 **仍要打开**

或者直接在终端执行：

```bash
xattr -cr /Applications/Input\ Method\ Lock.app
```

## 原理

应用启动后在状态栏显示一个图标，通过监听 `kTISNotifySelectedKeyboardInputSourceChanged` 系统通知来感知输入法变化。当检测到当前输入法与用户选定的目标输入法不一致时，调用 Carbon `TISSelectInputSource` 将其切回。

## 开发过程

老实说，这是我第一次写 Swift，之前连 Xcode 都没怎么打开过。事情的起因很简单：打字的时候输入法老是被莫名其妙切走，忍无可忍，决定自己搞一个。

先去找 ChatGPT 聊了聊，问了问 macOS 上怎么监听和切换输入法，它给我指了 Carbon TIS API 的方向。有了思路之后，就直接上 [Claude Code](https://claude.ai/code) 开干了——在终端里一句一句告诉它要做什么，它就一行一行把代码写出来。用的模型是 **GLM-5.1**，整个过程就像Pair Programming，只不过搭档不会喝咖啡也不会摸鱼。

从零到能用的第一个版本，大概也就一个下午的事。AI 写代码确实方便，但调试和修 bug 还是得自己盯着——比如隐藏状态栏图标后 Dock 栏又冒出来这种坑，AI 也不一定一次就能想到。

## 许可证

MIT License

---

<a id="english"></a>

# Input Method Lock

A macOS menu-bar utility that locks your input method and prevents accidental switching.

![screenshot](screenshot.png)

## Download

Don't want to clone and build from source? Grab the pre-built app here: [Releases](https://github.com/a471640241/InputMethod-Lock/releases)

Built on: macOS 15.7, Apple Silicon (M1). Other environments are untested — feel free to open an Issue if you run into problems.

## Background

On macOS, the system or certain apps may automatically switch your input method (e.g., from English to Chinese or vice versa), causing unexpected mixed-language text while typing. This tool detects unintended input method changes and immediately switches back to your chosen one.

## Features

- **Lock input method** — Select a target input method; any unintended switch is automatically corrected
- **Toggle guard** — Enable or disable at any time without restarting the app
- **Launch at login** — Optionally start automatically on login, managed via System Settings
- **Hide icon** — Hide the menu-bar icon while the guard continues running in the background; icon reappears on next launch

## Requirements

- macOS 15.7+
- Xcode 26.3+

## Build

```bash
git clone https://github.com/a471640241/InputMethod-Lock.git
cd InputMethodGuard
open InputMethodGuard.xcodeproj
```

Press Build & Run (⌘R) in Xcode to run.

## Installation Note

macOS may block the app with a "cannot verify developer" warning. To bypass it:

1. Try opening the app, then dismiss the security prompt
2. Go to **System Settings → Privacy & Security**
3. Find the blocked app at the bottom and click **Open Anyway**

Or simply run this in Terminal:

```bash
xattr -cr /Applications/Input\ Method\ Lock.app
```

## How It Works

The app displays a menu-bar icon on launch and listens for the `kTISNotifySelectedKeyboardInputSourceChanged` system notification to detect input method changes. When the current input method differs from the user-selected target, it calls Carbon `TISSelectInputSource` to switch back.

## Development

Full disclosure: this is my very first Swift project. Before this, I barely even opened Xcode. The whole thing started because I got fed up with my input method randomly switching while typing, so I decided to just build a fix myself.

I started by bouncing ideas off ChatGPT — asked it how to listen for and switch input methods on macOS. It pointed me toward the Carbon TIS API. Armed with that knowledge, I fired up [Claude Code](https://claude.ai/code) and got to work. I'd describe what I wanted in plain language, and it'd write the code line by line. The model behind it was **GLM-5.1**. The whole process felt like pair programming, except my partner doesn't drink coffee or slack off.

From zero to a working first version took roughly an afternoon. AI-assisted coding is pretty handy, but you still have to keep an eye on things — like the time the status bar icon was hidden but the Dock icon mysteriously reappeared. AI doesn't always catch those edge cases on the first try either.

## License

MIT License

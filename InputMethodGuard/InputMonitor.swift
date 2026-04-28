import Cocoa
import Carbon

class InputMonitor {

    private var lastTime = Date(timeIntervalSince1970: 0)

    init() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(onChange),
            name: NSNotification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String),
            object: nil
        )
    }

    @objc func onChange() {

        guard Config.data.enabled else { return }

        // 防抖（解决系统连续触发）
        let now = Date()
        if now.timeIntervalSince(lastTime) < 0.3 {
            return
        }

        let current = InputSourceManager.currentID() ?? ""
        let app = NSWorkspace.shared.frontmostApplication?.localizedName ?? ""

        // 白名单 App 不处理
        if Config.data.whitelistApps.contains(app) {
            return
        }

        if current != Config.data.targetIM {
            lastTime = now
            InputSourceManager.switchTo(id: Config.data.targetIM)

            print("🔁 修正输入法: \(current) → \(Config.data.targetIM) | App: \(app)")
        }
    }
}

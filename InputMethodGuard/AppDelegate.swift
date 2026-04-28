import Cocoa
import ServiceManagement


class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    let monitor = InputMonitor()

    func applicationDidFinishLaunching(_ notification: Notification) {

        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "⌨️"

        if Config.data.launchAtLogin {
            try? SMAppService.mainApp.register()
        }

        refreshMenu()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            statusItem.button?.title = "⌨️"
            refreshMenu()
        }
    }

    func refreshMenu() {

        let menu = NSMenu()

        // 开关
        let toggle = NSMenuItem(
            title: Config.data.enabled ? "关闭守护" : "开启守护",
            action: #selector(toggleAction),
            keyEquivalent: ""
        )
        toggle.target = self
        menu.addItem(toggle)

        menu.addItem(.separator())

        // 输入法列表
        for im in InputSourceManager.allSources() {

            let item = NSMenuItem(
                title: im.name,
                action: #selector(selectIM(_:)),
                keyEquivalent: ""
            )

            item.target = self
            item.representedObject = im.id
            item.state = (im.id == Config.data.targetIM) ? .on : .off

            menu.addItem(item)
        }

        menu.addItem(.separator())

        let launchItem = NSMenuItem(
            title: "开机自启",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchItem.target = self
        launchItem.state = Config.data.launchAtLogin ? .on : .off
        menu.addItem(launchItem)

        let hideItem = NSMenuItem(
            title: "隐藏状态栏图标",
            action: #selector(hideStatusBar),
            keyEquivalent: ""
        )
        hideItem.target = self
        menu.addItem(hideItem)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu
    }

    @objc func toggleAction() {
        Config.data.enabled.toggle()
        Config.save()
        refreshMenu()
    }

    @objc func selectIM(_ sender: NSMenuItem) {
        if let id = sender.representedObject as? String {
            Config.data.targetIM = id
            Config.save()
            refreshMenu()
        }
    }

    @objc func addWhitelist() {
        if let app = NSWorkspace.shared.frontmostApplication?.localizedName {
            if !Config.data.whitelistApps.contains(app) {
                Config.data.whitelistApps.append(app)
                Config.save()
                print("加入白名单: \(app)")
            }
        }
    }

    @objc func toggleLaunchAtLogin() {
        Config.data.launchAtLogin.toggle()
        Config.save()
        do {
            if Config.data.launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("登录项设置失败: \(error)")
        }
        refreshMenu()
    }

    @objc func hideStatusBar() {
        statusItem = nil
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}

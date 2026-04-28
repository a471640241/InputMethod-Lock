import Foundation

struct ConfigModel: Codable {
    var enabled: Bool
    var targetIM: String
    var whitelistApps: [String]
    var launchAtLogin: Bool
}

class Config {

    private static let key = "im_guard_config"

    static var data: ConfigModel = load()

    static func load() -> ConfigModel {
        if let d = UserDefaults.standard.data(forKey: key),
           let obj = try? JSONDecoder().decode(ConfigModel.self, from: d) {
            return obj
        }

        return ConfigModel(
            enabled: true,
            targetIM: "",
            whitelistApps: ["Terminal"],
            launchAtLogin: false
        )
    }

    static func save() {
        if let d = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(d, forKey: key)
        }
    }
}

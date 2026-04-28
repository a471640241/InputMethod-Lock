import Carbon

struct InputSourceInfo {
    let id: String
    let name: String
}

class InputSourceManager {

    // 只获取“真实可切换输入法”
    static func allSources() -> [InputSourceInfo] {

        guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }

        var result: [InputSourceInfo] = []

        for src in list {

            // 1️⃣ 过滤 category（关键）
            guard let categoryPtr = TISGetInputSourceProperty(src, kTISPropertyInputSourceCategory) else {
                continue
            }

            let category = Unmanaged<CFString>
                .fromOpaque(categoryPtr)
                .takeUnretainedValue() as String

            guard category == (kTISCategoryKeyboardInputSource as String) else {
                continue
            }
            

            // 2️⃣ id
            guard let idPtr = TISGetInputSourceProperty(src, kTISPropertyInputSourceID),
                  let namePtr = TISGetInputSourceProperty(src, kTISPropertyLocalizedName)
            else { continue }

            let id = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String
            let name = Unmanaged<CFString>.fromOpaque(namePtr).takeUnretainedValue() as String
            
            if id == "com.tencent.inputmethod.wetype" {
                continue
            }

            result.append(InputSourceInfo(id: id, name: name))
        }

        return result
    }

    // 当前输入法
    static func currentID() -> String? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
              let ptr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID)
        else { return nil }

        return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
    }

    // 切换输入法
    static func switchTo(id: String) {
        guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return
        }

        for src in list {
            guard let ptr = TISGetInputSourceProperty(src, kTISPropertyInputSourceID) else { continue }

            let sid = Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String

            if sid == id {
                TISSelectInputSource(src)
                return
            }
        }
    }
}

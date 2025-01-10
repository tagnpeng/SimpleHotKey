import AppKit
import SwiftUICore
import Combine
import Foundation
import Cocoa

class ShortcutManager {
//    private var items: [Item] = [] // 动态从 Item 数据加载快捷键配置
    private var isMonitoring = false // 是否正在监听
    var itemDict =  [String: Item]()
    
    func setItem(items: [Item]) {
//        self.items = items
        if !items.isEmpty {
            itemDict = Dictionary(uniqueKeysWithValues: items.map { ($0.shortcutKey, $0) })
        }
    }
    
    func check(appIdentifier: String, shortcuKey: String) -> Bool {
        if let v = itemDict[shortcuKey] {
            //检查是否已经存在
            if appIdentifier != v.appIdentifier {
                //快捷键冲突
                return false;
            }
        }
        return true
    }
    
    func setItem(item: Item) {
        itemDict.updateValue(item, forKey: item.shortcutKey)
    }
    
    func remove(item: Item) {
        if let v = itemDict[item.shortcutKey] {
            if v.appIdentifier == item.appIdentifier {
                itemDict.removeValue(forKey: item.appIdentifier)
            }
        }
    }
    
    /// 启动全局按键监听
    func startListening() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("程序需要授权辅助功能")
        }
        
        guard !isMonitoring else { return }
        isMonitoring = true
        
        // 全局监听
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyPress(event: event)
        }
        
        // 局部监听
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyPress(event: event)
            return event // 返回事件，确保按键事件正常传递给其他处理器
        }
        
        print("已启动监听")
    }
    
    private func handleKeyPress(event: NSEvent) {
        guard let characters = event.charactersIgnoringModifiers else { return }
//        let shortcut = createShortcutString(characters: characters, flags: event.modifierFlags)
        let shortcut =  createShortcutString(event: event)
        print("按下的快捷键字符串: \(shortcut)")
        
        // 检测是否匹配快捷键，执行额外逻辑
        if let item = itemDict[shortcut] {
            // 检测应用是否处于焦点
            let isAppInFocus = NSWorkspace.shared.frontmostApplication?.bundleIdentifier == item.appIdentifier
            
            if item.isEnabled {
                // 检测当前应用是否启动，未启动则启动应用
                let runningApps = NSWorkspace.shared.runningApplications
                if !runningApps.contains(where: { $0.bundleIdentifier == item.appIdentifier }) {
                    guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: item.appIdentifier) else {
                        print("无法找到应用路径: \(item.appIdentifier)")
                        return
                    }
                    NSWorkspace.shared.open(appURL)
                    print("应用未运行，已启动: \(item.appIdentifier)")
                }
            }
            
            if item.isAnotherOptionEnabled {
                if isAppInFocus {
                    // 当应用处于焦点，则最小化应用
                    minimizeApp(bundleIdentifier: item.appIdentifier)
                    print("应用处于焦点，已最小化: \(item.appIdentifier)")
                } else {
                    // 当应用不处于焦点，则将应用前置
                    bringAppToFront(appIdentifier: item.appIdentifier)
                    print("应用未处于焦点，已置于前台: \(item.appIdentifier)")
                }
            } else {
                // 将应用置于前台
                bringAppToFront(appIdentifier: item.appIdentifier)
                print("应用未处于焦点，已置于前台: \(item.appIdentifier)")
            }
        }
    }
    
    // 辅助方法：最小化应用
    private func minimizeApp(bundleIdentifier: String) {
        guard let app = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == bundleIdentifier }) else {
            print("无法找到运行中的应用: \(bundleIdentifier)")
            return
        }
        
        app.hide()
    }
    
    
    /// 停止监听
    func stopListening() {
        isMonitoring = false
        print("Stopped listening for shortcuts.")
    }
    
    private func createShortcutString(event: NSEvent) -> String {
        var shortcut = ""
        let flags = event.modifierFlags
        let keyCode = event.keyCode

        // 添加修饰键
        if flags.contains(.command) { shortcut += "Cmd+" }
        if flags.contains(.shift) { shortcut += "Shift+" }
        if flags.contains(.control) { shortcut += "Ctrl+" }
        if flags.contains(.option) { shortcut += "Opt+" }

        // 按键映射
        switch keyCode {
        case 0x12: shortcut += "1"  // 物理键 "1"
        case 0x13: shortcut += "2"  // 物理键 "2"
        case 0x14: shortcut += "3"  // 物理键 "3"
        case 0x15: shortcut += "4"  // 物理键 "4"
        case 0x17: shortcut += "5"  // 物理键 "5"
        case 0x16: shortcut += "6"  // 物理键 "6"
        case 0x1A: shortcut += "7"  // 物理键 "7"
        case 0x1C: shortcut += "8"  // 物理键 "8"
        case 0x19: shortcut += "9"  // 物理键 "9"
        case 0x1D: shortcut += "0"  // 物理键 "0"

        case 0x7A: shortcut += "F1"  // 功能键 F1
        case 0x78: shortcut += "F2"  // 功能键 F2
        case 0x63: shortcut += "F3"  // 功能键 F3
        case 0x76: shortcut += "F4"  // 功能键 F4
        case 0x60: shortcut += "F5"  // 功能键 F5
        case 0x61: shortcut += "F6"  // 功能键 F6
        case 0x62: shortcut += "F7"  // 功能键 F7
        case 0x64: shortcut += "F8"  // 功能键 F8
        case 0x65: shortcut += "F9"  // 功能键 F9
        case 0x6D: shortcut += "F10" // 功能键 F10
        case 0x67: shortcut += "F11" // 功能键 F11
        case 0x6F: shortcut += "F12" // 功能键 F12

        default:
            // 使用字符作为回退
            shortcut += event.charactersIgnoringModifiers?.uppercased() ?? "Unknown"
        }

        return shortcut
    }

    
    /// 将按键事件解析为快捷键字符串
    private func createShortcutString(characters: String, flags: NSEvent.ModifierFlags) -> String {
        var shortcut = ""
        if flags.contains(.command) { shortcut += "Cmd+" }
        if flags.contains(.shift) { shortcut += "Shift+" }
        if flags.contains(.control) { shortcut += "Ctrl+" }
        if flags.contains(.option) { shortcut += "Opt+" }
        shortcut += characters.uppercased()
        return shortcut
    }
    
    //完美实现，但是需要关闭沙箱
    func bringAppToFront(appIdentifier: String) {
        // 减少延迟，且确保不进行不必要的等待
        let script = """
        tell application "System Events"
            -- 检查应用是否在运行，如果没有运行则激活
            set appList to (every application process whose bundle identifier is "\(appIdentifier)")
            if (count of appList) > 0 then
                set targetApp to first item of appList
                set frontmost of targetApp to true -- 将应用置于前台
            else
                tell application id "\(appIdentifier)"
                    activate -- 激活应用
                end tell
            end if
        end tell

        tell application id "\(appIdentifier)"
            -- 窗口排序部分仍然执行
            set windowCount to count of windows
            if windowCount > 0 then
                repeat with i from 1 to windowCount
                    set index of window i to 1
                end repeat
            end if
        end tell
        """

        // 使用 `Process` 执行 osascript，确保最小化处理过程的延迟
        let process = Process()
        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", script]
        
        do {
            try process.run()  // 执行 AppleScript
            process.waitUntilExit()  // 等待脚本执行完毕
        } catch {
            // 不输出错误信息，保持安静
        }
    }
}

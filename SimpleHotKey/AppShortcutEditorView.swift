import SwiftUI
import SwiftData

struct AppShortcutEditorView: View {
    @Bindable var item: Item // 传入的 Item 对象，直接绑定到视图
    @State private var isListeningForKeyPress = false // 控制是否开始监听
    @State private var showPopup = false // 控制弹出框显示状态
    var shortcutManager: ShortcutManager
    @State private var monitor: Any? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("快捷键:")
                    .frame(width: 120, alignment: .leading)
                // 按钮用于触发监听快捷键
                Button(action: {
                    showPopup.toggle()
                    isListeningForKeyPress = true
                    listenForKeyPress(item: self.item) // 开始监听快捷键
                }) {
                    Text(item.appIdentifier.isEmpty ? "点击设置" : "\(item.shortcutKey)")
                        .frame(width: 200, height: 30)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                        .padding(.vertical, 5)
                }
                .disabled(isListeningForKeyPress) // 如果正在监听快捷键，禁用按钮
            }
            // Enable Shortcut 开关
            HStack {
                Text("控制是否打开应用:")
                    .frame(width: 120, alignment: .leading)
                Toggle("", isOn: $item.isEnabled)
                    .onChange(of: item.isEnabled) { _ in
//                        saveItem()  // 实时保存
                    }
            }
            
            // Enable Another Option 开关
            HStack {
                Text("切换应用隐藏:")
                    .frame(width: 120, alignment: .leading)
                Toggle("", isOn: $item.isAnotherOptionEnabled)
                    .onChange(of: item.isAnotherOptionEnabled) { _ in
//                        saveItem()  // 实时保存
                    }
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top) // 设置VStack顶部对齐
        .navigationTitle("编辑")
        .onChange(of: item) { newItem in
            // 监听 item 变化时停止按键监听
            stopListeningForKeyPress()
        }
    }
    
    // 监听按键并保存
    private func listenForKeyPress(item: Item) {
        // 确保只有在监听标志为 true 时才开始监听按键
        guard isListeningForKeyPress else { return }
                
        if monitor != nil {
            NSEvent.removeMonitor(monitor)
            monitor = nil;
        }
        
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // 获取按键的字符
            let shortcut = createShortcutString(event: event)
            //通知监听
            if(self.shortcutManager.check(appIdentifier: self.item.appIdentifier, shortcuKey: shortcut)) {
                // 更新按下的快捷键
                item.shortcutKey = shortcut
                saveItem()
                print("更新快捷键\(shortcut)")
            }else {
                print("快捷键冲突")
            }
            stopListeningForKeyPress()
            showPopup = false // 隐藏弹窗
            return event
        }
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
    
    // 实时保存数据
    private func saveItem() {
       self.shortcutManager.setItem(item: self.item)
    }

    // 停止按键监听
    private func stopListeningForKeyPress() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor)
            monitor = nil
        }
        isListeningForKeyPress = false // 停止监听
        print("关闭监听")
    }
}

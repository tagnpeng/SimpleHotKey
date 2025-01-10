//
//  ContentView.swift
//  SimpleHotKey
//
//  Created by tang on 2025/1/6.
//

import SwiftUI
import SwiftData
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    private var shortcutManager: ShortcutManager = ShortcutManager()
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items, id: \.appIdentifier) { item in
                    NavigationLink {
                        AppShortcutEditorView(item: item, shortcutManager: shortcutManager)
                    } label: {
                        HStack {
                            // 强制解包 iconData 并将其转换为 NSImage
                            let icon = NSWorkspace.shared.icon(forFile: item.iconData!)
                            Image(nsImage: icon) // 强制解包并显示图标
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20) // 设置图标大小
                            Text("\(item.appName)")
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .onAppear {
            self.shortcutManager.setItem(items: self.items)
            self.shortcutManager.startListening()
        }
    }
    
    private func addItem() {
        // 打开文件选择器
        let openPanel = NSOpenPanel()
        
        // 使用 UTType 来限制选择的内容类型为应用程序
        openPanel.allowedContentTypes = [UTType.application] // 只允许选择应用
        
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.urls.first {
                // 获取应用的 bundleIdentifier
                if let bundle = Bundle(url: url) {
                    let appIdentifier = bundle.bundleIdentifier ?? "Unknown Identifier"
                    
                    if isAppAlreadyAdded(appIdentifier) {
                        // 如果已经添加，不做任何处理
                        return
                    } else {
                        // 获取应用的名称 (使用 CFBundleName 或 CFBundleDisplayName)
                        let appName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                        ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                        ?? url.lastPathComponent
                        
                        DispatchQueue.main.async {
                            withAnimation {
                                let newItem = Item(
                                    appIdentifier: appIdentifier,
                                    shortcutKey: "null",
                                    isEnabled: true,
                                    isAnotherOptionEnabled: false,
                                    iconData: url.path, // 保存图标的二进制数据
                                    appName: appName // 保存应用名称
                                )
                                modelContext.insert(newItem)
                            }
                        }
                    }
                }
            }
            // 确保在选择完成后关闭面板
            openPanel.close()
            print("关闭面板")
        }
    }
    
    private func isAppAlreadyAdded(_ appIdentifier: String) -> Bool {
        // 查询现有的数据，检查是否存在相同的 appIdentifier
        return items.contains { $0.appIdentifier == appIdentifier }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                shortcutManager.remove(item: items[index])
                modelContext.delete(items[index])
            }
        }
    }
    
    private func deleteItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

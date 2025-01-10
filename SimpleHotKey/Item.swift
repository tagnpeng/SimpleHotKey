//
//  Item.swift
//  SimpleHotKey
//
//  Created by tang on 2025/1/6.
//

import Foundation
import SwiftData

@Model
final class Item {
    var appIdentifier: String
    var shortcutKey: String
    var isEnabled: Bool
    var isAnotherOptionEnabled: Bool
    var iconData: String?
    var appName: String
    init(appIdentifier: String, shortcutKey: String, isEnabled: Bool, isAnotherOptionEnabled: Bool, iconData: String?, appName: String) {
        self.appIdentifier = appIdentifier
        self.shortcutKey = shortcutKey
        self.isEnabled = isEnabled
        self.isAnotherOptionEnabled = isAnotherOptionEnabled
        self.iconData = iconData
        self.appName = appName
    }
}

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
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

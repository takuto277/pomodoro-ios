//
//  Item.swift
//  pomodoro-ios
//
//  Created by 小野拓人 on 2026/02/11.
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

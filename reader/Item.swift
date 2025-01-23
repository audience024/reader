//
//  Item.swift
//  reader
//
//  Created by zero on 2025/1/23.
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

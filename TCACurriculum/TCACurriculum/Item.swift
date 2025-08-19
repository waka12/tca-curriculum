//
//  Item.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/19.
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

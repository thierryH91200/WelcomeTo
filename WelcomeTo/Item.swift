//
//  Item.swift
//  WelcomeTo
//
//  Created by thierryH24 on 04/08/2025.
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

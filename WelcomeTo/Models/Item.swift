//
//  Item.swift
//  test50
//
//  Created by thierryH24 on 03/08/2025.
//

import Foundation
import SwiftData

@Model
final class Item {

    var timestamp: Date
    var number: Int
    init(timestamp: Date = .now, count: Int = 0) {
        // Initialisation avec les valeurs passées en paramètres
        self.timestamp = timestamp
        self.number = count
    }
}

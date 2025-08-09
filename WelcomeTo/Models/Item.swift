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
    static let numberKey = "ItemLastNumber"  // Clé UserDefaults

    var timestamp: Date
    var number: Int?

    init(timestamp: Date = .now) {
        // Lire la dernière valeur depuis UserDefaults
        let lastNumber = UserDefaults.standard.integer(forKey: Self.numberKey)
        
        // Incrémenter
        let newNumber = lastNumber + 1
        
        // Enregistrer la nouvelle valeur
        UserDefaults.standard.set(newNumber, forKey: Self.numberKey)

        // Assigner aux propriétés
        self.timestamp = timestamp
        self.number = newNumber
    }
}

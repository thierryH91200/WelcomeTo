//
//  Item.swift
//  test50
//
//  Created by thierryH24 on 03/08/2025.
//

import Foundation
import SwiftData

@Model
final class Person {

    var id = UUID()
    var name: String
    var age: Int
    var city: String
    var number: Int

    init(id: UUID = UUID(), name: String, age: Int, city: String, number: Int = 1)
    {
        self.name = name
        self.age = age
        self.city = city
        self.number = number
    }
}

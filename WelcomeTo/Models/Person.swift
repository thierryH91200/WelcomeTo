//
//  Item.swift
//  test50
//
//  Created by thierryH24 on 03/08/2025.
//

import Foundation
import SwiftData
import Combine


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

final class PersonManager: ObservableObject {
    
    static let shared = PersonManager()
    
    @Published var entitiesPerson = [Person]()
    
    var modelContext: ModelContext? {
        DataContext.shared.context
    }
    
    init () {
    }
    
    @discardableResult
    func create(name: String, age: Int, city: String, number: Int) -> Person {
        let person = Person(name: name, age: age, city: city, number: number)
        entitiesPerson.append(person)
        return person
    }
    
    func getAllData() -> [Person] {
        
        entitiesPerson.removeAll()
        
        let predicate = #Predicate<Person> { _ in true }
        let sort = [SortDescriptor(\Person.name, order: .forward)]
        
        let descriptor = FetchDescriptor<Person>(
            predicate: predicate,
            sortBy: sort )
        
        do {
            entitiesPerson = try modelContext?.fetch(descriptor) ??   []
        } catch {
            print("Error fetching data from SwiftData: \(error)")
            return []
        }
        return entitiesPerson
    }
}

final class DataContext {
    static let shared = DataContext()
    @Published var persons = [Person]()

    var context: ModelContext?
    var undoManager: UndoManager?

    init() {}
}


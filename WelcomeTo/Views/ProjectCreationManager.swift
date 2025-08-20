//  ProjectCreationManager.swift
//  Welcome
//
//  Created by thierryH24 on 04/08/2025.
//

import Foundation
import SwiftData
import Combine


final class ProjectCreationManager: ObservableObject {
    @MainActor func createDatabase(named projectName: String) -> URL? {
        
        let schema = AppGlobals.shared.schema
        let folder = "WelcomeBDD"
        let file = projectName + ".store"

        do {
            let documentsURL = URL.documentsDirectory
            var newDirectory = documentsURL.appendingPathComponent(folder)

            try FileManager.default.createDirectory(at: newDirectory, withIntermediateDirectories: true)
            
            newDirectory = newDirectory.appendingPathComponent(projectName)
            try FileManager.default.createDirectory(at: newDirectory, withIntermediateDirectories: true)

            let storeURL = newDirectory.appendingPathComponent("\(file)")
            print(storeURL.path)
            let config = ModelConfiguration(url: storeURL)
            
            let modelContainer = try ModelContainer(for: schema, configurations: config)
            modelContainer.mainContext.undoManager = UndoManager()

            // Exemple d'insertion d’un élément de test
            let newItem = Item(timestamp: .now)
            modelContainer.mainContext.insert(newItem)
            try modelContainer.mainContext.save()
            
            print("✅ Base créée : \(storeURL.path)")
            return storeURL
        } catch {
            print("❌ Erreur création base : \(error)")
            return nil
        }
    }
}

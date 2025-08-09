import Foundation
import SwiftData
import Combine


final class ProjectCreationManager: ObservableObject {
    func createDatabase(named projectName: String) -> URL? {
        let documentsURL = URL.documentsDirectory
        let newDirectory = documentsURL.appendingPathComponent(projectName)
        do {
            try FileManager.default.createDirectory(at: newDirectory, withIntermediateDirectories: true)
            let storeURL = newDirectory.appendingPathComponent("\(projectName).sqlite")
            let configuration = ModelConfiguration(url: storeURL)
            let container = try ModelContainer(for: Item.self, configurations: configuration)
            let newItem = Item(timestamp: .now)
            container.mainContext.insert(newItem)
            try container.mainContext.save()
            print("✅ Base créée : \(storeURL.path)")
            return storeURL
        } catch {
            print("❌ Erreur création base : \(error)")
            return nil
        }
    }
}

//
//  WelcomeToApp.swift
//  WelcomeTo
//
//  Created by thierryH24 on 04/08/2025.
//

import SwiftUI
import SwiftData
import Combine

@main
struct WelcomeToApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var appState = AppState()
    @StateObject private var recentManager = RecentProjectsManager() // ← ici
    @StateObject private var projectCreationManager = ProjectCreationManager()
    @State private var dataController: DataController
    var modelContainer: ModelContainer
    
    let schema = AppGlobals.shared.schema
    let folder = "WelcomeBDD"
    let file = "WelcomeTo.store"

    init() {
        do {
            let documentsURL = URL.documentsDirectory
            let directory = documentsURL.appendingPathComponent(folder)
            if !FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            }

            let storeURL = directory.appendingPathComponent(file)
            let config = ModelConfiguration(url: storeURL)
            
            modelContainer = try ModelContainer(for: schema, configurations: config)
            modelContainer.mainContext.undoManager = UndoManager()
            
            // ⚠️ Initialisation de la propriété temporaire
            dataController = DataController(url: storeURL)

        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }

    var body: some Scene {
        WindowGroup {
            if appState.isProjectOpen {
                ContentView()
                    .environment(\.modelContext, dataController.modelContainer.mainContext)
                    .environmentObject(appState)
            } else {
                WelcomeWindowView(
                    recentManager: recentManager, openHandler: { url in
                        let project = RecentProject(name: url.lastPathComponent, url: url)
                        recentManager.addProject(project)
                        dataController = DataController(url: url)
                    },
                    onCreateProject: {
                        createProject()
                        appState.isProjectOpen = true
                    }
                )
                .environment(\.modelContext, modelContainer.mainContext)
                .environmentObject(appState)
                .environmentObject(recentManager)
                // Injection of projectCreationManager environment object
                .environmentObject(projectCreationManager)
            }
        }
    }
    
    func createProject() {
        

        // 1. Demander un nom à l’utilisateur
        let alert = NSAlert()
        alert.messageText = String(localized:"Project Name")
        alert.informativeText = String(localized:"Enter the name of your new database :")
        alert.alertStyle = .informational
        alert.addButton(withTitle: String(localized:"Cancel"))
        alert.addButton(withTitle: String(localized:"OK"))

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        textField.placeholderString = "MonProjet"
        alert.accessoryView = textField

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return } // Annuler
        let projectName = textField.stringValue.isEmpty ? "ProjetSansNom" : textField.stringValue

        // 2. Construire l'URL avec le nom choisi
        let documentsURL = URL.documentsDirectory
        let newDirectory = documentsURL.appendingPathComponent(projectName)
        do {
            try FileManager.default.createDirectory(at: newDirectory, withIntermediateDirectories: true)
        } catch {
            print("❌ Erreur création dossier : \(error)")
            return
        }

        let storeURL = newDirectory.appendingPathComponent("\(projectName).sqlite")

        // 3. Créer la base SwiftData avec ce nom
        do {
            let configuration = ModelConfiguration(url: storeURL)
            let container = try ModelContainer(for: schema, configurations: configuration)

            // Exemple d'insertion d’un élément de test
            let newItem = Item(timestamp: .now)
            container.mainContext.insert(newItem)
            try container.mainContext.save()
            
            let project = RecentProject(name: storeURL.lastPathComponent, url: storeURL)
            recentManager.addProject(project)
            
            print("✅ Base créée : \(storeURL.path)")
        } catch {
            print("❌ Erreur création base : \(error)")
        }
    }
}


@Observable
@MainActor
final class DataController {
    var modelContainer: ModelContainer
    let schema = AppGlobals.shared.schema

    init(url: URL) {
        let config = ModelConfiguration(url: url)
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: config)
            self.modelContainer.mainContext.undoManager = UndoManager()
        } catch {
            fatalError("❌ Failed to create model container: \(error)")
        }
    }
}

final class AppGlobals {
    static let shared = AppGlobals() // instance unique
    
    let schema = Schema([Item.self])
    
    private init() {} // empêche la création d'autres instances
}

//
//  WelcomeToApp.swift
//  WelcomeTo
//
//  Created by thierryH24 on 04/08/2025.
//

import SwiftUI
import SwiftData
import Combine

import SwiftUI

import SwiftUI

@main
struct MyApp: App {
    
    @StateObject private var appState = AppState()
    @StateObject private var recentManager = RecentProjectsManager() // ← ici
    @StateObject private var projectCreationManager = ProjectCreationManager()

    // un manager pour chaque fenêtre
    @StateObject private var welcomeWindowSizeManager = WindowSizeManager(windowID: "welcomeWindow")
    @StateObject private var mainWindowSizeManager    = WindowSizeManager(windowID: "mainWindow")

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
        // Fenêtre d'accueil
        Window("Welcome", id: "welcomeWindow") {
            
            let sizeManager = WindowSizeManager(windowID: "welcomeWindow")

            WelcomeWindowView(
                recentManager: recentManager,
                openHandler: { url in
                    let project = RecentProject(name: url.lastPathComponent, url: url)
                    recentManager.addProject(project)
                    dataController = DataController(url: url)
                    appState.isProjectOpen = true   // ← déclenche la bascule
                },
                onCreateProject: {
                    createProject()
                    appState.isProjectOpen = true   // ← déclenche la bascule
                }
            )
            .environment(\.modelContext, modelContainer.mainContext)
            .environmentObject(appState)
            .environmentObject(recentManager)
            .environmentObject(projectCreationManager)
            .background(WindowSwitcher(currentWindowID: "welcomeWindow").environmentObject(appState))
            .background(
                WindowAccessor { window in
                    if let window = window {
                        window.delegate = welcomeWindowSizeManager
                        sizeManager.applySavedSize(to: window)
                    }
                }
            )
        }
        .defaultSize(width: 800, height: 800)

        // Fenêtre principale
        Window("Main", id: "mainWindow") {
            
            let sizeManager = WindowSizeManager(windowID: "mainWindow")

            ContentView()
                .environment(\.modelContext, dataController.modelContainer.mainContext)
                .environmentObject(appState)
                .environmentObject(recentManager)
                .environmentObject(projectCreationManager)
                .background(WindowSwitcher(currentWindowID: "mainWindow").environmentObject(appState))
                .background(
                    WindowAccessor { window in
                        if let window = window {
                            window.delegate = mainWindowSizeManager
                            sizeManager.applySavedSize(to: window)
                        }
                    }
                )

        }
        .defaultSize(width: 1000, height: 600)
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
    static let shared = AppGlobals()
    let schema = Schema([Item.self])
    
    private init() {}
}


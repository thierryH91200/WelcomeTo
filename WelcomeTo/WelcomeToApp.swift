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
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var appState = AppState()
    @StateObject private var recentManager = RecentProjectsManager() // ← ici
    @StateObject private var projectCreationManager = ProjectCreationManager()

    // un manager pour chaque fenêtre
    @StateObject private var welcomeWindowSizeManager = WindowSizeManager(windowID: "welcomeWindow")
    @StateObject private var mainWindowSizeManager    = WindowSizeManager(windowID: "mainWindow")

    @State private var dataController: DataController
    var modelContainer: ModelContainer
    
    let schema = AppGlobals.shared.schema
    let folder = "WelcomeToBDD"
    let file = "WelcomeTo.store"

    init() {
        do {
            let documentsURL = URL.documentsDirectory
            var newDirectory = documentsURL.appendingPathComponent(folder)
            
            if !FileManager.default.fileExists(atPath: newDirectory.path) {
                try FileManager.default.createDirectory(at: newDirectory, withIntermediateDirectories: true)
            }
            
            newDirectory = newDirectory.appendingPathComponent(folder)
            try FileManager.default.createDirectory(at: newDirectory, withIntermediateDirectories: true)

            let storeURL = newDirectory.appendingPathComponent(file)
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
                    let project = RecentProject(name: url.lastPathComponent, url: url, count: 0)
                    recentManager.addProject(project)
                    appState.currentProjectURL = url
                    dataController = DataController(url: url)
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
                .environmentObject(recentManager) // ← AJOUTER ICI
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



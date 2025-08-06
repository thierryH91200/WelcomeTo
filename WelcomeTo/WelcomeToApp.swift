//
//  WelcomeToApp.swift
//  WelcomeTo
//
//  Created by thierryH24 on 04/08/2025.
//

import SwiftUI
import SwiftData
import Combine

//@Observable
class AppState: ObservableObject {
    @Published var databaseURL: URL? = nil
    @Published var isProjectOpen = false
}

@main
struct WelcomeToApp: App {
    @StateObject private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var modelContainer: ModelContainer

    let schema = Schema([
        Item.self
    ])

    init() {
        
        do {
            let documentsURL = URL.documentsDirectory
            let pegaseDirectory = documentsURL.appendingPathComponent("WelcomeBDD")

            // Crée le dossier "Pegase" s'il n'existe pas
            if !FileManager.default.fileExists(atPath: pegaseDirectory.path) {
                try FileManager.default.createDirectory(at: pegaseDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            // Chemin complet vers le fichier store dans le dossier Pegase
            let storeURL = pegaseDirectory.appendingPathComponent("WelcomeTo.store")

            let config = ModelConfiguration(url: storeURL)
            print("💾 SwiftData store location: \(storeURL.path)")

            modelContainer = try ModelContainer(for: schema, configurations: config)
            modelContainer.mainContext.undoManager = UndoManager()

        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }

    var body: some Scene {
        WindowGroup {
            if appState.isProjectOpen {
                ContentView()
                    .environment(\.modelContext, modelContainer.mainContext)
            } else {
                WelcomeWindowView()
                    .environmentObject(appState)
                    .environment(\.modelContext, modelContainer.mainContext)
            }
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
    }
}


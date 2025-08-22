//
//  ContentView.swift
//  Welcome
//
//  Created by thierryH24 on 04/08/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var recentManager: RecentProjectsManager

    @Query(sort: [SortDescriptor(\Person.number, order: .forward)]) private var persons: [Person]

    var body: some View {
        VStack {
            Text("Main window is open ✅")
            Text("Items count: \(persons.count)")
            List(persons) { item in
                HStack {
                    Text("N°\(item.number)")
                    Text(item.name)
                }
            }
            Button("Add Item") {
                addItem()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        .onAppear {
            activateMainWindow()
        }
        .onChange(of: appState.currentProjectURL) { newValue in
            activateMainWindow()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    appState.isProjectOpen = false // Revenir à WelcomeWindowView
                } label: {
                    Label("Home", systemImage: "house")
                }
            }
        }

    }

    // MARK: - Private Methods
    private func addItem() {
        withAnimation {
            if let url = appState.currentProjectURL {
                let itemCount = recentManager.itemCount(for: url)

                let newItem = Person( name: "Baby", age: 7, city: "Seoul", number: itemCount + 1)
                modelContext.insert(newItem)
                do {
                    try modelContext.save()
                    print("✅ Item ajouté et sauvegardé")
                    recentManager.addProject(with: url)
                    
                } catch {
                    print("❌ Erreur lors de la sauvegarde:", error)
                }
            }
        }
    }

    private func activateMainWindow() {
        print("Fenêtres AVANT :", NSApp.windows.map { $0.title })
        if let window = NSApp.windows.first(where: { $0.isVisible && $0.title == "mainWindow" }) {
            window.makeKeyAndOrderFront(nil)
            window.makeMain()
            NSApp.activate(ignoringOtherApps: true)
            print("Fenêtres APRÈS :", NSApp.windows.map { $0.title })
        } else {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.mainWindow?.makeKeyAndOrderFront(nil)
            // Idem ici si besoin
            print("Fenêtres APRÈS :", NSApp.windows.map { $0.title })
        }
    }
}


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
    @Environment(\.undoManager) private var undoManager

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var recentManager: RecentProjectsManager

    @State private var person: [Person] = []

    @Query(sort: [SortDescriptor(\Person.number, order: .forward)]) private var persons: [Person]

    @State private var selectedItem: Person.ID?

    @State private var isDarkMode = false
    @State private var refreshID = UUID()

    @State private var isAddDialogPresented = false
    @State private var isEditDialogPresented = false
    @State private var isModeCreate = false

    var selectedPerson: Person? {
        guard let id = selectedItem else { return nil }
        return persons.first(where: { $0.id == id })
    }
    
    @State private var sortOrder = [KeyPathComparator(\Person.name)]

    
    private var tableSection: some View {
        Table(person, selection: $selectedItem, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name)
            TableColumn("Age") { person in
                Text("\(person.age)")
            }
            TableColumn("City", value: \.city)
            TableColumn("Number") { person in
                Text("\(person.number)")
            }
        }
        .id(refreshID)
    }

    var body: some View {
        VStack {
            Text("Main window is open ✅")
            Text("Items count: \(persons.count)")
            List(persons) { item in
                HStack {
                    Text("N°\(item.number)")
                    Text(item.name)
                    Text("\(item.age)")
                }
            }
//            tableSection
            HStack {
                Button("Add Item") {
                    addItem()
                }
                Button(action: {
                    isAddDialogPresented = true
                    isModeCreate = true
                }) {
                    Label("Add", systemImage: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    isEditDialogPresented = true
                    isModeCreate = false
                }) {
                    Label("Edit", systemImage: "pencil")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(selectedItem == nil)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)

        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.green)
        .onAppear {
            activateMainWindow()
            setupDataManager()
        }
        .onChange(of: appState.currentProjectURL) { _, newValue in
            activateMainWindow()
            setupDataManager()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    appState.isProjectOpen = false // Revenir à WelcomeWindowView
                } label: {
                    Label("Home", systemImage: "house")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    isDarkMode.toggle()
                } label: {
                    Label(isDarkMode ? "Light mode" : "Dark mode",
                          systemImage: isDarkMode ? "sun.max" : "moon")
                }
            }
        }
        .sheet(isPresented: $isEditDialogPresented,
               onDismiss: { setupDataManager()
                            addProject() })
        {
            PersonFormView(
                isPresented: $isEditDialogPresented,
                isModeCreate: $isModeCreate,
                person: selectedPerson,
                url: appState.currentProjectURL)
        }
        .sheet(isPresented: $isAddDialogPresented ,
               onDismiss: { setupDataManager()
                            addProject() })
        {
            PersonFormView(
                isPresented: $isAddDialogPresented,
                isModeCreate: $isModeCreate,
                person: nil,
                url: appState.currentProjectURL ) {
                    addProject()
            }
        }
    }
    
    func addProject() {
        if let url = appState.currentProjectURL {
            recentManager.addProject(with: url)
        }
    }

    // MARK: - Private Methods
    func addItem() {
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
        if let window = NSApp.windows.first(where: { $0.isVisible && $0.title == "mainWindow" }) {
            window.makeKeyAndOrderFront(nil)
            window.makeMain()
            NSApp.activate(ignoringOtherApps: true)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.mainWindow?.makeKeyAndOrderFront(nil)
        }
    }
    
    private func setupDataManager() {
        DataContext.shared.context = modelContext
        DataContext.shared.undoManager = undoManager
        
        person = PersonManager.shared.getAllData()
    }
}



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
                }
            }
            HStack {
                
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
        }
        .onChange(of: appState.currentProjectURL) { _, newValue in
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
            ToolbarItem(placement: .automatic) {
                Button {
                    isDarkMode.toggle()
                } label: {
                    Label(isDarkMode ? "Light mode" : "Dark mode",
                          systemImage: isDarkMode ? "sun.max" : "moon")
                }
            }


        }
        .sheet(isPresented: $isEditDialogPresented, onDismiss: {setupDataManager()})
        {
            PersonFormView(
                isPresented: $isEditDialogPresented,
                isModeCreate: $isModeCreate,
                person: selectedPerson)
        }
        .sheet(isPresented: $isAddDialogPresented , onDismiss: {setupDataManager()})
        {
            PersonFormView(
                isPresented: $isAddDialogPresented,
                isModeCreate: $isModeCreate,
                person: nil)
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

        // Vider toutes les anciennes entités avant de recharger (sécurité)
//        PersonManager.shared.resetEntities()

        if let allData = PersonManager.shared.getAllData() {
            person = allData
        } else {
            person = []
        }
    }

}

// Vue pour la boîte de dialogue d'ajout
struct PersonFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Binding var isPresented: Bool
    @Binding var isModeCreate: Bool
    let person: Person?
    
    @State private var name: String = ""
    @State private var age: Int = 0
    @State private var city: String = ""
    @State private var number: Int = 1

    var body: some View {
        VStack(spacing: 0) { // Spacing à 0 pour que les bandeaux soient collés au contenu
            // Bandeau du haut
            Rectangle()
                .fill(isModeCreate ? Color.blue : Color.green)
                .frame(height: 10)
            
            // Contenu principal
            VStack(spacing: 20) {
                Text(isModeCreate ? "Add Person" : "Edit Person")
                    .font(.headline)
                    .padding(.top, 10) // Ajoute un peu d'espace après le bandeau
                
                HStack {
                    Text("Name")
                        .frame(width: 100, alignment: .leading)
                    TextField("", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    Text("Age")
                        .frame(width: 100, alignment: .leading)
                    TextField("", value: $age, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    Text("City")
                        .frame(width: 100, alignment: .leading)
                    TextField("", text: $city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Spacer()
            }
            .padding()
            .navigationTitle(person == nil ? "New Person" : "Edit Person")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        isPresented = false
                        save()
                        dismiss()
                    }
                    .disabled(name.isEmpty || city.isEmpty)
                    .opacity(name.isEmpty || city.isEmpty ? 0.6 : 1)
                }
            }
            .frame(width: 400)
            
            // Bandeau du bas
            Rectangle()
                .fill(isModeCreate ? Color.blue : Color.green)
                .frame(height: 10)
        }
        .onAppear {
            if let person = person {
                name = person.name
                age = person.age
                city = person.city
                number = person.number
            }
        }
    }
    
    private func save() {
        if isModeCreate { // Création
            PersonManager.shared.create(
                name: name,
                age: age,
                city: city,
                number: number
            )
        } else { // Modification
            if let existingItem = person {
                existingItem.name = name
                existingItem.age = age
                existingItem.city = city
                try? modelContext.save()
            }
        }
        
        isPresented = false
        dismiss()
    }
    
    private func updatePerson(_ item: Person) {
        item.name = name
        item.age = age
        item.city = city
        item.number = number
    }
}



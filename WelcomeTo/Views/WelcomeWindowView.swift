//
//  WelcomeWindowView.swift
//  Welcome
//
//  Created by thierryH24 on 04/08/2025.
//

import SwiftUI
import SwiftData

struct WelcomeWindowView: View {
    @ObservedObject var recentManager: RecentProjectsManager
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    
    var openHandler: (URL) -> Void
    
    @State private var window: NSWindow?
    @State private var showCreateSheet = false
    
    var body: some View {
        HStack(spacing: 0) {
            LeftPanelView(
                openHandler: openHandler
            )
            .environmentObject(appState)
            .environmentObject(recentManager)

            Divider()
            
            RecentProjectsListView(
                recentManager: recentManager,
                openHandler: openHandler
            )
            .environmentObject(appState)
        }
        .frame(width: 700, height: 400)
        .getHostingWindow { self.window = $0 }
    }
}

private struct LeftPanelView: View {
    @Environment(\.modelContext) private var modelContext

    var openHandler: (URL) -> Void
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var recentManager: RecentProjectsManager
    @EnvironmentObject var projectCreationManager: ProjectCreationManager
    
    @State private var showCreateSheet = false
    @State private var showResetAlert = false
    @State private var showCopySuccessAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "hammer.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
            
            Text("WelcomeTo")
                .font(.largeTitle)
                .bold()
            
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"))")
                .foregroundColor(.secondary)
            
            VStack(spacing: 10) {
                Button("Create New Document...") {
                    showCreateSheet = true
                }

                Button("Open existing document...") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = true
                    panel.canChooseDirectories = false
                    panel.allowsMultipleSelection = false
                    panel.allowedContentTypes = [.sqlite, .store]
                    if panel.runModal() == .OK, let url = panel.url {
                        openHandler(url)
                        recentManager.addProject(with: url)
                        appState.isProjectOpen = true
                    }
                }
                
                Button("Open sample document Project...") {
                    preloadDBData()
                }
                
                Button("Reset preferences…") {
                    showResetAlert = true
                }
                .foregroundColor(.red)
                .alert("Confirm reset?", isPresented: $showResetAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) {
                        if let appDomain = Bundle.main.bundleIdentifier {
                            UserDefaults.standard.removePersistentDomain(forName: appDomain)
                            UserDefaults.standard.synchronize()
                        }
                    }
                } message: {
                    Text(String(localized: "This operation will delete all application preferences. Are you sure you want to proceed?"))
                }
            }
            Spacer()
        }
        .alert("Copie réussie", isPresented: $showCopySuccessAlert) {
            Button(role: .cancel) {
                // No action needed
            } label: {
                Text("✅ OK")
            }
            .frame(width: 50)

        } message: {
            Text("La copie a bien été effectuée.")
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateProjectView(onCreate: { projectName in
                projectCreationManager.createDatabase(named: projectName)
            }, onOpenProject: openHandler)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // https://stackoverflow.com/questions/40761140/how-to-pre-load-database-in-core-data-using-swift-3-xcode-8
    func preloadDBData() {
        let folder = "WelcomeToBDD"
        let file = "SampleWelcomeTo.store"
        let documentsURL = URL.documentsDirectory
        let newDirectory = documentsURL.appendingPathComponent(folder)

        do {
            if !FileManager.default.fileExists(atPath: newDirectory.path) {
                try FileManager.default.createDirectory(at: newDirectory, withIntermediateDirectories: true)
            }
        } catch {
            print("❌ Erreur création base : \(error)")
            return
        }
        
        let newDirectory1 = newDirectory.appendingPathComponent(folder)

        do {
            if !FileManager.default.fileExists(atPath: newDirectory1.path) {
                try FileManager.default.createDirectory(at: newDirectory1, withIntermediateDirectories: true)
            }
        } catch {
            print("❌ Erreur création base : \(error)")
            return
        }

        guard let sqlitePath = Bundle.main.path(forResource: "SampleWelcomeTo", ofType: "store") else {
            print("Fichier source introuvable dans le bundle")
            return
        }

        let URL1 = URL(fileURLWithPath: sqlitePath)
        let storeURL = newDirectory1.appendingPathComponent(file)

        // Supprime l'ancien fichier s'il existe déjà à destination
        if FileManager.default.fileExists(atPath: storeURL.path) {
            do {
                try FileManager.default.removeItem(at: storeURL)
            } catch {
                print("Erreur lors de la suppression de l'ancien fichier : \(error)")
            }
        }

        do {
            try FileManager.default.copyItem(at: URL1, to: storeURL)
            DispatchQueue.main.async {
                self.showCopySuccessAlert = false
            }
        } catch {
            print("Erreur lors de la copie : \(error)")
        }
        openHandler(storeURL)
        recentManager.addProject(with: storeURL)
        appState.isProjectOpen = true
    }
}

private struct RecentProjectsListView: View {
    @ObservedObject var recentManager: RecentProjectsManager
    var openHandler: (URL) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Projects")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(recentManager.projects, id: \.id) { project in
                            RecentProjectRowView(
                                project: project,
                                onOpen: openHandler,
                                onDelete: {
                                    recentManager.removeProject(project)
                                }
                            )
                            .background(.bar)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.vertical, 4)
                            .id(project.id)
                        }
                    }
                }
                .frame(width: 450, height: 400)
                .onAppear {
                    if let first = recentManager.projects.first {
                        proxy.scrollTo(first.id, anchor: .top)
                    }
                }
            }
            .listStyle(.inset)
            .padding(.horizontal)
        }
        .frame(width: 400)
    }
}

private struct RecentProjectRowView: View {
    let project: RecentProject
    let onOpen: (URL) -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject var appState: AppState
    
    @State private var itemCount: Int? = nil
    @State private var isLoading: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "cylinder.split.1x2.fill")
                .foregroundColor(.accentColor)
                .imageScale(.large)
            
            VStack(alignment: .leading, spacing: 2) {
                // Nom du projet
                Text(project.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                // Chemin avec tilde
                Text((project.url.path as NSString).abbreviatingWithTildeInPath)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
//                Spacer()
                if let itemCount = itemCount {
                    Text("Total items: " + String(itemCount))
                        .foregroundColor(.secondary)
                        .font(.footnote)
                } else if isLoading {
                    Text("Chargement...")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
            
            Spacer()
            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
            
            .buttonStyle(BorderlessButtonStyle())
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onOpen(project.url)
            appState.isProjectOpen = true
        }
        .onAppear { loadItemCount() }
        .onChange(of: project.url) { _ , _ in loadItemCount() }
    }
    
    private func loadItemCount() {
        isLoading = true
        itemCount = nil
        Task {
            do {
                let config = ModelConfiguration(url: project.url)
                let container = try ModelContainer(for: Person.self, configurations: config)
                let result = try container.mainContext.fetch(FetchDescriptor<Person>())
                self.itemCount = result.count
                self.isLoading = false
            } catch {
                self.itemCount = 0
                self.isLoading = false
            }
        }
    }
}

struct CreateProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var recentManager: RecentProjectsManager

    @State private var projectName: String = "Project without a Name"
    static let numberKey = "ItemLastNumber"
    var onCreate: (String) -> URL?
    var onOpenProject: (URL) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New project")
                .font(.headline)
            
            TextField("Project Name", text: $projectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 250)
            
            HStack {
                Button("Cancel") {
                    appState.isProjectOpen = false
                    dismiss()
                }
                Button("Create") {
                    let name = projectName.isEmpty ? "Project Without a Name" : projectName
                    if let url = onCreate(name) {
                        recentManager.addProject(with: url)
                        UserDefaults.standard.set(0, forKey: Self.numberKey)
                        onOpenProject(url)
                        appState.isProjectOpen = true
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
    }
}


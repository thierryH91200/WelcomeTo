//
//  WelcomeToApp.swift
//  WelcomeTo
//
//  Created by thierryH24 on 27/11/2023.
//

import SwiftUI
import SwiftData

@main
struct WelcomeToApp: App {
    
    @StateObject private var recentProjects = RecentProjects()
    @State private var showWelcomeWindow = true
    
    var body: some Scene {
        WindowGroup(id: "Welcome") {
            if showWelcomeWindow {
                WelcomeWindowView()
                    .environmentObject(recentProjects)
                    .frame(minWidth: 600, minHeight: 400)
            }
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "Welcome"))
        
        WindowGroup("Project") {
            ProjectWindowView()
                .environmentObject(recentProjects)
                .frame(minWidth: 800, minHeight: 600)
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "Project"))
    }
}

final class RecentProjects: ObservableObject {
    @Published var projects: [ProjectModel] = []
    
    init() {
        loadRecentProjects()
    }
    
    func loadRecentProjects() {
        // Load recent projects from persistent storage if needed
        // For now, empty list
    }
    
    func addProject(_ project: ProjectModel) {
        if !projects.contains(where: { $0.id == project.id }) {
            projects.insert(project, at: 0)
        }
    }
}

@Model
final class ProjectModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var items: [ProjectItem]
    
    init(name: String, items: [ProjectItem] = []) {
        self.id = UUID()
        self.name = name
        self.items = items
    }
}

@Model
final class ProjectItem {
    @Attribute(.unique) var id: UUID
    var title: String
    
    init(title: String) {
        self.id = UUID()
        self.title = title
    }
}

struct WelcomeWindowView: View {
    @EnvironmentObject private var recentProjects: RecentProjects
    
    @State private var newProjectName: String = ""
    @State private var showingOpenPanel = false
    @State private var selectedProjectFileURL: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to WelcomeTo")
                .font(.largeTitle)
                .padding(.top, 30)
            Text("Create or open your projects")
                .font(.title3)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                Button("Create New Project") {
                    createNewProject()
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("Open Project") {
                    showingOpenPanel = true
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            
            Divider()
                .padding(.vertical, 20)
            
            Text("Recent Projects")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            List {
                ForEach(recentProjects.projects, id: \.id) { project in
                    Button(action: {
                        openProject(project)
                    }) {
                        Text(project.name)
                    }
                }
            }
            .listStyle(.inset)
            
            Spacer()
        }
        .padding()
        .fileImporter(
            isPresented: $showingOpenPanel,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedProjectFileURL = url
                    openProject(at: url)
                }
            case .failure:
                break
            }
        }
    }
    
    private func createNewProject() {
        let newProject = ProjectModel(name: "New Project")
        newProject.items.append(ProjectItem(title: "Welcome Item"))
        recentProjects.addProject(newProject)
        // Open project window for new project
        openProject(newProject)
    }
    
    private func openProject(_ project: ProjectModel) {
        // Insert logic to open project window for existing project
    }
    
    private func openProject(at url: URL) {
        // Insert logic to open project from file URL
    }
}

struct ProjectWindowView: View {
    @EnvironmentObject private var recentProjects: RecentProjects
    
    @State private var project: ProjectModel?
    @State private var newItemTitle: String = ""
    
    var body: some View {
        VStack {
            if let project = project {
                Text("Project: \(project.name)")
                    .font(.title)
                    .padding()
                
                HStack {
                    TextField("New item title", text: $newItemTitle)
                    Button("Add Item") {
                        addItem()
                    }
                    .disabled(newItemTitle.isEmpty)
                }
                .padding()
                
                List {
                    ForEach(project.items, id: \.id) { item in
                        Text(item.title)
                    }
                }
                
                Spacer()
            } else {
                Text("No project loaded")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private func addItem() {
        if !newItemTitle.isEmpty {
            let newItem = ProjectItem(title: newItemTitle)
            project?.items.append(newItem)
            newItemTitle = ""
        }
    }
}

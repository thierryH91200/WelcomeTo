//
//  WelcomeWindowView.swift
//  Welcome
//
//  Created by thierryH24 on 04/08/2025.
//

import SwiftUI
import SwiftData

struct WelcomeWindowView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    
    @State private var window: NSWindow?
    @State private var openPanel: NSOpenPanel? = nil
    
    let recentProjects = [
        "test50",
        "MLXSampleApp",
        "Daily",
        "SwiftDataAnimals",
        "VacuumTest",
        "PegaseUIData",
        "Tophat",
        "Icare",
        "pongGmae"
    ]
    
    let onCreateProject: () -> Void
    
    init(onCreateProject: @escaping () -> Void = {}) {
        self.onCreateProject = onCreateProject
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "hammer.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                
                Text("WelcomeTo")
                    .font(.largeTitle)
                    .bold()
                
                Text("Version 1.0")
                    .foregroundColor(.secondary)
                
                VStack(spacing: 10) {
                    
                    Button("Create New Document...") {
                        // Remove all Item objects from the database
                        let fetchDescriptor = FetchDescriptor<Item>()
                        if let items = try? modelContext.fetch(fetchDescriptor) {
                            for item in items {
                                modelContext.delete(item)
                            }
                            UserDefaults.standard.set(0, forKey: "ItemLastNumber")

                            try? modelContext.save()
                        }
                        appState.isProjectOpen = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Open existing doccument...") {
                        let panel = NSOpenPanel()
                        panel.canChooseFiles = true
                        panel.canChooseDirectories = false
                        panel.allowsMultipleSelection = false
                        panel.allowedContentTypes = [.sqlite, .store]
                        if panel.runModal() == .OK, let url = panel.url {
                            appState.databaseURL = url
                            appState.isProjectOpen = true
                        }
                    }
                    
                    Button("Open sample document Project...") {
                        // action
                        appState.isProjectOpen = true
                    }
                }
                .padding(.top)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(recentProjects, id: \.self) { project in
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text(project)
                        Spacer()
                        Text("~/Documents/pegase")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
                Spacer()
            }
            .padding()
            .frame(width: 300)
        }
        .frame(width: 800, height: 500)
        .padding()
        .getHostingWindow { self.window = $0 }  // ✅ capture la NSWindow
    }
}


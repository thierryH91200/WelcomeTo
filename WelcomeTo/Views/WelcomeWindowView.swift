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
    var onCreateProject: () -> Void

    @State private var window: NSWindow?

    var body: some View {
        HStack(spacing: 0) {
            LeftPanelView(
                onCreateProject: onCreateProject,
                openHandler: openHandler,
                recentManager: recentManager
            )
            .environmentObject(appState)

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
    var onCreateProject: () -> Void
    var openHandler: (URL) -> Void
    var recentManager: RecentProjectsManager
    @EnvironmentObject var appState: AppState

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

            Text("Version 1.0")
                .foregroundColor(.secondary)

            VStack(spacing: 10) {
                Button("Create New Document...") {
                    let fetchDescriptor = FetchDescriptor<Item>()
                    if let items = try? modelContext.fetch(fetchDescriptor) {
                        for item in items {
                            modelContext.delete(item)
                        }
                        UserDefaults.standard.set(0, forKey: "ItemLastNumber")
                        try? modelContext.save()
                    }
                    onCreateProject()
                }
                .buttonStyle(.borderedProminent)

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
//                .buttonStyle(.borderedProminent)


                Button("Open sample document Project...") {
                    onCreateProject()
                }
//                .buttonStyle(.borderedProminent)

            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
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

            List {
                ForEach(recentManager.projects, id: \.id) { project in
                    RecentProjectRowView(
                        project: project,
                        onOpen: openHandler,
                        onDelete: {
                            recentManager.removeProject(project)
                        }
                    )
                }
            }
            .frame(width: 350, height: 300)
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

    var body: some View {
        HStack {
            Image(systemName: "cylinder.split.1x2.fill")
                .foregroundColor(.accentColor)
            Text(project.name)
            Text(project.url.path)
                .foregroundColor(.gray)
                .font(.caption)

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
    }
}

import SwiftUI

@available(macOS 13.0, *)
struct WindowSwitcher: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @EnvironmentObject var appState: AppState

    /// L’ID de la fenêtre qui héberge *cette* instance du switcher
    let currentWindowID: String

    var body: some View {
        Color.clear
            // Synchronisation au lancement (au cas où la mauvaise fenêtre s’ouvre)
            .task {
                if appState.isProjectOpen, currentWindowID == "welcomeWindow" {
                    openWindow(id: "mainWindow")
                    dismissWindow(id: "welcomeWindow")
                    if let window = NSApp.windows.first(where: { $0.title == "Welcome" }) {
                          window.close()
                      }

                } else if !appState.isProjectOpen, currentWindowID == "mainWindow" {
                    openWindow(id: "welcomeWindow")
                    dismissWindow(id: "mainWindow")
                    if let window = NSApp.windows.first(where: { $0.title == "Main" }) {
                          window.close()
                      }
                }
            }
            // Bascule dès que l’état change
            .onChange(of: appState.isProjectOpen) { old, newValue in
                if newValue {
                    // Aller vers Main
                    if currentWindowID != "mainWindow" {
                        openWindow(id: "mainWindow")
                        dismissWindow(id: "welcomeWindow")
                        if let window = NSApp.windows.first(where: { $0.title == "Welcome" }) {
                              window.close()
                          }
                    }
                } else {
                    // Revenir vers Welcome
                    if currentWindowID != "welcomeWindow" {
                        openWindow(id: "welcomeWindow")
                        dismissWindow(id: "mainWindow")
                        if let window = NSApp.windows.first(where: { $0.title == "Main" }) {
                              window.close()
                          }
                    }
                }
            }
    }
}

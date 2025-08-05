//
//  Untitled.swift
//  Welcome
//
//  Created by thierryH24 on 04/08/2025.
//

import SwiftUI
import SwiftData
import Combine



final class SplashManager: ObservableObject {
    
    @Published var showSplash = true
    
    func dismissSplash(after delay: TimeInterval = 2.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation {
                self.showSplash = false
                
                // Active l'app et sa fenêtre
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
}

//class SplashWindowController {
//    private var window: NSWindow?
//
//    func show() {
//        let hostingView = NSHostingView(rootView: SplashScreenView())
//
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
//            styleMask: [.titled, .closable],
//            backing: .buffered,
//            defer: false
//        )
//        window?.center()
//        window?.title = ""
//        window?.isOpaque = false
//        window?.backgroundColor = NSColor.white
//        window?.contentView = hostingView
//        window?.isReleasedWhenClosed = false
//        window?.makeKeyAndOrderFront(nil)
//        NSApp.activate(ignoringOtherApps: true)
//    }
//
//    func close() {
//        window?.close()
//        window = nil
//    }
//}

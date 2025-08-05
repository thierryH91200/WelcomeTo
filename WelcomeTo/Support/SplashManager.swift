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

//
//  WindowSizeManager.swift
//  WelcomeTo
//
//  Created by thierryH24 on 15/08/2025.
//

import SwiftUI
import Combine

class WindowSizeManager: NSObject, ObservableObject, NSWindowDelegate {
    @Published var isMainViewActive: () -> Bool = { false }
    
    private let windowID: String

    init(windowID: String) {
        self.windowID = windowID
        super.init()
    }

    func preferredWindowSize() -> CGSize? {
        if isMainViewActive() {
            let width = UserDefaults.standard.double(forKey: "mainWindowWidth")
            let height = UserDefaults.standard.double(forKey: "mainWindowHeight")
            return (width > 0 && height > 0) ? CGSize(width: width, height: height) : nil
        } else {
            let width = UserDefaults.standard.double(forKey: "welcomeWindowWidth")
            let height = UserDefaults.standard.double(forKey: "welcomeWindowHeight")
            return (width > 0 && height > 0) ? CGSize(width: width, height: height) : nil
        }
    }

    // Restaure la taille depuis UserDefaults
    func applySavedSize(to window: NSWindow) {
        let width = UserDefaults.standard.double(forKey: "\(windowID)_width")
        let height = UserDefaults.standard.double(forKey: "\(windowID)_height")
        let x      = UserDefaults.standard.double(forKey: "\(windowID)_x")
        let y      = UserDefaults.standard.double(forKey: "\(windowID)_y")

        if width > 0, height > 0 {
            var frame = window.frame
            frame.size = CGSize(width: width, height: height)
            if x != 0 || y != 0 {
                frame.origin = CGPoint(x: x, y: y)
            }
            window.setFrame(frame, display: true)
        }
    }

    // Sauvegarde la taille et la position à chaque redimensionnement ou déplacement
    func windowDidResize(_ notification: Notification) {
        saveFrame(notification: notification)
    }

    func windowDidMove(_ notification: Notification) {
        saveFrame(notification: notification)
    }

    private func saveFrame(notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        let frame = window.frame
        UserDefaults.standard.set(frame.size.width,  forKey: "\(windowID)_width")
        UserDefaults.standard.set(frame.size.height, forKey: "\(windowID)_height")
        UserDefaults.standard.set(frame.origin.x,   forKey: "\(windowID)_x")
        UserDefaults.standard.set(frame.origin.y,   forKey: "\(windowID)_y")
    }
}

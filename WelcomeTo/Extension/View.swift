//
//  Untitled.swift
//  WelcomeTo
//
//  Created by thierryH24 on 15/08/2025.
//

// MARK: - View Extension

import SwiftUI

extension View {
    func getHostingWindow(completion: @escaping (NSWindow?) -> Void) -> some View {
        background(WindowAccessor(callback: completion))
    }
}

//
//  SplashScreenView.swift
//  Welcome
//
//  Created by thierryH24 on 04/08/2025.
//


import SwiftUI
import SwiftData

struct SplashScreenView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gearshape.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)

            Text("WelcomeTo")
                .font(.system(size: 56, weight: .semibold))

            Text("Loading...")
                .foregroundColor(.red)
        }
        .frame(width: 300, height: 300)
        .background(Color.white)
    }
}

//
//  ContentView.swift
//  Welcome
//
//  Created by thierryH24 on 03/08/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    var body: some View {
        VStack {
            Text("Main window is open ✅")
            Text("Items count: \(items.count)")
            List {
                ForEach(items) { item in
                    HStack {
                        Text(item.timestamp.formatted(date: .numeric, time: .shortened))
                        Spacer()
                    }
                }
            }
            Button("Add Item") {
                addItem()
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green)
        .onAppear {
            printHello()

            if let window = NSApp.windows.first(where: { $0.isVisible && $0.title == "Main Project Window" }) {
                window.makeKeyAndOrderFront(nil)
                window.makeMain()
                NSApp.activate(ignoringOtherApps: true)
            } else {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.mainWindow?.makeKeyAndOrderFront(nil)
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
    func printHello() {
        print("ContentView chargé")
        
    }
}

extension View {
    func getHostingWindow(completion: @escaping (NSWindow?) -> Void) -> some View {
        background(WindowAccessor(callback: completion))
    }
}




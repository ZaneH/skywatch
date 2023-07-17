//
//  SwiftUI2App.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/10/23.
//

import SwiftUI

@main
struct SkyWatch: App {
    let persistenceController = PersistenceController.shared

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        
        #if os(macOS)
            Settings {
                SettingsView()
            }
        #endif
    }
}

//
//  TherapAIApp.swift
//  TherapAI
//
//  Created by Ramneet Bhangoo on 2025-05-13.
//

import SwiftUI

@main
struct TherapAIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

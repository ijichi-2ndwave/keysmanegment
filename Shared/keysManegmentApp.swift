//
//  keysManegmentApp.swift
//  Shared
//
//  Created by ijichi on 2021/05/17.
//

import SwiftUI

@main
struct keysManegmentApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

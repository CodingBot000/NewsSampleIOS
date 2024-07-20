//
//  NewsApp.swift
//  News
//
//  Created by switchMac on 7/21/24.
//

import SwiftUI

@main
struct NewsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

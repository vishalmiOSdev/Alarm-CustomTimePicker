//
//  ClassicWatchApp.swift
//  ClassicWatch
//
//  Created by Vishal Manhas on 28/08/24.
//

import SwiftUI

@main
struct ClassicWatchApp: App {
    let persistenceController = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .environment(\.managedObjectContext, persistenceController.persistentContainer.viewContext)
        }
    }
}

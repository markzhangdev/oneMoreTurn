//
//  OneMoreTurnApp.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 30/9/2023.
//

import SwiftUI
import SwiftData

@main
struct OneMoreTurnApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Match.self,
            Team.self,
            Player.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var userSettings = UserSettingsUseCase().shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(userSettings)
        }
        .modelContainer(sharedModelContainer)
    }
}

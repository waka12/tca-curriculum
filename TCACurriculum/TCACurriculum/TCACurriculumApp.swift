//
//  TCACurriculumApp.swift
//  TCACurriculum
//
//  Created by わくわく on 2025/08/19.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct TCACurriculumApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Day10GitHubScreen(store: Store(initialState: Day10GitHubFeature.State()) {
                Day10GitHubFeature()
            })
        }
        .modelContainer(sharedModelContainer)
    }
}

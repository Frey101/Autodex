//
//  AutodexApp.swift
//  Autodex
//
//  Created by Alyssia Frey on 29/05/2026.
//

import SwiftUI
import SwiftData

@main
struct AutodexApp: App {
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

    init() {
        // Configuration du cache réseau d'images (50 Mo RAM, 150 Mo disque)
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 150 * 1024 * 1024,
            diskPath: "autodex_images_cache"
        )
    }

    var body: some Scene {
        WindowGroup {
            Navigationview()
        }
        .modelContainer(for: FavoriteCar.self)
    }
}

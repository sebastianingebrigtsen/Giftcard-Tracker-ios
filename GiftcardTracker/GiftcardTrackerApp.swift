//
//  GiftcardTrackerApp.swift
//  GiftcardTracker
//
//  Created by Sebastian Ingebrigtsen on 18/12/2025.
//

import SwiftUI
import SwiftData

@main
struct GiftcardTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: GiftCard.self)
    }
}

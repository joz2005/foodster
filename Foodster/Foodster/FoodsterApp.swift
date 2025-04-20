//
//  FoodsterApp.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/7/25.
//

import SwiftUI
import SwiftData

@main
struct FoodsterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedRestaurant.self)
    }
}

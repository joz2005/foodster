//
//  MainView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var vm: FoodsterViewModel = .init()
    @State private var location: String = ""
    @StateObject private var locationManager: LocationManager = LocationManager()
    @State private var user: User = User()
    @State private var term: String = ""
    @State private var sortBy: String = "best_match"
    @State private var hasPerformedInitialFetch = false

    var body: some View {
        TabView {
            FoodsterHomeView(vm: $vm, location: $location, user: $user, hasPerformedInitialFetch: $hasPerformedInitialFetch)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .environmentObject(locationManager)
            
            FoodsterSearchView(vm: $vm, location: $location, term: $term, sortBy: $sortBy, user: $user, hasPerformedInitialFetch: $hasPerformedInitialFetch)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass.circle")
                }
                .environmentObject(locationManager)

            FoodsterSavedView(vm: $vm)
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
                .environmentObject(locationManager)
        }
    }
}

#Preview {
    ContentView()
}

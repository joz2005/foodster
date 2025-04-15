//
//  ContentView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var vm: FoodsterViewModel = .init()
    @State private var location: String = ""
    @State private var term: String = ""
    @State private var sortBy: String = "best_match"

    var body: some View {
        TabView {
            NavigationStack {
                FoodsterHomeView(vm: $vm, location: $location)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                FoodsterSearchView(vm: $vm, location: $location, term: $term, sortBy: $sortBy)
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass.circle")
            }

            NavigationStack {
                FoodsterSavedView(vm: $vm)
            }
            .tabItem {
                Label("Saved", systemImage: "bookmark")
            }
        }
    }
}

#Preview {
    ContentView()
}

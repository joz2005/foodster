//
//  MainView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import SwiftUI

struct MainView: View {
    @State private var vm: FoodsterViewModel = .init()
    @State private var location: String = ""
    @State private var term: String = ""
    @State private var sortBy: String = "best_match"

    var body: some View {
        TabView {
            FoodsterHomeView(vm: $vm, location: $location)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            FoodsterSearchView(vm: $vm, location: $location, term: $term, sortBy: $sortBy)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass.circle")
                }

            FoodsterSavedView(vm: $vm)
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
        }
    }
}

#Preview {
    MainView()
}

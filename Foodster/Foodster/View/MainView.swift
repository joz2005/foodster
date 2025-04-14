//
//  MainView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import SwiftUI

struct MainView: View {
    @State private var vm: FoodsterViewModel = FoodsterViewModel()
    @State private var location: String = "Chapel Hill"
    
    var body: some View {
        TabView {
            FoodsterHomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            FoodsterSearchView(vm: $vm, location: $location)
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

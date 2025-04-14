//
//  FoodsterSavedView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import SwiftUI


struct FoodsterSavedView: View {
    @Binding var vm: FoodsterViewModel
    
    @State private var savedRestaurants: [Restaurant] = []
    
    
    var body: some View {
        NavigationStack {
            List(vm.savedRestaurants) { restaurant in
                HStack {
                    NavigationLink {
                        RestaurantDetailView(restaurant: restaurant)
                    } label: {
                        HStack {
                            RestaurantRow(restaurant: restaurant)
                        }
                    }
                    
                    Button {
                        Task {
                            await vm.saveRestaurant(restaurant: restaurant)
                        }
                    } label: {
                        Image(systemName: vm.savedRestaurants.contains(where: {$0.id == restaurant.id}) ? "bookmark.fill" : "bookmark")
                    }
                    .buttonStyle(.plain)
                }
                .refreshable {
                    savedRestaurants = vm.savedRestaurants
                }
            }
            .navigationTitle("Saved")
            .task {
                savedRestaurants = vm.savedRestaurants
            }
            .overlay {
                if vm.savedRestaurants.isEmpty {
                    ContentUnavailableView ("No restaurants nearby.", systemImage: "fork.knife.circle", description: Text("Please enter another location above."))
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var vm: FoodsterViewModel = FoodsterViewModel()
    FoodsterSavedView(vm: $vm)
}

//
//  FoodsterSavedView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/11/25.
//

import SwiftData
import SwiftUI

struct FoodsterSavedView: View {
    @Binding var vm: FoodsterViewModel
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedRestaurant.savedAt, order: .reverse) private var savedRestaurants: [SavedRestaurant]

    var body: some View {
        NavigationStack {
            Spacer(minLength: 20)
            List {
                ForEach(savedRestaurants) { savedRestaurant in
                    let restaurant = savedRestaurant.toRestaurant()
                    HStack {
                        NavigationLink {
                            RestaurantDetailView(restaurant: restaurant, locationManager: locationManager, vm: vm)
                        } label: {
                            HStack {
                                RestaurantRow(restaurant: restaurant)

                                Spacer()

                                Button {
                                    modelContext.delete(savedRestaurant)
                                    vm.refreshSavedRestaurants(in: modelContext)
                                } label: {
                                    Image(systemName: "bookmark.slash.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.red)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            .onAppear {
                vm.refreshSavedRestaurants(in: modelContext)
            }
            .navigationTitle("Saved Restaurants")
            .overlay {
                if savedRestaurants.isEmpty {
                    ContentUnavailableView("No restaurants saved.",
                                           systemImage: "bookmark.circle",
                                           description: Text("Please save a restaurant to view it here."))
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var vm = FoodsterViewModel()
    FoodsterSavedView(vm: $vm)
}

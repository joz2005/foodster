//
//  FoodsterView.swift
//  Foodster
//
//  Created by Joseph Zheng on 4/8/25.
//

import SwiftUI

struct FoodsterSearchView: View {
    
    // Backend Requests
    @Binding var vm: FoodsterViewModel
    @Binding var location: String
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Enter Location", text: $location)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        Task {
                            await vm.getRestaurants(location: location)
                        }
                    } label: {
                        if vm.isLoading {
                            ProgressView()
                        } else {
                            Text("Search")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isLoading)
                }
                .padding()
                
//                if let error = vm.errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                        .padding()
//                }
                
                List(vm.restaurants) { restaurant in
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
                }
                .refreshable {
                    await search()
                }
            }
            .navigationTitle("Foodster")
            .task {
                await search()
            }
            .overlay {
                if vm.restaurants.isEmpty {
                    ContentUnavailableView ("No restaurants nearby.", systemImage: "fork.knife.circle", description: Text("Please enter another location above."))
                }
            }
        }
    }
    
    private func search() async {
        await vm.getRestaurants(location: location)
    }
}


#Preview {
    @Previewable @State var vm: FoodsterViewModel = FoodsterViewModel()
    @Previewable @State var location: String = "Chapel Hill"
    FoodsterSearchView(vm: $vm, location: $location)
}
